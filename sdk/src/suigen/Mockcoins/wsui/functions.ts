import { PUBLISHED_AT } from '..';
import { obj, pure } from '../../_framework/util';
import { Transaction, TransactionArgument, TransactionObjectInput } from '@mysten/sui/transactions';

export function init(tx: Transaction, wsui: TransactionObjectInput) {
  return tx.moveCall({ target: `${PUBLISHED_AT}::wsui::init`, arguments: [obj(tx, wsui)] });
}

export interface MintArgs {
  treasuryCap: TransactionObjectInput;
  u64: bigint | TransactionArgument;
}

export function mint(tx: Transaction, args: MintArgs) {
  return tx.moveCall({
    target: `${PUBLISHED_AT}::wsui::mint`,
    arguments: [obj(tx, args.treasuryCap), pure(tx, args.u64, `u64`)],
  });
}
