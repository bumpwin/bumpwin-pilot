import type { Transaction, TransactionResult, TransactionObjectInput } from '@mysten/sui/transactions';
import { createPool } from '@/suigen/champ_market/root/functions';

type NetworkType = 'testnet' | 'mainnet';

export class ChampMarket {
  private rootId: string;
  private static readonly ROOT_IDS: Partial<Record<NetworkType, string>> = {
    testnet: '0x283fd860da6927ad9ea98ee552db356734fc02126eb4b1264c082d8646dd99d7',
  } as const;

  constructor(private network: NetworkType) {
    const rootId = ChampMarket.ROOT_IDS[network];
    if (!rootId) {
      throw new Error(`Network ${network} not supported`);
    }
    this.rootId = rootId;
  }

  public createPool = (
    tx: Transaction,
    typeArgs: [string, string],
    args: { coin1: TransactionObjectInput; coin2: TransactionObjectInput },
  ): TransactionResult => {
    return createPool(tx, typeArgs, {
      root: this.rootId,
      coin1: args.coin1,
      coin2: args.coin2,
    });
  };
}
