import { Transaction } from '@mysten/sui/transactions';
import { bcs } from '@mysten/bcs';
import { fromHex } from '@mysten/bcs';
import { getKeyInfoFromAlias } from '../test/keyInfo';
import { getFullnodeUrl, SuiClient } from '@mysten/sui/client';
import { SUI_CLOCK_OBJECT_ID } from '@mysten/sui/utils';
import { getAllowlistedKeyServers, SealClient, SessionKey } from '@mysten/seal';

// === 設定 ===
const PACKAGE_ID = '0x1d58d7a49fafb509aef183464eaa4c5d1c2f26a56f4a7eb78ddbcd3c83713a38';
const MODULE_NAME = 'tle_counter';
const COUNTER_ID = '0x742914409cdb3a5a4f66230f0e0c769f61cd1c326d5000121e7a1e0fe8c7eac1';
const FULLNODE_URL = getFullnodeUrl('testnet');

// === 準備 ===
const suiClient = new SuiClient({ url: FULLNODE_URL });
const keypair = getKeyInfoFromAlias('alice')?.keypair;
if (!keypair) throw new Error('Keypair not found');

const keyServerIds = await getAllowlistedKeyServers('testnet');

// === トランザクション構築（完全な TransactionBlock を作成）===
const tx = new Transaction();
tx.moveCall({
  target: `${PACKAGE_ID}::${MODULE_NAME}::add`,
  arguments: [tx.object(COUNTER_ID), tx.pure.u64(42)],
});
tx.setSender(keypair.toSuiAddress());
const txBytes = await tx.build({ client: suiClient }); // ★フル構造体でビルド

// === 時限 ID を構成 ===
const unlockTimestampMs = BigInt(Date.now() - 1 * 60 * 1000); // 今より1分前
const idBytes = bcs.u64().serialize(unlockTimestampMs).toBytes();
const idHex = '0x' + Buffer.from(idBytes).toString('hex');
console.log(`Current time: ${Date.now()}, Unlock time: ${Number(unlockTimestampMs)}`);

// === SealClient を使って暗号化 ===
const sealClient = new SealClient({
  suiClient,
  serverObjectIds: keyServerIds,
  verifyKeyServers: false,
});

const { encryptedObject } = await sealClient.encrypt({
  threshold: 1,
  packageId: PACKAGE_ID,
  id: idHex,
  data: txBytes,
});
console.log(`Encrypted object: ${encryptedObject}`);

// === セッションキーを作成 ===
const sessionKey = new SessionKey({
  address: keypair.toSuiAddress(),
  packageId: PACKAGE_ID,
  ttlMin: 10,
});
const personalMessage = sessionKey.getPersonalMessage();
const { signature } = await keypair.signPersonalMessage(personalMessage);
sessionKey.setPersonalMessageSignature(signature);
console.log(`Session key ready`);

// === seal_approve トランザクションを構築 ===
const approvalTx = new Transaction();
approvalTx.moveCall({
  target: `${PACKAGE_ID}::${MODULE_NAME}::seal_approve`,
  arguments: [approvalTx.pure.vector('u8', Array.from(idBytes)), approvalTx.object(SUI_CLOCK_OBJECT_ID)],
});
const approvalTxBytes = await approvalTx.build({
  client: suiClient,
  onlyTransactionKind: true,
});
console.log(`Approval tx bytes ready`);

// === 復号 & 実行ループ ===
while (true) {
  try {
    const decryptedTxBytes = await sealClient.decrypt({
      data: encryptedObject,
      sessionKey,
      txBytes: approvalTxBytes,
    });
    console.log(`Decrypted tx bytes retrieved`);

    const signedTx = await keypair.signTransaction(decryptedTxBytes);
    const result = await suiClient.executeTransactionBlock({
      transactionBlock: decryptedTxBytes,
      signature: signedTx.signature,
      options: { showEffects: true },
    });

    console.log('Transaction executed successfully:', result.effects);
    break;
  } catch (error) {
    console.error('Error:', error);
  }

  await new Promise((resolve) => setTimeout(resolve, 20_000)); // wait 20s
}
