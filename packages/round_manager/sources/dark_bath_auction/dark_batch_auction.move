module round_manager::sealed_tx_board;

use sui::bcs;
use sui::clock::Clock;
use sui::table::Table;

const ENoAccess: u64 = 0;
const EInvalidUnlockTimestampMs: u64 = 1;

public struct SealedTxBoard has key, store {
    id: UID,
    tx_table: Table<address, SealedTx>,
    unlock_timestamp_ms: u64,
}

public struct SealedTx has copy, store {
    encrypted_object: vector<u8>,
    nullifier: u256,
    unlock_timestamp_ms: u64,
    signer: address,
}

public fun borrow_sealed_tx(self: &SealedTxBoard, signer: address): Option<SealedTx> {
    if (self.tx_table.contains(signer)) {
        option::some(*self.tx_table.borrow(signer))
    } else {
        option::none()
    }
}

public fun get_nullifier(self: &SealedTxBoard, signer: address): Option<u256> {
    if (self.tx_table.contains(signer)) {
        let sealed_tx = self.tx_table.borrow(signer);
        option::some(sealed_tx.nullifier)
    } else {
        option::none()
    }
}

public fun commit_sealed_tx(
    self: &mut SealedTxBoard,
    encrypted_object: vector<u8>,
    nullifier: u256,
    unlock_timestamp_ms: u64,
    ctx: &TxContext,
) {
    assert!(self.unlock_timestamp_ms == unlock_timestamp_ms, EInvalidUnlockTimestampMs);

    let sealed_tx = SealedTx {
        encrypted_object,
        nullifier,
        unlock_timestamp_ms: self.unlock_timestamp_ms,
        signer: ctx.sender(),
    };
    self.tx_table.add(ctx.sender(), sealed_tx);
}

public entry fun seal_approve(encoded_data: vector<u8>, clock: &Clock) {
    let mut decoder = bcs::new(encoded_data);
    let time_to_reveal = decoder.peel_u64();
    let leftovers = decoder.into_remainder_bytes();
    assert!((clock.timestamp_ms() >= time_to_reveal) && (leftovers.length() == 0), ENoAccess);
}
