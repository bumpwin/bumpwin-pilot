import { PUBLISHED_AT } from '..';
import { obj, pure } from '../../_framework/util';
import { Transaction, TransactionArgument, TransactionObjectInput } from '@mysten/sui/transactions';

export function init(tx: Transaction, brown: TransactionObjectInput) {
  return tx.moveCall({ target: `${PUBLISHED_AT}::brown::init`, arguments: [obj(tx, brown)] });
}

export interface MintArgs {
  treasuryCap: TransactionObjectInput;
  u64: bigint | TransactionArgument;
}

export function mint(tx: Transaction, args: MintArgs) {
  return tx.moveCall({
    target: `${PUBLISHED_AT}::brown::mint`,
    arguments: [obj(tx, args.treasuryCap), pure(tx, args.u64, `u64`)],
  });
}
