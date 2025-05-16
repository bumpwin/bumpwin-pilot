import { PUBLISHED_AT } from '..';
import { obj, pure } from '../../_framework/util';
import { Transaction, TransactionArgument, TransactionObjectInput } from '@mysten/sui/transactions';

export function new_(tx: Transaction, typeArg: string) {
  return tx.moveCall({ target: `${PUBLISHED_AT}::vault::new`, typeArguments: [typeArg], arguments: [] });
}

export interface DepositArgs {
  bumpWinCoinVault: TransactionObjectInput;
  balance: TransactionObjectInput;
}

export function deposit(tx: Transaction, typeArg: string, args: DepositArgs) {
  return tx.moveCall({
    target: `${PUBLISHED_AT}::vault::deposit`,
    typeArguments: [typeArg],
    arguments: [obj(tx, args.bumpWinCoinVault), obj(tx, args.balance)],
  });
}

export interface WithdrawArgs {
  bumpWinCoinVault: TransactionObjectInput;
  u64: bigint | TransactionArgument;
  adminCap: TransactionObjectInput;
}

export function withdraw(tx: Transaction, typeArg: string, args: WithdrawArgs) {
  return tx.moveCall({
    target: `${PUBLISHED_AT}::vault::withdraw`,
    typeArguments: [typeArg],
    arguments: [obj(tx, args.bumpWinCoinVault), pure(tx, args.u64, `u64`), obj(tx, args.adminCap)],
  });
}
