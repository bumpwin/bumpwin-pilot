import { Transaction } from '@mysten/sui/transactions';
import { createCoin } from '../suigen/ooze_fam_factory/ooze-fam-factory/functions';
import { publish } from '../suiClientUtils';
import { OOZE_FAM_COIN_MOVE_BYTECODE } from '../moveBytecodes/ooze_fam_coin';


export class OozeFamCoin {
  static publishOozeFamCoinPackage(
    tx: Transaction,
    args: {
      sender: string;
    }
  ) {
    publish(tx, {
      moveBytecode: OOZE_FAM_COIN_MOVE_BYTECODE,
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
      url: tx.pure.string(args.iconUrl ?? ''),
    });
  }
}
