import {PUBLISHED_AT} from "..";
import {obj, pure} from "../../_framework/util";
import {Transaction, TransactionArgument, TransactionObjectInput} from "@mysten/sui/transactions";

export interface SharePoolArgs { coin1: TransactionObjectInput; coin2: TransactionObjectInput }

export function sharePool( tx: Transaction, typeArgs: [string, string], args: SharePoolArgs ) { return tx.moveCall({ target: `${PUBLISHED_AT}::cpmm::share_pool`, typeArguments: typeArgs, arguments: [ obj(tx, args.coin1), obj(tx, args.coin2) ], }) }

export function reserveAmountX( tx: Transaction, typeArgs: [string, string], pool: TransactionObjectInput ) { return tx.moveCall({ target: `${PUBLISHED_AT}::cpmm::reserve_amount_x`, typeArguments: typeArgs, arguments: [ obj(tx, pool) ], }) }

export function reserveAmountY( tx: Transaction, typeArgs: [string, string], pool: TransactionObjectInput ) { return tx.moveCall({ target: `${PUBLISHED_AT}::cpmm::reserve_amount_y`, typeArguments: typeArgs, arguments: [ obj(tx, pool) ], }) }

export interface ComputeSwapAmountArgs { balance1: TransactionObjectInput; balance2: TransactionObjectInput; u64: bigint | TransactionArgument }

export function computeSwapAmount( tx: Transaction, typeArgs: [string, string], args: ComputeSwapAmountArgs ) { return tx.moveCall({ target: `${PUBLISHED_AT}::cpmm::compute_swap_amount`, typeArguments: typeArgs, arguments: [ obj(tx, args.balance1), obj(tx, args.balance2), pure(tx, args.u64, `u64`) ], }) }

export interface SwapXToYArgs { pool: TransactionObjectInput; coin: TransactionObjectInput }

export function swapXToY( tx: Transaction, typeArgs: [string, string], args: SwapXToYArgs ) { return tx.moveCall({ target: `${PUBLISHED_AT}::cpmm::swap_x_to_y`, typeArguments: typeArgs, arguments: [ obj(tx, args.pool), obj(tx, args.coin) ], }) }

export interface SwapYToXArgs { pool: TransactionObjectInput; coin: TransactionObjectInput }

export function swapYToX( tx: Transaction, typeArgs: [string, string], args: SwapYToXArgs ) { return tx.moveCall({ target: `${PUBLISHED_AT}::cpmm::swap_y_to_x`, typeArguments: typeArgs, arguments: [ obj(tx, args.pool), obj(tx, args.coin) ], }) }
