import { TransactionBlock } from '@mysten/sui.js/transactions';
import { MoveBytecode } from './types';

const toBytes = (b64: string) => {
  const binary = atob(b64);
  return Array.from(binary).map((c) => c.charCodeAt(0));
};

export const buildPublishTx = (bytecode: MoveBytecode, sender: string): TransactionBlock => {
  const tx = new TransactionBlock();
  tx.setSender(sender);

  const modules = bytecode.modules.map(toBytes);
  const dependencies = [...bytecode.dependencies];

  const [upgradeCap] = tx.publish({ modules, dependencies });
  tx.transferObjects([upgradeCap], sender);
  tx.setGasBudget(1_000_000_000);

  return tx;
};
