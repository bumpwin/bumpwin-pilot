import { PUBLISHED_AT } from '..';
import { String } from '../../_dependencies/onchain/0x1/string/structs';
import { obj, pure } from '../../_framework/util';
import { Transaction, TransactionArgument, TransactionObjectInput } from '@mysten/sui/transactions';

export interface SendMessageArgs {
  messageFeeCap: TransactionObjectInput;
  string: string | TransactionArgument;
  coin: TransactionObjectInput;
}

export function sendMessage(tx: Transaction, args: SendMessageArgs) {
  return tx.moveCall({
    target: `${PUBLISHED_AT}::messaging::send_message`,
    arguments: [
      obj(tx, args.messageFeeCap),
      pure(tx, args.string, `${String.$typeName}`),
      obj(tx, args.coin),
    ],
  });
}
