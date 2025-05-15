import { PUBLISHED_AT } from '..';
import { obj, pure } from '../../_framework/util';
import { Transaction, TransactionArgument, TransactionObjectInput } from '@mysten/sui/transactions';

export function shareCounter(tx: Transaction) {
  return tx.moveCall({ target: `${PUBLISHED_AT}::tle_counter::share_counter`, arguments: [] });
}

export function increment(tx: Transaction, counter: TransactionObjectInput) {
  return tx.moveCall({
    target: `${PUBLISHED_AT}::tle_counter::increment`,
    arguments: [obj(tx, counter)],
  });
}

export interface AddArgs {
  counter: TransactionObjectInput;
  u64: bigint | TransactionArgument;
}

export function add(tx: Transaction, args: AddArgs) {
  return tx.moveCall({
    target: `${PUBLISHED_AT}::tle_counter::add`,
    arguments: [obj(tx, args.counter), pure(tx, args.u64, `u64`)],
  });
}

export interface SealApproveArgs {
  vecU8: Array<number | TransactionArgument> | TransactionArgument;
  clock: TransactionObjectInput;
}

export function sealApprove(tx: Transaction, args: SealApproveArgs) {
  return tx.moveCall({
    target: `${PUBLISHED_AT}::tle_counter::seal_approve`,
    arguments: [pure(tx, args.vecU8, `vector<u8>`), obj(tx, args.clock)],
  });
}
