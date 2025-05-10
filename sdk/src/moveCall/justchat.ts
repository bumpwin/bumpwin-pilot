import { sendMessage } from '@/suigen/justchat/messaging/functions';
import type { Transaction } from '@mysten/sui/transactions';

// Fee cap IDs for different networks
const FEE_CAP_ID = {
  mainnet: 'NOT_IMPLEMENTED',
  testnet: '0xd5c0f61d9c02a72ce8af482d1dcb9e47ead607d9ae23904ebb0c1696852e684f',
  devnet: '0x0c55735e02c5c28f0fff19711e7377b302f44ed0bbb2924ebe7b9bc6d6bebe6c',
} as const;

// Message fee amount
const MESSAGE_FEE = 1000;

/**
 * Justchat class for sending messages on Sui blockchain
 */
export class Justchat {
  private feeCapId: string;

  /**
   * Initialize Justchat with the specified network
   * @param network Network to use (mainnet, testnet, or devnet)
   */
  constructor(private network: 'mainnet' | 'testnet' | 'devnet') {
    this.feeCapId = FEE_CAP_ID[network];
  }

  /**
   * Send a message on the Sui blockchain
   * @param tx Transaction object
   * @param args Message arguments
   */
  sendMessage(
    tx: Transaction,
    args: {
      message: string;
      sender: string;
    }
  ) {
    // Split coins for the message fee
    const [coin] = tx.splitCoins(tx.gas, [tx.pure.u64(MESSAGE_FEE)]);

    // Call sendMessage function
    sendMessage(tx, {
      messageFeeCap: this.feeCapId,
      string: args.message,
      coin,
    });
  }
}
