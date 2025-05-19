import { PUBLISHED_AT } from '..';
import { obj } from '../../_framework/util';
import { Transaction, TransactionObjectInput } from '@mysten/sui/transactions';

export function init(tx: Transaction) {
  return tx.moveCall({ target: `${PUBLISHED_AT}::root::init`, arguments: [] });
}

export interface CreatePoolArgs {
  root: TransactionObjectInput;
  coin1: TransactionObjectInput;
  coin2: TransactionObjectInput;
}

export function createPool(tx: Transaction, typeArgs: [string, string], args: CreatePoolArgs) {
  return tx.moveCall({
    target: `${PUBLISHED_AT}::root::create_pool`,
    typeArguments: typeArgs,
    arguments: [obj(tx, args.root), obj(tx, args.coin1), obj(tx, args.coin2)],
  });
}
