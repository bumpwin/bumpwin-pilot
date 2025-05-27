import {PUBLISHED_AT} from "..";
import {pure} from "../../_framework/util";
import {Transaction, TransactionArgument} from "@mysten/sui/transactions";

export interface CostArgs { u641: bigint | TransactionArgument; u128: bigint | TransactionArgument; u642: bigint | TransactionArgument }

export function cost( tx: Transaction, args: CostArgs ) { return tx.moveCall({ target: `${PUBLISHED_AT}::market_math::cost`, arguments: [ pure(tx, args.u641, `u64`), pure(tx, args.u128, `u128`), pure(tx, args.u642, `u64`) ], }) }

export interface PriceArgs { u641: bigint | TransactionArgument; u642: bigint | TransactionArgument }

export function price( tx: Transaction, args: PriceArgs ) { return tx.moveCall({ target: `${PUBLISHED_AT}::market_math::price`, arguments: [ pure(tx, args.u641, `u64`), pure(tx, args.u642, `u64`) ], }) }

export interface SwapRateZToXiArgs { u641: bigint | TransactionArgument; u128: bigint | TransactionArgument; u642: bigint | TransactionArgument; u643: bigint | TransactionArgument }

export function swapRateZToXi( tx: Transaction, args: SwapRateZToXiArgs ) { return tx.moveCall({ target: `${PUBLISHED_AT}::market_math::swap_rate_z_to_xi`, arguments: [ pure(tx, args.u641, `u64`), pure(tx, args.u128, `u128`), pure(tx, args.u642, `u64`), pure(tx, args.u643, `u64`) ], }) }

export interface SwapRateXiToZArgs { u641: bigint | TransactionArgument; u128: bigint | TransactionArgument; u642: bigint | TransactionArgument; u643: bigint | TransactionArgument }

export function swapRateXiToZ( tx: Transaction, args: SwapRateXiToZArgs ) { return tx.moveCall({ target: `${PUBLISHED_AT}::market_math::swap_rate_xi_to_z`, arguments: [ pure(tx, args.u641, `u64`), pure(tx, args.u128, `u128`), pure(tx, args.u642, `u64`), pure(tx, args.u643, `u64`) ], }) }
