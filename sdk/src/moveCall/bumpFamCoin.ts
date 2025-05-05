import { Transaction } from '@mysten/sui/transactions';
import { createCoin } from '@/suigen/bump_fam_factory/bump-fam-factory/functions';
import { publish } from '@/suiClientUtils';
import { BUMP_FAM_COIN_MOVE_BYTECODE } from '@/moveBytecodes/bumpFamCoin';
import { newUnsafe } from '@/suigen/sui/url/functions';

export class BumpFamCoin {
  static publishBumpFamCoinPackage(
    tx: Transaction,
    args: {
      sender: string;
    }
  ) {
    publish(tx, {
      moveBytecode: BUMP_FAM_COIN_MOVE_BYTECODE,
      sender: args.sender,
    });
  }

  static createCoin(
    tx: Transaction,
    typeArg: string,
    args: {
      treasuryCapID: string;
      coinMetadataID: string;
      name: string;
      symbol: string;
      description: string;
      iconUrl: string | null;
    }
  ) {
    createCoin(tx, typeArg, {
      treasuryCap: args.treasuryCapID,
      coinMetadata: args.coinMetadataID,
      string1: args.name,
      string2: args.symbol,
      string3: args.description,
      url: newUnsafe(tx, args.iconUrl ?? ''),
    });
  }
}