import { Transaction } from '@mysten/sui/transactions';
import { bcs, fromHex } from '@mysten/bcs';
import { getKeyInfoFromAlias } from '../test/keyInfo';
import { getFullnodeUrl } from '@mysten/sui/client';
import { SuiClient } from '@mysten/sui/client';

import { getAllowlistedKeyServers, SealClient, SessionKey } from '@mysten/seal';

// === 設定 ===
const PACKAGE_ID = '0x1d58d7a49fafb509aef183464eaa4c5d1c2f26a56f4a7eb78ddbcd3c83713a38';
const MODULE_NAME = 'tle_counter'; // Moveモジュール名
const COUNTER_ID = '0x742914409cdb3a5a4f66230f0e0c769f61cd1c326d5000121e7a1e0fe8c7eac1';
const FULLNODE_URL = getFullnodeUrl('testnet');

// === 準備 ===
const suiClient = new SuiClient({ url: FULLNODE_URL });
const keypair = getKeyInfoFromAlias('alice')?.keypair;
if (!keypair) throw new Error('Keypair not found');

const keyServerIds = await getAllowlistedKeyServers('testnet');

// === 暗号化対象トランザクション ===
const tx = new Transaction();
tx.moveCall({
  target: `${PACKAGE_ID}::${MODULE_NAME}::add`,
  arguments: [tx.object(COUNTER_ID), tx.pure.u64(42)],
});
tx.setSender(keypair.toSuiAddress());
const builtTx = await tx.build({ client: suiClient });
const signedTx = await keypair.signTransaction(builtTx);

// === 時限IDを生成 ===
const unlockTimestampMs = BigInt(Date.now() - 1 * 60 * 1000); // 1 min
const idBytes = bcs.u64().serialize(unlockTimestampMs).toHex();
console.log(`Current time: ${Date.now()}, Unlock time: ${Number(unlockTimestampMs)}`);

// === SealClient を構築して暗号化 ===
const sealClient = new SealClient({
  suiClient,
  serverObjectIds: keyServerIds,
  verifyKeyServers: false,
});

const { encryptedObject } = await sealClient.encrypt({
  threshold: 1,
  packageId: PACKAGE_ID,
  id: idBytes,
  data: Uint8Array.from(signedTx.bytes),
});
console.log(`Encrypted object: ${encryptedObject}`);

// === session key を生成（署名つき）===
const sessionKey = new SessionKey({
  address: keypair.toSuiAddress(),
  packageId: PACKAGE_ID,
  ttlMin: 10,
});
const personalMessage = sessionKey.getPersonalMessage();
const { signature } = await keypair.signPersonalMessage(personalMessage);
sessionKey.setPersonalMessageSignature(signature);
console.log(`Session key: ${sessionKey}`);

// === seal_approve トランザクションを構築 ===
const approvalTx = new Transaction();
approvalTx.moveCall({
  target: `${PACKAGE_ID}::${MODULE_NAME}::seal_approve`,
  arguments: [approvalTx.pure.vector('u8', Array.from(fromHex(idBytes))), approvalTx.object(COUNTER_ID)],
});
const approvalTxBytes = await approvalTx.build({
  client: suiClient,
  onlyTransactionKind: true,
});
console.log(`Approval tx bytes: ${approvalTxBytes}`);

// === 復号 ===
while (true) {
  try {
    const decryptedTxBytes = await sealClient.decrypt({
      data: encryptedObject,
      sessionKey,
      txBytes: approvalTxBytes,
    });
    console.log(`Decrypted tx bytes: ${decryptedTxBytes}`);

    // === 復号後のトランザクションを実行 ===
    await suiClient.executeTransactionBlock({
      transactionBlock: decryptedTxBytes,
      signature: signedTx.signature,
      options: { showEffects: true },
    });
    console.log('Transaction executed successfully');
  } catch (error) {
    console.error('Error:', error);
  }
  await new Promise(resolve => setTimeout(resolve, 20_000));
}

