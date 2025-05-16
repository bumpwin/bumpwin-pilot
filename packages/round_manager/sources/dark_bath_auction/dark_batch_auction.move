module round_manager::dark_batch_tx_board;

use sui::table::Table;

#[allow(unused_field)]
public struct DarkBatchTxBoard has key, store {
    id: UID,
    table: Table<address, DarkBatchTx>,
}

#[allow(unused_field, lint(missing_key))]
public struct DarkBatchTx has key, store {
    id: UID,
    address: address,
    amount: u64,
}
