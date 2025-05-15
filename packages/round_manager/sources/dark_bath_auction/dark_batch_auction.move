
module round_manager::dark_batch_tx_board;

use sui::table::Table;

public struct DarkBatchTxBoard has key, store {
    id: UID,
    table: Table<address, DarkBatchTx>,
}

public struct DarkBatchTx has store {
    id: UID,
    address: address,
    amount: u64,
}
