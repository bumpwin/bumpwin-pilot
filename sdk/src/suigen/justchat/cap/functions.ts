import type {
  Transaction,
  TransactionArgument,
  TransactionObjectInput,
} from '@mysten/sui/transactions';
import { PUBLISHED_AT } from '..';
import { obj, pure } from '../../_framework/util';

export function init(tx: Transaction) {
  return tx.moveCall({ target: `${PUBLISHED_AT}::cap::init`, arguments: [] });
}

export function messageFee(tx: Transaction, messageFeeCap: TransactionObjectInput) {
  return tx.moveCall({
    target: `${PUBLISHED_AT}::cap::message_fee`,
    arguments: [obj(tx, messageFeeCap)],
  });
}

export function recipient(tx: Transaction, messageFeeCap: TransactionObjectInput) {
  return tx.moveCall({
    target: `${PUBLISHED_AT}::cap::recipient`,
    arguments: [obj(tx, messageFeeCap)],
  });
}

export interface SetMessageFeeArgs {
  adminCap: TransactionObjectInput;
  messageFeeCap: TransactionObjectInput;
  u64: bigint | TransactionArgument;
}

export function setMessageFee(tx: Transaction, args: SetMessageFeeArgs) {
  return tx.moveCall({
    target: `${PUBLISHED_AT}::cap::set_message_fee`,
    arguments: [obj(tx, args.adminCap), obj(tx, args.messageFeeCap), pure(tx, args.u64, `u64`)],
  });
}

export interface SetRecipientArgs {
  adminCap: TransactionObjectInput;
  messageFeeCap: TransactionObjectInput;
  address: string | TransactionArgument;
}

export function setRecipient(tx: Transaction, args: SetRecipientArgs) {
  return tx.moveCall({
    target: `${PUBLISHED_AT}::cap::set_recipient`,
    arguments: [
      obj(tx, args.adminCap),
      obj(tx, args.messageFeeCap),
      pure(tx, args.address, `address`),
    ],
  });
}
