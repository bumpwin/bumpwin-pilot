
import { Buffer } from 'buffer';
import { bcs } from '@mysten/bcs';
import {
	SealClient,
	SessionKey,
	getAllowlistedKeyServers,
} from '@mysten/seal';
import { SuiClient, getFullnodeUrl } from '@mysten/sui/client';
import { Transaction } from '@mysten/sui/transactions';
import { SUI_CLOCK_OBJECT_ID } from '@mysten/sui/utils';
import prettyBytes from 'pretty-bytes';
import { getKeyInfoFromAlias } from '../test/keyInfo';

// ──────────────── 共有スロット ────────────────
let SEALED_BYTES: Uint8Array | null = null;
let ALICE_SIG   = '';           // base64
let ID_BYTES:   Uint8Array;     // unlock id
let READY = false;

// ──────────────── 定数 ────────────────
const PACKAGE_ID =
	'0x1d58d7a49fafb509aef183464eaa4c5d1c2f26a56f4a7eb78ddbcd3c83713a38';
const MODULE     = 'tle_counter';
const COUNTER_ID =
	'0x742914409cdb3a5a4f66230f0e0c769f61cd1c326d5000121e7a1e0fe8c7eac1';
const NODE_URL   = getFullnodeUrl('testnet');

// ──────────────── Alice ────────────────
(async () => {
	const sui     = new SuiClient({ url: NODE_URL });
	const aliceKP = getKeyInfoFromAlias('alice')?.keypair;
	if (!aliceKP) throw new Error('missing alice keypair');

	// ── PTB 構築 ──
	const ptb = new Transaction();
	ptb.moveCall({
		target: `${PACKAGE_ID}::${MODULE}::add`,
		arguments: [ptb.object(COUNTER_ID), ptb.pure.u64(42)],
	});
	ptb.setSender(aliceKP.toSuiAddress());
	const ptbBytes  = await ptb.build({ client: sui });
	const signed    = await aliceKP.signTransaction(ptbBytes);
	ALICE_SIG       = signed.signature;               // base64

	// ── unlock id ──
	const unlockTs  = BigInt(Date.now() + 10_000);    // +10s
	ID_BYTES = bcs.u64().serialize(unlockTs).toBytes();
	const idHex     = `0x${Buffer.from(ID_BYTES).toString('hex')}`;

	console.log(
		`⏰ Unlock @ ${new Date(Number(unlockTs)).toISOString()}`,
	);

	// ── Seal encrypt ──
	const seal = new SealClient({
		suiClient: sui,
		serverObjectIds: await getAllowlistedKeyServers('testnet'),
		verifyKeyServers: false,
	});
	const { encryptedBytes } = await seal.encrypt({
		threshold: 1,
		packageId: PACKAGE_ID,
		id: idHex,
		data: new Uint8Array(Buffer.from(signed.bytes, 'base64')),
	});
	SEALED_BYTES = encryptedBytes;
	console.log(`🔐 sealed = ${prettyBytes(encryptedBytes.length)}`);

	READY = true;                                       // Bob へ合図
})().catch(console.error);

// ──────────────── Bob (独立タスク) ────────────────
(async () => {
	// ── Alice 完了待ち ──
	for (let i = 0; i < 50 && !READY; i++) await new Promise(r => setTimeout(r, 200));
	if (!READY || !SEALED_BYTES) throw new Error('alice not ready');

	const sui     = new SuiClient({ url: NODE_URL });
	const bobKP   = getKeyInfoFromAlias('bob')?.keypair;
	if (!bobKP) throw new Error('missing bob keypair');

	// ── SessionKey (signer 指定が必須) ──
	const sessionKey = new SessionKey({
		address: bobKP.toSuiAddress(),
		packageId: PACKAGE_ID,
		ttlMin: 60,            // 1h
		signer: bobKP,         // ← これが無いと ExpiredSessionKey
	});

	// ── seal_approve PTBKind ──
	const approve = new Transaction();
	approve.moveCall({
		target: `${PACKAGE_ID}::${MODULE}::seal_approve`,
		arguments: [
			approve.pure.vector('u8', Array.from(ID_BYTES)),
			approve.object(SUI_CLOCK_OBJECT_ID),
		],
	});
	approve.setSender(bobKP.toSuiAddress());
	const approveBytes = await approve.build({
		client: sui,
		onlyTransactionKind: true,
	});

	// ── Decrypt ──
	const seal = new SealClient({
		suiClient: sui,
		serverObjectIds: await getAllowlistedKeyServers('testnet'),
		verifyKeyServers: false,
	});
	const decrypted = await seal.decrypt({
		data: SEALED_BYTES,
		sessionKey,
		txBytes: approveBytes,
	} as const);                      // satisfy type‐checker

	console.log('🔓 decrypted');

	// ── Execute ──
	const res = await sui.executeTransactionBlock({
		transactionBlock: decrypted,
		signature: ALICE_SIG,          // alice の署名を流用
		requestType: 'WaitForEffectsCert',
		options: { showEffects: true },
	});
	console.log('✅ executed:', JSON.stringify(res.effects, null, 2));
})().catch(console.error);
