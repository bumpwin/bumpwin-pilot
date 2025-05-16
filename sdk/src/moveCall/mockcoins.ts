import { mint as mintRed } from '@/suigen/mockcoins/red/functions';
import { mint as mintGreen } from '@/suigen/mockcoins/green/functions';
import { mint as mintBlue } from '@/suigen/mockcoins/blue/functions';
import type { Transaction, TransactionResult } from '@mysten/sui/transactions';

export class Red {
  private treasuryCapId: string;
  private coinMetadataId: string;

  constructor(private network: 'testnet') {
    this.treasuryCapId = {
      testnet: '0xf2d356f4889d853d46cf11a68f78e7870691af8a27c4803640b05e8b5f9a8000',
    }[network];
    this.coinMetadataId = {
      testnet: '0x978f68d41cadf0494d2ad34b2de182a3872cd32264e6769a16003be944f99380',
    }[network];
  }

  public mint = (tx: Transaction, args: { amount: bigint }): TransactionResult => {
    return mintRed(tx, {
      treasuryCap: this.treasuryCapId,
      u64: args.amount,
    });
  };
}

export class Green {
  private treasuryCapId: string;
  private coinMetadataId: string;

  constructor(private network: 'testnet') {
    this.treasuryCapId = {
      testnet: '0x56f3925b01b5c127e6ae5d6f76fe6a672f6974bf869aafb225221cd76535572f',
    }[network];
    this.coinMetadataId = {
      testnet: '0xecf81d353bada3fb9d45c88322fb14be76854cff2028deb51c46589ad5aca964',
    }[network];
  }

  public mint = (tx: Transaction, args: { amount: bigint }): TransactionResult => {
    return mintGreen(tx, {
      treasuryCap: this.treasuryCapId,
      u64: args.amount,
    });
  };
}

export class Blue {
  private treasuryCapId: string;
  private coinMetadataId: string;

  constructor(private network: 'testnet') {
    this.treasuryCapId = {
      testnet: '0x6acc52f46fcee66b76a4f0f2fcd08d943a6658a9ba906b873487f89150c96f76',
    }[network];
    this.coinMetadataId = {
      testnet: '0x3a9223ab6e93b6f111112736e34cb442ba5655dc07cd65d7c9fc6997ee5a36c3',
    }[network];
  }

  public mint = (tx: Transaction, args: { amount: bigint }): TransactionResult => {
    return mintBlue(tx, {
      treasuryCap: this.treasuryCapId,
      u64: args.amount,
    });
  };
}
