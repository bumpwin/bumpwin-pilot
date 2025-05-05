import { getFullnodeUrl } from '@mysten/sui/client';
import { SuiClient } from '@mysten/sui/client';
import { Ed25519Keypair } from '@mysten/sui/keypairs/ed25519';
import { Transaction } from '@mysten/sui/transactions';
import { isCoinMetadata, isTreasuryCap } from '../src/suigen/sui/coin/structs';

import { faucetDevnet } from '../src/suiClientUtils';
import { OozeFamCoin } from '../src/moveCall/oozeFamCoin';

const client = new SuiClient({ url: getFullnodeUrl('devnet') });

// Setup
const keypair = Ed25519Keypair.generate();
const address = keypair.getPublicKey().toSuiAddress();
console.log('🔑 Address:', address);

// Request SUI from faucet
await faucetDevnet(client, address);

const { packageId, coinMetadataID, treasuryCapID } = await (async () => {
  const tx = new Transaction();
  tx.setSender(address);
  tx.setGasBudget(1_000_000_000);

  await OozeFamCoin.publishOozeFamCoinPackage(tx, { sender: address });
  const signature = await keypair.signTransaction(await tx.build({ client }));
  const result = await client.executeTransactionBlock({
    transactionBlock: await tx.build({ client }),
    signature: signature.signature,
    options: { showEffects: true, showObjectChanges: true },
  });

  console.log(result);

  return {
    packageId: (result.objectChanges?.find((c) => c.type === 'published') as any)?.packageId,
    coinMetadataID: (
      result.objectChanges?.find((c) => c.type === 'created' && isCoinMetadata(c.objectType)) as any
    )?.objectId,
    treasuryCapID: (
      result.objectChanges?.find((c) => c.type === 'created' && isTreasuryCap(c.objectType)) as any
    )?.objectId,
  };
})();

console.log('packageId', `https://suiscan.xyz/devnet/package/${packageId}`);
console.log('coinMetadataID', `https://suiscan.xyz/devnet/object/${coinMetadataID}`);
console.log('treasuryCapID', `https://suiscan.xyz/devnet/object/${treasuryCapID}`);

{
  const tx = new Transaction();
  tx.setSender(address);
  tx.setGasBudget(1_000_000_000);

  OozeFamCoin.createCoin(tx, `${packageId}::ooze_fam_coin::OOZE_FAM_COIN`, {
    treasuryCapID,
    coinMetadataID,
    name: 'Ooze Fam Coin',
    symbol: 'OFC',
    description: 'This is a test coin',
    iconUrl: 'https://s2.coinmarketcap.com/static/img/coins/200x200/1027.png',
  });

  const signature = await keypair.signTransaction(await tx.build({ client }));
  const result = await client.executeTransactionBlock({
    transactionBlock: await tx.build({ client }),
    signature: signature.signature,
    options: { showEffects: true, showObjectChanges: true },
  });

  console.log(result);

  const digest = result.digest;

  console.log('digest', `https://suiscan.xyz/devnet/tx/${digest}`);
}
