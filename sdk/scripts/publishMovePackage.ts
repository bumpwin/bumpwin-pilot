import { getFullnodeUrl } from '@mysten/sui/client';
import { SuiClient } from '@mysten/sui/client';
import { Ed25519Keypair } from '@mysten/sui/keypairs/ed25519';
import { Transaction } from '@mysten/sui/transactions';
import { OOZE_FAM_COIN_MOVE_BYTECODE } from '../src/moveBytecodes/ooze_fam_coin';
import { isCoinMetadata, isTreasuryCap } from '../src/suigen/sui/coin/structs';

import { faucetDevnet, publish } from '../src/suiClientUtils';

const client = new SuiClient({ url: getFullnodeUrl('devnet') });

// Setup
const keypair = Ed25519Keypair.generate();
const address = keypair.getPublicKey().toSuiAddress();
console.log('🔑 Address:', address);

// Request SUI from faucet
await faucetDevnet(client, address);

const tx = new Transaction();
tx.setSender(address);

publish(tx, {
  moveBytecode: OOZE_FAM_COIN_MOVE_BYTECODE,
  sender: address,
});

tx.setGasBudget(1_000_000_000);

const signature = await keypair.signTransaction(await tx.build({ client }));
const result = await client.executeTransactionBlock({
  transactionBlock: await tx.build({ client }),
  signature: signature.signature,
  options: { showEffects: true, showObjectChanges: true },
});

console.log('📦 Package Published!');
console.log('📤 Digest:', result.digest);
const published = result.objectChanges?.find((c) => c.type === 'published');
console.log('📦 Package ID:', published?.packageId);
console.log('🔍 View on SuiScan:', `https://suiscan.xyz/devnet/object/${published?.packageId}`);
console.log(result);

const coinMetadataID = result.objectChanges?.find(
  (c) => c.type === 'created' && isCoinMetadata(c.objectType)
)?.objectId;
console.log('Coin Metadata:', coinMetadataID);
console.log('🔍 View on SuiScan:', `https://suiscan.xyz/devnet/object/${coinMetadataID}`);

const treasuryCapID = result.objectChanges?.find(
  (c) => c.type === 'created' && isTreasuryCap(c.objectType)
)?.objectId;
console.log('Treasury Cap:', treasuryCapID);
console.log('🔍 View on SuiScan:', `https://suiscan.xyz/devnet/object/${treasuryCapID}`);

