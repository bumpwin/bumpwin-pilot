import { Justchat } from '@/moveCall/justchat';
import { SuiClient, getFullnodeUrl } from '@mysten/sui/client';
import { Transaction } from '@mysten/sui/transactions';
import { describe, expect, it } from 'vitest';
import { getKeyInfoFromAlias } from './keyInfo';
import { Red, Green, Blue } from '@/moveCall/mockcoins';

describe('Mock Coins Tests', () => {
  const suiClient = new SuiClient({ url: getFullnodeUrl('testnet') });
  const alice = getKeyInfoFromAlias('alice')?.keypair;
  if (!alice) throw new Error('Alice keypair not found');

  it('should mint red to alice', async () => {
    const tx = new Transaction();
    tx.setSender(alice.toSuiAddress());
    tx.setGasBudget(100_000_000);

    const red = new Red('testnet');

    const coin = red.mint(tx, {
      amount: 100n,
    });
    tx.transferObjects([coin], alice.toSuiAddress());

    const txBytes = await tx.build({ client: suiClient });
    const signature = await alice.signTransaction(txBytes);
    const result = await suiClient.executeTransactionBlock({
      transactionBlock: txBytes,
      signature: signature.signature,
      options: { showEffects: true, showObjectChanges: true },
    });

    expect(result.effects?.status.status).toBe('success');
  });

  it('should mint green to alice', async () => {
    const tx = new Transaction();
    tx.setSender(alice.toSuiAddress());
    tx.setGasBudget(100_000_000);

    const green = new Green('testnet');

    const coin = green.mint(tx, {
      amount: 100n,
    });
    tx.transferObjects([coin], alice.toSuiAddress());

    const txBytes = await tx.build({ client: suiClient });
    const signature = await alice.signTransaction(txBytes);
    const result = await suiClient.executeTransactionBlock({
      transactionBlock: txBytes,
      signature: signature.signature,
      options: { showEffects: true, showObjectChanges: true },
    });

    expect(result.effects?.status.status).toBe('success');
  });

  it('should mint blue to alice', async () => {
    const tx = new Transaction();
    tx.setSender(alice.toSuiAddress());
    tx.setGasBudget(100_000_000);

    const blue = new Blue('testnet');

    const coin = blue.mint(tx, {
      amount: 100n,
    });
    tx.transferObjects([coin], alice.toSuiAddress());

    const txBytes = await tx.build({ client: suiClient });
    const signature = await alice.signTransaction(txBytes);
    const result = await suiClient.executeTransactionBlock({
      transactionBlock: txBytes,
      signature: signature.signature,
      options: { showEffects: true, showObjectChanges: true },
    });

    expect(result.effects?.status.status).toBe('success');
  });
});
