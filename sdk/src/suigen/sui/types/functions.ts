import type { Transaction } from '@mysten/sui/transactions';
import { PUBLISHED_AT } from '..';
import { type GenericArg, generic } from '../../_framework/util';

export function isOneTimeWitness(tx: Transaction, typeArg: string, t: GenericArg) {
  return tx.moveCall({
    target: `${PUBLISHED_AT}::types::is_one_time_witness`,
    typeArguments: [typeArg],
    arguments: [generic(tx, `${typeArg}`, t)],
  });
}
