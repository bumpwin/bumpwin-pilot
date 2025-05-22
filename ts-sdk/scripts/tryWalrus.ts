import { getFullnodeUrl } from '@mysten/sui/client';
import { SuiClient } from '@mysten/sui/client';
import { Ed25519Keypair } from '@mysten/sui/keypairs/ed25519';
import { Transaction } from '@mysten/sui/transactions';
import { WalrusClient } from '@mysten/walrus';
import { faucetDevnet } from '../src/suiClientUtils';

const suiClient = new SuiClient({ url: getFullnodeUrl('testnet') });

// Setup
const keypair = Ed25519Keypair.generate();
const address = keypair.getPublicKey().toSuiAddress();
console.log('🔑 Address:', address);

// Request SUI from faucet
await faucetDevnet(suiClient, address);

const main = async () => {
  const walrusClient = new WalrusClient({
    network: 'testnet',
    suiClient,
  });

  const blobData = new TextEncoder().encode('Hello, Walrus from Testnet!');

  const { blobId } = await walrusClient.writeBlob({
    blob: blobData,
    signer: keypair,
    deletable: false,
    epochs: 3,
  });

  console.log('✅ Uploaded blobId:', blobId);
};

main();
