import type { Transaction, TransactionArgument } from '@mysten/sui/transactions';
import { PUBLISHED_AT } from '..';
import { pure } from '../../_framework/util';

export function blake2b256(
  tx: Transaction,
  data: Array<number | TransactionArgument> | TransactionArgument
) {
  return tx.moveCall({
    target: `${PUBLISHED_AT}::hash::blake2b256`,
    arguments: [pure(tx, data, `vector<u8>`)],
  });
}

export function keccak256(
  tx: Transaction,
  data: Array<number | TransactionArgument> | TransactionArgument
) {
  return tx.moveCall({
    target: `${PUBLISHED_AT}::hash::keccak256`,
    arguments: [pure(tx, data, `vector<u8>`)],
  });
}
