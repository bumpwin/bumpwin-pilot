import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { Ed25519Keypair } from '@mysten/sui/keypairs/ed25519';

interface KeyAlias {
  alias: string;
  public_key_base64: string;
}

interface KeyInfo {
  address: string;
  publicKey: string;
  privateKey: string;
  keypair: Ed25519Keypair;
}

export const getKeyInfoFromAlias = (alias: string): KeyInfo | null => {
  // Read keystore and aliases files
  const configDir = join(process.env.HOME || '', '.sui', 'sui_config');
  const keystorePath = join(configDir, 'sui.keystore');
  const aliasesPath = join(configDir, 'sui.aliases');

  const keystoreContent = readFileSync(keystorePath, 'utf-8');
  const aliasesContent = readFileSync(aliasesPath, 'utf-8');

  const keystore = JSON.parse(keystoreContent);
  const aliases: KeyAlias[] = JSON.parse(aliasesContent);

  // Find the alias
  const keyAlias = aliases.find((a) => a.alias === alias);
  if (!keyAlias) {
    console.error(`❌ Alias "${alias}" not found`);
    return null;
  }

  // Remove the first byte from the alias public key
  const pubKeyBytes = Buffer.from(keyAlias.public_key_base64, 'base64');
  const pubKey = Buffer.from(pubKeyBytes.slice(1)).toString('base64');

  // Find matching key in keystore
  const keyIndex = keystore.findIndex((key: string) => {
    const secretKeyBytes = Buffer.from(key, 'base64');
    const ed25519SecretKey = secretKeyBytes.slice(1);
    const keypair = Ed25519Keypair.fromSecretKey(ed25519SecretKey);
    return keypair.getPublicKey().toBase64() === pubKey;
  });

  if (keyIndex === -1) {
    console.error(`❌ Key for alias "${alias}" not found in keystore`);
    return null;
  }

  // Get the keypair
  const secretKeyBytes = Buffer.from(keystore[keyIndex], 'base64');
  const ed25519SecretKey = secretKeyBytes.slice(1);
  const keypair = Ed25519Keypair.fromSecretKey(ed25519SecretKey);
  const address = keypair.getPublicKey().toSuiAddress();

  return {
    address,
    publicKey: keyAlias.public_key_base64,
    privateKey: keystore[keyIndex],
    keypair,
  };
};
