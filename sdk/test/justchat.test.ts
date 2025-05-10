import { Justchat } from '@/moveCall/justchat';
import { SuiClient, getFullnodeUrl } from '@mysten/sui/client';
import { Ed25519Keypair } from '@mysten/sui/keypairs/ed25519';
import { Transaction } from '@mysten/sui/transactions';
import { describe, expect, it } from 'vitest';
import { getKeyInfoFromAlias } from './keyInfo';

describe('Justchat Tests', () => {
  const client = new SuiClient({ url: getFullnodeUrl('testnet') });
  const aliceKeyInfo = getKeyInfoFromAlias('alice');
  if (!aliceKeyInfo) throw new Error('Alice key info not found');
  const keypair = Ed25519Keypair.fromSecretKey(
    Buffer.from(aliceKeyInfo.privateKey, 'base64').slice(1)
  );
  const address = aliceKeyInfo.address;

  it('should send a message', async () => {
    const tx = new Transaction();
    tx.setSender(address);
    tx.setGasBudget(100_000_000);

    const justchat = new Justchat('testnet');

    // メッセージ送信
    justchat.sendMessage(tx, {
      message: 'Hello, Bump Fam!',
      sender: address,
    });

    const txBytes = await tx.build({ client });
    const signature = await keypair.signTransaction(txBytes);
    const result = await client.executeTransactionBlock({
      transactionBlock: txBytes,
      signature: signature.signature,
      options: { showEffects: true, showObjectChanges: true },
    });

    expect(result.effects?.status.status).toBe('success');
  });
});
