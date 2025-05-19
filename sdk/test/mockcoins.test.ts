import { SuiClient, getFullnodeUrl } from '@mysten/sui/client';
import { Transaction } from '@mysten/sui/transactions';
import { describe, expect, it } from 'vitest';
import { getKeyInfoFromAlias } from './keyInfo';
import { mockcoins } from '@/suigen';
import { MOCKCOINS_OBJECT_IDS } from '@/objectIds';

describe('Mock Coins Tests', () => {
  const suiClient = new SuiClient({ url: getFullnodeUrl('testnet') });
  const alice = getKeyInfoFromAlias('alice')?.keypair;
  if (!alice) throw new Error('Alice keypair not found');

  it('should mint red to alice', async () => {
    const tx = new Transaction();
    tx.setSender(alice.toSuiAddress());
    tx.setGasBudget(100_000_000);

    const redCoin = mockcoins.red.mint(tx, {
      treasuryCap: MOCKCOINS_OBJECT_IDS.TREASURY_CAPS.RED,
      u64: 500_000_000n * 1_000_000n,
    });

    tx.transferObjects([redCoin], alice.toSuiAddress());

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
