import { SuiClient, getFullnodeUrl } from '@mysten/sui/client';
import { Transaction } from '@mysten/sui/transactions';
import { getKeyInfoFromAlias } from '../test/keyInfo';
import { Red, Wsui } from '../src/moveCall/mockcoins';
import { object_ids } from '../src';
import { champ_market, mockcoins } from '../src/suigen';

const suiClient = new SuiClient({ url: getFullnodeUrl('testnet') });

const alice = getKeyInfoFromAlias('alice')?.keypair;
if (!alice) throw new Error('Alice keypair not found');

const tx = new Transaction();
tx.setSender(alice.toSuiAddress());
tx.setGasBudget(100_000_000);

// Mint tokens and get their transaction results
const redCoin = new Red('testnet').mint(tx, {
  amount: 500_000_000n * 1_000_000n,
});
const wsuiCoin = new Wsui('testnet').mint(tx, {
  amount: 10_000n * 1_000_000_000n,
});

champ_market.root.createPool(tx, [mockcoins.red.RED.$typeName, mockcoins.wsui.WSUI.$typeName], {
  root: object_ids.CHAMP_MARKET_ROOT_IDS.testnet,
  coin1: redCoin,
  coin2: wsuiCoin,
});

const txBytes = await tx.build({ client: suiClient });
const signature = await alice.signTransaction(txBytes);
const result = await suiClient.executeTransactionBlock({
  transactionBlock: txBytes,
  signature: signature.signature,
  options: { showEffects: true, showObjectChanges: true },
});

console.log(result);
