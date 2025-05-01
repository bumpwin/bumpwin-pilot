module battle_market::root;

use sui::clock::Clock;

const ROUND_CYCLE_HOURS: u64 = 25; // 25 hours
const GENESIS_TIMESTAMP_MS: u64 = 1748736000000; // 2025-06-01 00:00:00+00:00

const EInvalidRoundStart: u64 = 0;

public struct Root has key, store {
    id: UID,
    round_cycle_hours: u64,
    current_round_number: u64, // 1-indexed
    genesis_timestamp_ms: u64,
    round_list: vector<ID>,
}

fun init(ctx: &mut TxContext) {
    let root = Root {
        id: object::new(ctx),
        round_cycle_hours: ROUND_CYCLE_HOURS,
        genesis_timestamp_ms: GENESIS_TIMESTAMP_MS,
        current_round_number: 1,
        round_list: vector[],
    };
    transfer::public_share_object(root);
}

public fun current_round_number(root: &Root): u64 {
    root.current_round_number
}

public fun nth_round_start_timestamp_ms(root: &Root, round_number: u64): u64 {
    let cycle_ms = root.round_cycle_hours * 60 * 60 * 1000;
    root.genesis_timestamp_ms + (round_number - 1) * cycle_ms
}

public fun nth_round_end_timestamp_ms(root: &Root, round_number: u64): u64 {
    nth_round_start_timestamp_ms(root, round_number) + root.round_cycle_hours * 60 * 60 * 1000
}

public fun current_round_start_timestamp_ms(root: &Root): u64 {
    nth_round_start_timestamp_ms(root, root.current_round_number)
}

public fun current_round_end_timestamp_ms(root: &Root): u64 {
    nth_round_end_timestamp_ms(root, root.current_round_number)
}

public fun start_new_round(
    root: &mut Root,
    round_id: ID,
    clock: &Clock,
) {
    let now_ms = clock.timestamp_ms();
    let expected_start = nth_round_start_timestamp_ms(root, root.current_round_number + 1);
    assert!(now_ms >= expected_start, EInvalidRoundStart);

    vector::push_back(&mut root.round_list, round_id);
    root.current_round_number = root.current_round_number + 1;
}

#[test_only]
public fun init_for_testing(ctx: &mut TxContext): Root {
    Root {
        id: object::new(ctx),
        round_cycle_hours: ROUND_CYCLE_HOURS,
        genesis_timestamp_ms: GENESIS_TIMESTAMP_MS,
        current_round_number: 1,
        round_list: vector[],
    }
}