import { SuiClient, getFullnodeUrl } from '@mysten/sui/client';
import { Transaction } from '@mysten/sui/transactions';
import { getKeyInfoFromAlias } from '../test/keyInfo';
import { mockcoins, champ_market } from '../src/suigen';
import { CHAMP_MARKET_OBJECT_IDS, MOCKCOINS_OBJECT_IDS } from '../src';

const suiClient = new SuiClient({ url: getFullnodeUrl('testnet') });
const alice = getKeyInfoFromAlias('alice')?.keypair;
if (!alice) throw new Error('Alice keypair not found');

const tx = new Transaction();
tx.setSender(alice.toSuiAddress());
tx.setGasBudget(100_000_000);

// Mint tokens and get their transaction results
const redCoin = mockcoins.red.mint(tx, {
  treasuryCap: MOCKCOINS_OBJECT_IDS.TREASURY_CAPS.RED,
  u64: 500_000_000n * 1_000_000n,
});

const wsuiCoin1 = mockcoins.wsui.mint(tx, {
  treasuryCap: MOCKCOINS_OBJECT_IDS.TREASURY_CAPS.WSUI,
  u64: 10_000n * 1_000_000_000n,
});

champ_market.root.createPool(tx, [mockcoins.red.RED.$typeName, mockcoins.wsui.WSUI.$typeName], {
  root: CHAMP_MARKET_OBJECT_IDS.ROOT,
  coin1: redCoin,
  coin2: wsuiCoin1,
});

const blueCoin = mockcoins.blue.mint(tx, {
  treasuryCap: MOCKCOINS_OBJECT_IDS.TREASURY_CAPS.BLUE,
  u64: 500_000_000n * 1_000_000n,
});

const wsuiCoin2 = mockcoins.wsui.mint(tx, {
  treasuryCap: MOCKCOINS_OBJECT_IDS.TREASURY_CAPS.WSUI,
  u64: 10_000n * 1_000_000_000n,
});

champ_market.root.createPool(tx, [mockcoins.blue.BLUE.$typeName, mockcoins.wsui.WSUI.$typeName], {
  root: CHAMP_MARKET_OBJECT_IDS.ROOT,
  coin1: blueCoin,
  coin2: wsuiCoin2,
});

const greenCoin = mockcoins.green.mint(tx, {
  treasuryCap: MOCKCOINS_OBJECT_IDS.TREASURY_CAPS.GREEN,
  u64: 500_000_000n * 1_000_000n,
});

const wsuiCoin3 = mockcoins.wsui.mint(tx, {
  treasuryCap: MOCKCOINS_OBJECT_IDS.TREASURY_CAPS.WSUI,
  u64: 10_000n * 1_000_000_000n,
});

champ_market.root.createPool(tx, [mockcoins.green.GREEN.$typeName, mockcoins.wsui.WSUI.$typeName], {
  root: CHAMP_MARKET_OBJECT_IDS.ROOT,
  coin1: greenCoin,
  coin2: wsuiCoin3,
});

const txBytes = await tx.build({ client: suiClient });
const signature = await alice.signTransaction(txBytes);
const result = await suiClient.executeTransactionBlock({
  transactionBlock: txBytes,
  signature: signature.signature,
  options: { showEffects: true, showObjectChanges: true },
});

console.log(result);
