import { mint as mintRed } from '@/suigen/mockcoins/red/functions';
import { mint as mintGreen } from '@/suigen/mockcoins/green/functions';
import { mint as mintBlue } from '@/suigen/mockcoins/blue/functions';
import { mint as mintWsui } from '@/suigen/mockcoins/wsui/functions';
import { mint as mintBlack } from '@/suigen/mockcoins/black/functions';
import { mint as mintWhite } from '@/suigen/mockcoins/white/functions';
import { mint as mintBrown } from '@/suigen/mockcoins/brown/functions';
import { mint as mintYellow } from '@/suigen/mockcoins/yellow/functions';
import { mint as mintPink } from '@/suigen/mockcoins/pink/functions';
import { mint as mintCyan } from '@/suigen/mockcoins/cyan/functions';

import type { Transaction, TransactionResult } from '@mysten/sui/transactions';

export class Red {
  private treasuryCapId: string;
  private coinMetadataId: string;

  constructor(private network: 'testnet') {
    this.treasuryCapId = {
      testnet: '0x362a2f38e8ee0a819cc5dcc2df695193842816dd462592713d7db78b6f750c06',
    }[network];
    this.coinMetadataId = {
      testnet: '0x22b08a4658e54e464efea97cd17bdb7295bbf5a430c78c66892160560123d7d6',
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
      testnet: '0x8788a4be46ae51cf14f7493c7c63c4441a9921a133d36bc1c3744749aeb87de0',
    }[network];
    this.coinMetadataId = {
      testnet: '0xf94955a8e84ef11059abcee0215fddd5d63b7fc9c1a922ef413f0798d75475fa',
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
      testnet: '0x72b9ca034bfcf9e1cea52e33989426feaea931885cef9bb1c8ae497fa1f406a2',
    }[network];
    this.coinMetadataId = {
      testnet: '0x869ac318447f656c42808b75d0841dc2dbee12c7239197b9dca9bdb40fb40939',
    }[network];
  }

  public mint = (tx: Transaction, args: { amount: bigint }): TransactionResult => {
    return mintBlue(tx, {
      treasuryCap: this.treasuryCapId,
      u64: args.amount,
    });
  };
}

export class Wsui {
  private treasuryCapId: string;
  private coinMetadataId: string;

  constructor(private network: 'testnet') {
    this.treasuryCapId = {
      testnet: '0x123138fa142d91d170cb4668814a7792691b1de0dc2b4df5b42c82d2d1e2b195',
    }[network];
    this.coinMetadataId = {
      testnet: '0xb3bcffe58d333ac2040ca6676fdc7df9de0d3e40304d2ec73618c9483e97458d',
    }[network];
  }

  public mint = (tx: Transaction, args: { amount: bigint }): TransactionResult => {
    return mintWsui(tx, {
      treasuryCap: this.treasuryCapId,
      u64: args.amount,
    });
  };
}

export class Black {
  private treasuryCapId: string;
  private coinMetadataId: string;

  constructor(private network: 'testnet') {
    this.treasuryCapId = {
      testnet: '0xdc694ad5f14e2a3c55d538ccd2008270ae663e2f285a6ae01f535afeaba5a17b',
    }[network];
    this.coinMetadataId = {
      testnet: '0x0a7eca4767366cfb1ca4d091e1b1d554f5fe243d007c9b1df6d4b1106d2659e8',
    }[network];
  }

  public mint = (tx: Transaction, args: { amount: bigint }): TransactionResult => {
    return mintBlack(tx, {
      treasuryCap: this.treasuryCapId,
      u64: args.amount,
    });
  };
}

export class White {
  private treasuryCapId: string;
  private coinMetadataId: string;

  constructor(private network: 'testnet') {
    this.treasuryCapId = {
      testnet: '0x69ca35e30d038feb27b36f9e49b75a084f137f261f31562544bf4f2d2cbfd193',
    }[network];
    this.coinMetadataId = {
      testnet: '0xffdebcfbbf252f31f8748ad9c57762c95f76d4420c227d7f96219ff2520a5e33',
    }[network];
  }

  public mint = (tx: Transaction, args: { amount: bigint }): TransactionResult => {
    return mintWhite(tx, {
      treasuryCap: this.treasuryCapId,
      u64: args.amount,
    });
  };
}

export class Brown {
  private treasuryCapId: string;
  private coinMetadataId: string;

  constructor(private network: 'testnet') {
    this.treasuryCapId = {
      testnet: '0x57b0f2df93cfee987229bc30a8fa88c913307c5d0d50486833368d955844d8df',
    }[network];
    this.coinMetadataId = {
      testnet: '0x700719a36e3c0150f0be68edf8f0728392830f7332e04b58d9c0085a4cce5e48',
    }[network];
  }

  public mint = (tx: Transaction, args: { amount: bigint }): TransactionResult => {
    return mintBrown(tx, {
      treasuryCap: this.treasuryCapId,
      u64: args.amount,
    });
  };
}

export class Yellow {
  private treasuryCapId: string;
  private coinMetadataId: string;

  constructor(private network: 'testnet') {
    this.treasuryCapId = {
      testnet: '0x0de2c264caa8f6c75aa3acd4844b2310c658ca77ab6a6cb0df6203396d294d32',
    }[network];
    this.coinMetadataId = {
      testnet: '0xe68645d0aa27d9c451af1cc00baba70469539fc7e6c3772f2d164050a04cbd1b',
    }[network];
  }

  public mint = (tx: Transaction, args: { amount: bigint }): TransactionResult => {
    return mintYellow(tx, {
      treasuryCap: this.treasuryCapId,
      u64: args.amount,
    });
  };
}

export class Pink {
  private treasuryCapId: string;
  private coinMetadataId: string;

  constructor(private network: 'testnet') {
    this.treasuryCapId = {
      testnet: '0x90fd61b8dffab3e74baa43e0d56159f697466c76a492cf6e6639b0a83a86db3f',
    }[network];
    this.coinMetadataId = {
      testnet: '0x26a7b3b1b09bf55c030b25c90cacc175a2c2ad3b0efc859dd0a89408bca46403',
    }[network];
  }

  public mint = (tx: Transaction, args: { amount: bigint }): TransactionResult => {
    return mintPink(tx, {
      treasuryCap: this.treasuryCapId,
      u64: args.amount,
    });
  };
}

export class Cyan {
  private treasuryCapId: string;
  private coinMetadataId: string;

  constructor(private network: 'testnet') {
    this.treasuryCapId = {
      testnet: '0xe180b36af69834d65724b1ff755f08cc596d015a2fcd2be4554893d61ec7a373',
    }[network];
    this.coinMetadataId = {
      testnet: '0x97d482710545df12cff0ec5016775d5e39bd125b7a4eb8ca9c35d5d64a2ca73e',
    }[network];
  }

  public mint = (tx: Transaction, args: { amount: bigint }): TransactionResult => {
    return mintCyan(tx, {
      treasuryCap: this.treasuryCapId,
      u64: args.amount,
    });
  };
}
