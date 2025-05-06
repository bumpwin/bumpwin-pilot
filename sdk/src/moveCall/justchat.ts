import { Transaction } from '@mysten/sui/transactions';
import { sendMessage } from '@/suigen/justchat/messaging/functions';

const FEE_CAP_ID = {
  mainnet: 'NOT_IMPLEMENTED',
  testnet: '0x3d1a7fc56ef71efcf98b6339b758343eaa5641e18fc43b1ad5cc4519d633edd6',
} as const;

export class Justchat {
  private feeCapId: string;

  constructor(private network: 'mainnet' | 'testnet') {
    this.feeCapId = FEE_CAP_ID[network];
  }

  sendMessage(
    tx: Transaction,
    args: {
      message: string;
      sender: string;
    }
  ) {
    const [coin] = tx.splitCoins(tx.gas, [tx.pure.u64(1000)]);
    const toKeep = sendMessage(tx, {
      messageFeeCap: this.feeCapId,
      string: args.message,
      coin,
    });
    tx.transferObjects([toKeep], args.sender);
  }
}
