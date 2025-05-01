import { PUBLISHED_AT } from '..';
import { String as String1 } from '../../_dependencies/onchain/0x1/ascii/structs';
import { String } from '../../_dependencies/onchain/0x1/string/structs';
import { obj, pure } from '../../_framework/util';
import { Transaction, TransactionArgument, TransactionObjectInput } from '@mysten/sui/transactions';

export function new_(tx: Transaction, typeArg: string) {
  return tx.moveCall({
    target: `${PUBLISHED_AT}::ooze_fam_factory::new`,
    typeArguments: [typeArg],
    arguments: [],
  });
}

export interface DepositArgs {
  oozeFamVault: TransactionObjectInput;
  balance: TransactionObjectInput;
}

export function deposit(tx: Transaction, typeArg: string, args: DepositArgs) {
  return tx.moveCall({
    target: `${PUBLISHED_AT}::ooze_fam_factory::deposit`,
    typeArguments: [typeArg],
    arguments: [obj(tx, args.oozeFamVault), obj(tx, args.balance)],
  });
}

export interface CreateCoinArgs {
  treasuryCap: TransactionObjectInput;
  coinMetadata: TransactionObjectInput;
  string1: string | TransactionArgument;
  string2: string | TransactionArgument;
  string3: string | TransactionArgument;
  url: TransactionObjectInput;
}

export function createCoin(tx: Transaction, typeArg: string, args: CreateCoinArgs) {
  return tx.moveCall({
    target: `${PUBLISHED_AT}::ooze_fam_factory::create_coin`,
    typeArguments: [typeArg],
    arguments: [
      obj(tx, args.treasuryCap),
      obj(tx, args.coinMetadata),
      pure(tx, args.string1, `${String.$typeName}`),
      pure(tx, args.string2, `${String1.$typeName}`),
      pure(tx, args.string3, `${String.$typeName}`),
      obj(tx, args.url),
    ],
  });
}

export interface UpdateMetadataArgs {
  treasuryCap: TransactionObjectInput;
  coinMetadata: TransactionObjectInput;
  string1: string | TransactionArgument;
  string2: string | TransactionArgument;
  string3: string | TransactionArgument;
  url: TransactionObjectInput;
}

export function updateMetadata(tx: Transaction, typeArg: string, args: UpdateMetadataArgs) {
  return tx.moveCall({
    target: `${PUBLISHED_AT}::ooze_fam_factory::update_metadata`,
    typeArguments: [typeArg],
    arguments: [
      obj(tx, args.treasuryCap),
      obj(tx, args.coinMetadata),
      pure(tx, args.string1, `${String.$typeName}`),
      pure(tx, args.string2, `${String1.$typeName}`),
      pure(tx, args.string3, `${String.$typeName}`),
      obj(tx, args.url),
    ],
  });
}
