import { Buffer } from "buffer";
import { bcs } from "@mysten/bcs";
import { fromHex } from "@mysten/bcs";
import { SealClient, SessionKey, getAllowlistedKeyServers } from "@mysten/seal";
import { SuiClient, getFullnodeUrl } from "@mysten/sui/client";
import { Transaction } from "@mysten/sui/transactions";
import { SUI_CLOCK_OBJECT_ID } from "@mysten/sui/utils";
import prettyBytes from "pretty-bytes";
import { getKeyInfoFromAlias } from "../test/keyInfo";

// SealClient用のデコードインターフェース
interface SealClientDecryptParams {
	data: Uint8Array;
	sessionKey: SessionKey;
	txBytes: Uint8Array;
}

// === 設定 ===
const PACKAGE_ID =
	"0x1d58d7a49fafb509aef183464eaa4c5d1c2f26a56f4a7eb78ddbcd3c83713a38";
const MODULE_NAME = "tle_counter";
const COUNTER_ID =
	"0x742914409cdb3a5a4f66230f0e0c769f61cd1c326d5000121e7a1e0fe8c7eac1";
const FULLNODE_URL = getFullnodeUrl("testnet");

// 暗号化されたトランザクションの共有用変数
let SHARED_BOARD: {
	sealedTx: Uint8Array;
	unlockTimestampMs: bigint;
	signedTx: { bytes: string; signature: string }; // 署名済みトランザクションの情報
};

{
	console.log("Alice");

	// === 準備 ===
	const suiClient = new SuiClient({ url: FULLNODE_URL });
	const alice = getKeyInfoFromAlias("alice")?.keypair;

	if (!alice) {
		throw new Error("Alice keypair not found");
	}

	const keyServerIds = await getAllowlistedKeyServers("testnet");

	// === トランザクション構築（完全な TransactionBlock を作成）===
	const tx = new Transaction();
	tx.moveCall({
		target: `${PACKAGE_ID}::${MODULE_NAME}::add`,
		arguments: [tx.object(COUNTER_ID), tx.pure.u64(42)],
	});
	// トランザクションの送信者をAliceに設定
	tx.setSender(alice.toSuiAddress());
	const txBytes = await tx.build({ client: suiClient });

	// === Aliceがトランザクションに署名 ===
	const signedTx = await alice.signTransaction(txBytes);
	console.log("Transaction signed by Alice");

	// === 時限 ID を構成 ===
	const unlockTimestampMs = BigInt(Date.now() + 30 * 1000); // 30 seconds later - give more time
	const idBytes = bcs.u64().serialize(unlockTimestampMs).toBytes();
	const idHex = `0x${Buffer.from(idBytes).toString("hex")}`;
	console.log(`Current time: ${Date.now()} (${new Date().toISOString()})`);
	console.log(
		`Unlock time:  ${Number(unlockTimestampMs)} (${new Date(Number(unlockTimestampMs)).toISOString()})`,
	);

	// === SealClient を使って署名済みトランザクションを暗号化 ===
	const sealClient = new SealClient({
		suiClient,
		serverObjectIds: keyServerIds,
		verifyKeyServers: false,
	});

	// 署名済みトランザクションを暗号化
	const { encryptedObject } = await sealClient.encrypt({
		threshold: 1,
		packageId: PACKAGE_ID,
		id: idHex,
		data: new Uint8Array(Buffer.from(signedTx.bytes, "base64")), // 署名済みトランザクションのバイト列を暗号化
	});
	console.log(`Encrypted object: ${encryptedObject}`);
	console.log(
		`Encrypted object size: ${prettyBytes(Buffer.from(encryptedObject).length)}`,
	);

	SHARED_BOARD = {
		sealedTx: encryptedObject,
		unlockTimestampMs: unlockTimestampMs,
		signedTx: {
			bytes: signedTx.bytes,
			signature: signedTx.signature,
		},
	};
}
{
	// === Bobの処理 ===
	console.log("Bob");
	const suiClient = new SuiClient({ url: FULLNODE_URL });

	const bob = getKeyInfoFromAlias("bob")?.keypair;

	if (!bob) {
		throw new Error("Bob keypair not found");
	}

	// === Bobのセッションキーを作成 ===
	const sessionKey = new SessionKey({
		address: bob.toSuiAddress(),
		packageId: PACKAGE_ID,
		ttlMin: 10,
	});
	const personalMessage = sessionKey.getPersonalMessage();
	const { signature } = await bob.signPersonalMessage(personalMessage);
	sessionKey.setPersonalMessageSignature(signature);
	console.log("Session key ready for Bob");

	// Aliceが使用したのと同じタイムスタンプを使用する
	const idBytes2 = bcs
		.u64()
		.serialize(SHARED_BOARD.unlockTimestampMs)
		.toBytes();

	// === seal_approve トランザクションを構築 ===
	const approvalTx = new Transaction();
	approvalTx.moveCall({
		target: `${PACKAGE_ID}::${MODULE_NAME}::seal_approve`,
		arguments: [
			approvalTx.pure.vector("u8", Array.from(idBytes2)),
			approvalTx.object(SUI_CLOCK_OBJECT_ID),
		],
	});

	// ここではBobをapprove操作の送信者に設定
	approvalTx.setSender(bob.toSuiAddress());
	const approvalTxBytes = await approvalTx.build({
		client: suiClient,
		onlyTransactionKind: true,
	});
	console.log("Approval tx bytes ready");

	// === 復号 & 実行ループ ===
	try {
		// SealClientを作成
		const keyServerIds2 = await getAllowlistedKeyServers("testnet");
		const sealClient2 = new SealClient({
			suiClient,
			serverObjectIds: keyServerIds2,
			verifyKeyServers: false,
		});

		// 暗号化されたトランザクションを復号
		const decryptParams: SealClientDecryptParams = {
			data: SHARED_BOARD.sealedTx,
			sessionKey,
			txBytes: approvalTxBytes,
		};

		const decryptedTxBytes = await sealClient2.decrypt(decryptParams);
		console.log("Decrypted tx bytes retrieved");

		// 復号された署名済みトランザクションを実行
		const result = await suiClient.executeTransactionBlock({
			transactionBlock: SHARED_BOARD.signedTx.bytes,
			signature: SHARED_BOARD.signedTx.signature,
			requestType: "WaitForEffectsCert",
			options: { showEffects: true },
		});

		console.log(
			`Transaction executed successfully (Alice signed, Bob executed): ${JSON.stringify(result.effects)}`,
		);
	} catch (error) {
		console.log(`Current time: ${Date.now()} (${new Date().toISOString()})`);
		console.error("Error:", error);
	}
}
