import {PUBLISHED_AT} from "..";
import {ID} from "../../_dependencies/onchain/0x2/object/structs";
import {obj, pure} from "../../_framework/util";
import {Transaction, TransactionArgument, TransactionObjectInput} from "@mysten/sui/transactions";

export function shareRoot( tx: Transaction, ) { return tx.moveCall({ target: `${PUBLISHED_AT}::object_table_counter::share_root`, arguments: [ ], }) }

export function createCounter( tx: Transaction, root: TransactionObjectInput ) { return tx.moveCall({ target: `${PUBLISHED_AT}::object_table_counter::create_counter`, arguments: [ obj(tx, root) ], }) }

export function createCounterWithEvent( tx: Transaction, root: TransactionObjectInput ) { return tx.moveCall({ target: `${PUBLISHED_AT}::object_table_counter::create_counter_with_event`, arguments: [ obj(tx, root) ], }) }

export interface BorrowMutCounterArgs { root: TransactionObjectInput; id: string | TransactionArgument }

export function borrowMutCounter( tx: Transaction, args: BorrowMutCounterArgs ) { return tx.moveCall({ target: `${PUBLISHED_AT}::object_table_counter::borrow_mut_counter`, arguments: [ obj(tx, args.root), pure(tx, args.id, `${ID.$typeName}`) ], }) }

export interface IncrementArgs { root: TransactionObjectInput; id: string | TransactionArgument }

export function increment( tx: Transaction, args: IncrementArgs ) { return tx.moveCall({ target: `${PUBLISHED_AT}::object_table_counter::increment`, arguments: [ obj(tx, args.root), pure(tx, args.id, `${ID.$typeName}`) ], }) }

export interface IncrementWithEventArgs { root: TransactionObjectInput; id: string | TransactionArgument }

export function incrementWithEvent( tx: Transaction, args: IncrementWithEventArgs ) { return tx.moveCall({ target: `${PUBLISHED_AT}::object_table_counter::increment_with_event`, arguments: [ obj(tx, args.root), pure(tx, args.id, `${ID.$typeName}`) ], }) }
