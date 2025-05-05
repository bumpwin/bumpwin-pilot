import { describe, it, expect } from 'vitest';
import { getFullnodeUrl, SuiClient } from '@mysten/sui/client';
import { Ed25519Keypair } from '@mysten/sui/keypairs/ed25519';
import { Transaction } from '@mysten/sui/transactions';
import { isCoinMetadata, isTreasuryCap } from '@/suigen/sui/coin/structs';
import { faucetDevnet } from '@/suiClientUtils';
import { BumpFamCoin } from '@/moveCall/bumpFamCoin';
import { getKeyInfoFromAlias } from './keyInfo';

describe('BumpFamCoin Creation Tests', () => {
  const client = new SuiClient({ url: getFullnodeUrl('testnet') });
  const aliceKeyInfo = getKeyInfoFromAlias('alice');
  if (!aliceKeyInfo) throw new Error('Alice key info not found');
  const keypair = Ed25519Keypair.fromSecretKey(Buffer.from(aliceKeyInfo.privateKey, 'base64').slice(1));
  const address = aliceKeyInfo.address;

  it('should publish BumpFamCoin package and create coin', async () => {
    // Publish package
    const tx1 = new Transaction();
    tx1.setSender(address);
    tx1.setGasBudget(100_000_000);

    await BumpFamCoin.publishBumpFamCoinPackage(tx1, { sender: address });
    const signature1 = await keypair.signTransaction(await tx1.build({ client }));
    const result1 = await client.executeTransactionBlock({
      transactionBlock: await tx1.build({ client }),
      signature: signature1.signature,
      options: { showEffects: true, showObjectChanges: true },
    });

    expect(result1.effects?.status.status).toBe('success');

    const packageId = (result1.objectChanges?.find(
      (c) => c.type === 'published'
    ) as any)?.packageId;
    const coinMetadataID = (result1.objectChanges?.find(
      (c) => c.type === 'created' && isCoinMetadata(c.objectType)
    ) as any)?.objectId;
    const treasuryCapID = (result1.objectChanges?.find(
      (c) => c.type === 'created' && isTreasuryCap(c.objectType)
    ) as any)?.objectId;

    console.log('Package ID:', packageId);
    console.log('Coin Metadata ID:', coinMetadataID);
    console.log('Treasury Cap ID:', treasuryCapID);

    expect(packageId).toBeDefined();
    expect(coinMetadataID).toBeDefined();
    expect(treasuryCapID).toBeDefined();

    // Wait for the objects to be available
    await new Promise(resolve => setTimeout(resolve, 2000));

    // Verify objects exist
    const coinMetadata = await client.getObject({
      id: coinMetadataID,
      options: { showType: true, showContent: true }
    });
    const treasuryCap = await client.getObject({
      id: treasuryCapID,
      options: { showType: true, showContent: true }
    });

    expect(coinMetadata.data).toBeDefined();
    expect(treasuryCap.data).toBeDefined();

    // Create coin
    const tx2 = new Transaction();
    tx2.setSender(address);
    tx2.setGasBudget(100_000_000);

    BumpFamCoin.createCoin(
      tx2,
      `${packageId}::bump_fam_coin::BUMP_FAM_COIN`,
      {
        treasuryCapID,
        coinMetadataID,
        name: 'Bump Fam Coin',
        symbol: 'BFC',
        description: "This is a test coin",
        iconUrl: 'https://s2.coinmarketcap.com/static/img/coins/200x200/1027.png',
      },
    );

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