import {PUBLISHED_AT} from "..";
import {obj, pure} from "../../_framework/util";
import {Transaction, TransactionArgument, TransactionObjectInput} from "@mysten/sui/transactions";

export function numOutcomes( tx: Transaction, marketVault: TransactionObjectInput ) { return tx.moveCall({ target: `${PUBLISHED_AT}::market_vault::num_outcomes`, arguments: [ obj(tx, marketVault) ], }) }

export function newSupply( tx: Transaction, typeArg: string, ) { return tx.moveCall({ target: `${PUBLISHED_AT}::market_vault::new_supply`, typeArguments: [typeArg], arguments: [ ], }) }

export function new_( tx: Transaction, ) { return tx.moveCall({ target: `${PUBLISHED_AT}::market_vault::new`, arguments: [ ], }) }

export function registerCoin( tx: Transaction, typeArg: string, marketVault: TransactionObjectInput ) { return tx.moveCall({ target: `${PUBLISHED_AT}::market_vault::register_coin`, typeArguments: [typeArg], arguments: [ obj(tx, marketVault) ], }) }

export interface DepositNumeraireArgs { marketVault: TransactionObjectInput; balance: TransactionObjectInput }

export function depositNumeraire( tx: Transaction, args: DepositNumeraireArgs ) { return tx.moveCall({ target: `${PUBLISHED_AT}::market_vault::deposit_numeraire`, arguments: [ obj(tx, args.marketVault), obj(tx, args.balance) ], }) }

export interface WithdrawNumeraireArgs { marketVault: TransactionObjectInput; u64: bigint | TransactionArgument }

export function withdrawNumeraire( tx: Transaction, args: WithdrawNumeraireArgs ) { return tx.moveCall({ target: `${PUBLISHED_AT}::market_vault::withdraw_numeraire`, arguments: [ obj(tx, args.marketVault), pure(tx, args.u64, `u64`) ], }) }

export interface MintSharesArgs { marketVault: TransactionObjectInput; u64: bigint | TransactionArgument }

export function mintShares( tx: Transaction, typeArg: string, args: MintSharesArgs ) { return tx.moveCall({ target: `${PUBLISHED_AT}::market_vault::mint_shares`, typeArguments: [typeArg], arguments: [ obj(tx, args.marketVault), pure(tx, args.u64, `u64`) ], }) }

export interface BurnSharesArgs { marketVault: TransactionObjectInput; balance: TransactionObjectInput }

export function burnShares( tx: Transaction, typeArg: string, args: BurnSharesArgs ) { return tx.moveCall({ target: `${PUBLISHED_AT}::market_vault::burn_shares`, typeArguments: [typeArg], arguments: [ obj(tx, args.marketVault), obj(tx, args.balance) ], }) }

export function shareSupplyValue( tx: Transaction, typeArg: string, marketVault: TransactionObjectInput ) { return tx.moveCall({ target: `${PUBLISHED_AT}::market_vault::share_supply_value`, typeArguments: [typeArg], arguments: [ obj(tx, marketVault) ], }) }

export function totalShareSupplyValue( tx: Transaction, marketVault: TransactionObjectInput ) { return tx.moveCall({ target: `${PUBLISHED_AT}::market_vault::total_share_supply_value`, arguments: [ obj(tx, marketVault) ], }) }

export interface BuySharesArgs { marketVault: TransactionObjectInput; coin: TransactionObjectInput }

export function buyShares( tx: Transaction, typeArg: string, args: BuySharesArgs ) { return tx.moveCall({ target: `${PUBLISHED_AT}::market_vault::buy_shares`, typeArguments: [typeArg], arguments: [ obj(tx, args.marketVault), obj(tx, args.coin) ], }) }

export interface SellSharesArgs { marketVault: TransactionObjectInput; coin: TransactionObjectInput }

export function sellShares( tx: Transaction, typeArg: string, args: SellSharesArgs ) { return tx.moveCall({ target: `${PUBLISHED_AT}::market_vault::sell_shares`, typeArguments: [typeArg], arguments: [ obj(tx, args.marketVault), obj(tx, args.coin) ], }) }
