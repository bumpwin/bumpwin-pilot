module round_manager::dark_batch_tx_board;

use sui::table::Table;

#[allow(unused_field)]
public struct DarkBatchTxBoard has key, store {
    id: UID,
    table: Table<address, DarkBatchTx>,
}

public struct SwitchTx has store {
    id: ID,
    signer: address,
    amount: u64,
}


public fun commit_tle_tx(self: &mut DarkBatchTxBoard, tx: DarkBatchTx) {
    board.table.add(tx.address, tx);
}

public fun commit_txs(board: &mut DarkBatchTxBoard, txs: vector<DarkBatchTx>) {
    board.table.add(txs);
}

public entry fun seal_approve(encoded_data: vector<u8>, clock: &Clock) {
    let mut decoder = bcs::new(encoded_data);
    let time_to_reveal = decoder.peel_u64();
    let leftovers = decoder.into_remainder_bytes();
    assert!(clock.timestamp_ms() >= time_to_reveal, ENoAccess);
    assert!(leftovers.length() == 0, ENoAccess);
}
