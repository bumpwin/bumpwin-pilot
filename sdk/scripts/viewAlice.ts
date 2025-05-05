import { readFileSync } from 'fs';
import { join } from 'path';
import { Ed25519Keypair } from '@mysten/sui/keypairs/ed25519';

interface KeyAlias {
  alias: string;
  public_key_base64: string;
}

const main = async () => {
  // Read keystore and aliases files
  const configDir = join(process.env.HOME || '', '.sui', 'sui_config');
  const keystorePath = join(configDir, 'sui.keystore');
  const aliasesPath = join(configDir, 'sui.aliases');

  const keystoreContent = readFileSync(keystorePath, 'utf-8');
  const aliasesContent = readFileSync(aliasesPath, 'utf-8');

  const keystore = JSON.parse(keystoreContent);
  const aliases: KeyAlias[] = JSON.parse(aliasesContent);
  console.log(aliases);

  // Find Alice's public key from aliases
  const aliceAlias = aliases.find(a => a.alias === 'alice');
  console.log(aliceAlias);
  if (!aliceAlias) {
    console.error('❌ Alice\'s alias not found');
    return;
  }

  // Remove the first byte from the alias public key
  const alicePubKeyBytes = Buffer.from(aliceAlias.public_key_base64, 'base64');
  const alicePubKey = Buffer.from(alicePubKeyBytes.slice(1)).toString('base64');

  // Find matching key in keystore
  const aliceKeyIndex = keystore.findIndex((key: string) => {
    const secretKeyBytes = Buffer.from(key, 'base64');
    const ed25519SecretKey = secretKeyBytes.slice(1);
    const keypair = Ed25519Keypair.fromSecretKey(ed25519SecretKey);
    const pubKey = keypair.getPublicKey().toBase64();
    console.log('Comparing:', pubKey, 'with:', alicePubKey);
    return pubKey === alicePubKey;
  });

  if (aliceKeyIndex === -1) {
    console.error('❌ Alice\'s key not found in keystore');
    return;
  }

  // Get Alice's keypair
  const secretKeyBytes = Buffer.from(keystore[aliceKeyIndex], 'base64');
  const ed25519SecretKey = secretKeyBytes.slice(1);
  const aliceKeypair = Ed25519Keypair.fromSecretKey(ed25519SecretKey);
  const address = aliceKeypair.getPublicKey().toSuiAddress();

  console.log('🔑 Alice\'s address:', address);
  console.log('🔑 Alice\'s public key (base64):', aliceAlias.public_key_base64);
  console.log('🔑 Alice\'s private key (base64):', keystore[aliceKeyIndex]);
}

main().catch(console.error);
