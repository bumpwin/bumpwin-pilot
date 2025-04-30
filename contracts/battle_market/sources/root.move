module battle_market::root;

use sui::object::{Self, UID};
use sui::table::{Self, Table};
use sui::clock::{Self, Clock};

const EInvalidRoundStart: u64 = 0;

public struct Root has key, store {
    id: UID,
    round_sycle_hours: u64,
    current_round_number: u64,
    genesis_timestamp_ms: u64,
    round_list: vector<ID>,
}

fun init(ctx: &mut TxContext) {
    let root = Root {
        id: object::new(ctx),
        round_sycle_hours: 25,
        current_round_number: 0,
        genesis_timestamp_ms: 1748736000000, // 2025-06-01 00:00:00+00:00
        round_list: vector[],
    };

    transfer::public_share_object(root);
}

public fun current_round_number(root: &Root): u64 {
    root.current_round_number
}

public fun start_new_round(
    root: &mut Root,
    round_id: ID,
    clock: &Clock,
) {
    let now_ms = clock.timestamp_ms();
    let cycle_ms = root.round_sycle_hours * 60 * 60 * 1000;
    let expected_round_start = root.genesis_timestamp_ms + (root.current_round_number + 1) * cycle_ms;

    assert!(now_ms >= expected_round_start, EInvalidRoundStart);

    vector::push_back(&mut root.round_list, round_id);
    root.current_round_number = root.current_round_number + 1;
}
