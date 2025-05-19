import { PUBLISHED_AT } from '..';
import { obj, pure } from '../../_framework/util';
import { Transaction, TransactionArgument, TransactionObjectInput } from '@mysten/sui/transactions';

export function init(tx: Transaction, yellow: TransactionObjectInput) {
  return tx.moveCall({ target: `${PUBLISHED_AT}::yellow::init`, arguments: [obj(tx, yellow)] });
}

export interface MintArgs {
  treasuryCap: TransactionObjectInput;
  u64: bigint | TransactionArgument;
}

export function mint(tx: Transaction, args: MintArgs) {
  return tx.moveCall({
    target: `${PUBLISHED_AT}::yellow::mint`,
    arguments: [obj(tx, args.treasuryCap), pure(tx, args.u64, `u64`)],
  });
}
