import { describe, it, expect } from 'vitest';
import { getFullnodeUrl, SuiClient } from '@mysten/sui/client';
import { Ed25519Keypair } from '@mysten/sui/keypairs/ed25519';
import { Transaction } from '@mysten/sui/transactions';
import { isCoinMetadata, isTreasuryCap } from '@/suigen/sui/coin/structs';
import { faucetDevnet } from '@/suiClientUtils';
import { OozeFamCoin } from '@/moveCall/oozeFamCoin';

describe('OozeFamCoin Creation Tests', () => {
  const client = new SuiClient({ url: getFullnodeUrl('devnet') });
  const keypair = Ed25519Keypair.generate();
  const address = keypair.getPublicKey().toSuiAddress();

  it('should request SUI from faucet', async () => {
    const result = await faucetDevnet(client, address);
    expect(result).toBeDefined();
  });

  it('should publish OozeFamCoin package and create coin', async () => {
    // Publish package
    const tx1 = new Transaction();
    tx1.setSender(address);
    tx1.setGasBudget(1_000_000_000);

    await OozeFamCoin.publishOozeFamCoinPackage(tx1, { sender: address });
    const signature1 = await keypair.signTransaction(await tx1.build({ client }));
    const result1 = await client.executeTransactionBlock({
      transactionBlock: await tx1.build({ client }),
      signature: signature1.signature,
      options: { showEffects: true, showObjectChanges: true },
    });

    expect(result1.effects?.status.status).toBe('success');

    const packageId = (result1.objectChanges?.find((c) => c.type === 'published') as any)
      ?.packageId;
    const coinMetadataID = (
      result1.objectChanges?.find(
        (c) => c.type === 'created' && isCoinMetadata(c.objectType)
      ) as any
    )?.objectId;
    const treasuryCapID = (
      result1.objectChanges?.find((c) => c.type === 'created' && isTreasuryCap(c.objectType)) as any
    )?.objectId;

    expect(packageId).toBeDefined();
    expect(coinMetadataID).toBeDefined();
    expect(treasuryCapID).toBeDefined();

    // Create coin
    const tx2 = new Transaction();
    tx2.setSender(address);
    tx2.setGasBudget(1_000_000_000);

    OozeFamCoin.createCoin(tx2, `${packageId}::ooze_fam_coin::OOZE_FAM_COIN`, {
      treasuryCapID,
      coinMetadataID,
      name: 'Ooze Fam Coin',
      symbol: 'OFC',
      description: 'This is a test coin',
      iconUrl: 'https://s2.coinmarketcap.com/static/img/coins/200x200/1027.png',
    });

    const signature2 = await keypair.signTransaction(await tx2.build({ client }));
    const result2 = await client.executeTransactionBlock({
      transactionBlock: await tx2.build({ client }),
      signature: signature2.signature,
      options: { showEffects: true, showObjectChanges: true },
    });

    expect(result2.effects?.status.status).toBe('success');
    expect(result2.digest).toBeDefined();
  });
});
