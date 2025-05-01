import { Ed25519Keypair } from '@mysten/sui.js/keypairs/ed25519';
import { getFaucetHost } from '@mysten/sui.js/faucet';
import { getFullnodeUrl } from '@mysten/sui.js/client';
import { SuiClient } from '@mysten/sui.js/client';
import { TransactionBlock } from '@mysten/sui.js/transactions';

// Base64 encoded bytecode
const bytecode = {
  modules: [
    'oRzrCwYAAAAKAQAMAgweAyocBEYIBU5GB5QBqwEIvwJgBp8DMArPAwUM1AMpAAsBDAIGAg8CEAIRAAECAAECBwEAAAIADAEAAQIDDAEAAQQEAgAFBQcAAAkAAQABCgEEAQACBwYHAQIDDQsBAQwEDggJAAEDAgUDCgMCAggABwgEAAELAgEIAAEIBQELAQEJAAEIAAcJAAIKAgoCCgILAQEIBQcIBAILAwEJAAsCAQkAAQYIBAEFAQsDAQgAAgkABQxDb2luTWV0YWRhdGENT09aRV9GQU1fQ09JTgZPcHRpb24LVHJlYXN1cnlDYXAJVHhDb250ZXh0A1VybARjb2luD2NyZWF0ZV9jdXJyZW5jeQtkdW1teV9maWVsZARpbml0BG5vbmUNb296ZV9mYW1fY29pbgZvcHRpb24PcHVibGljX3RyYW5zZmVyBnNlbmRlcgh0cmFuc2Zlcgp0eF9jb250ZXh0A3VybAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgIBBgoCCwpUQkRfU1lNQk9MCgIJCFRCRF9OQU1FCgIQD1RCRF9ERVNDUklQVElPTgACAQgBAAAAAAITCwAHAAcBBwIHAzgACgE4AQwCCgEuEQQ4AgsCCwEuEQQ4AwIA',
  ],
  dependencies: ['0x1', '0x2'],
} as const;

// Convert Base64 to array of numbers
const toBytes = (b64: string) => {
  const binary = atob(b64);
  return Array.from(binary).map((c) => c.charCodeAt(0));
};

// Setup
const keypair = Ed25519Keypair.generate();
const address = keypair.getPublicKey().toSuiAddress();
console.log('🔑 Address:', address);

const client = new SuiClient({ url: getFullnodeUrl('devnet') });

// Request SUI from faucet
console.log('⛲ Requesting SUI from faucet...');
const faucetUrl = `${getFaucetHost('devnet')}/v2/gas`;
const faucetResponse = await fetch(faucetUrl, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    FixedAmountRequest: {
      recipient: address,
    },
  }),
});

if (!faucetResponse.ok) {
  throw new Error(`Faucet request failed with status ${faucetResponse.status}`);
}

const faucetData = await faucetResponse.json();
console.log('Faucet response:', JSON.stringify(faucetData, null, 2));

if (!faucetData.coins_sent || faucetData.coins_sent.length === 0) {
  throw new Error('Failed to get gas objects from faucet response');
}

await client.waitForTransactionBlock({ digest: faucetData.coins_sent[0].transferTxDigest });
console.log('✅ Faucet funded');

// Build transaction
const tx = new TransactionBlock();
tx.setSender(address);
const modules = bytecode.modules.map(toBytes);
const dependencies = [...bytecode.dependencies];

const [upgradeCap] = tx.publish({ modules, dependencies });
tx.transferObjects([upgradeCap], address);

tx.setGasBudget(1_000_000_000);

// Execute
const signature = await keypair.signTransactionBlock(await tx.build({ client }));
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
