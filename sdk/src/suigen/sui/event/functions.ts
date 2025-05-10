import type { Transaction } from '@mysten/sui/transactions';
import { PUBLISHED_AT } from '..';
import { type GenericArg, generic } from '../../_framework/util';

export function emit(tx: Transaction, typeArg: string, event: GenericArg) {
  return tx.moveCall({
    target: `${PUBLISHED_AT}::event::emit`,
    typeArguments: [typeArg],
    arguments: [generic(tx, `${typeArg}`, event)],
  });
}
