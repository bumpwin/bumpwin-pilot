module counter::sealed_tx_counter;

use sui::bcs;
use sui::clock::Clock;
use sui::table::{Self, Table};

const ENoAccess: u64 = 0;
const EInvalidNonce: u64 = 1;

public struct TxBoard has store {
    nonce_table: Table<address, ID>,
}

public struct Counter has key, store {
    id: UID,
    value: u64,
    tx_board: TxBoard,
}

public entry fun share_counter(ctx: &mut TxContext) {
    let counter = Counter {
        id: object::new(ctx),
        value: 0,
        tx_board: TxBoard {
            nonce_table: table::new(ctx),
        },
    };
    transfer::public_share_object(counter);
}

public entry fun increment(self: &mut Counter): u64 {
    self.value = self.value + 1;
    self.value
}

public fun commit_tx(self: &mut Counter, tx_id: ID, ctx: &mut TxContext) {
    let nonce_table = &mut self.tx_board.nonce_table;

    if (!nonce_table.contains(ctx.sender())) {
        nonce_table.add(ctx.sender(), tx_id);
    } else {
        let nonce = nonce_table.borrow_mut(ctx.sender());
        *nonce = tx_id;
    }
}

public fun borrow_nonce(self: &Counter, singer: address): ID {
    *self.tx_board.nonce_table.borrow(singer)
}

public entry fun add(self: &mut Counter, amount: u64, tx_id: ID, ctx: &mut TxContext): u64 {
    assert!(self.borrow_nonce(ctx.sender()) == tx_id, EInvalidNonce);

    self.value = self.value + amount;
    self.value
}

public entry fun seal_approve(encoded_data: vector<u8>, clock: &Clock) {
    let mut decoder = bcs::new(encoded_data);
    let time_to_reveal = decoder.peel_u64();
    let leftovers = decoder.into_remainder_bytes();
    assert!(clock.timestamp_ms() >= time_to_reveal, ENoAccess);
    assert!(leftovers.length() == 0, ENoAccess);
}
