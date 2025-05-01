#[test_only]
module battle_market::battle_market_tests;

use sui::test_scenario::{Self as test, ctx};
use sui::clock;
use std::string;
use std::ascii;
use sui::url;

use battle_market::root;
use battle_market::round;

// Test constants
const ALICE: address = @0xA11CE;
const ROUND_CYCLE_HOURS: u64 = 25;
const GENESIS_TIMESTAMP_MS: u64 = 1748736000000;

// Error codes
const ENotImplemented: u64 = 0;

/// Test that root initialization works correctly
#[test]
fun test_root_initialization() {
    let mut scenario = test::begin(@0x1);
    let test = &mut scenario;

    // Step 1: Initialize root
    test.next_tx(ALICE); {
        let root = root::init_for_testing(test.ctx());
        transfer::public_share_object(root);
    };

    // Step 2: Verify root properties
    test.next_tx(ALICE); {
        let root = test.take_shared<root::Root>();
        assert!(root::current_round_number(&root) == 1, 0);
        assert!(root::current_round_start_timestamp_ms(&root) == GENESIS_TIMESTAMP_MS, 1);
        assert!(root::current_round_end_timestamp_ms(&root) == GENESIS_TIMESTAMP_MS + ROUND_CYCLE_HOURS * 60 * 60 * 1000, 2);
        test::return_shared(root);
    };

    test::end(scenario);
}

/// Test that round creation works correctly
#[test]
fun test_round_creation() {
    let mut scenario = test::begin(@0x1);
    let test = &mut scenario;

    clock::create_for_testing(test.ctx()).share_for_testing();

    // Step 1: Initialize root
    test.next_tx(ALICE); {
        let root = root::init_for_testing(test.ctx());
        transfer::public_share_object(root);
    };

    // Step 2: Create a new round
    test.next_tx(ALICE); {
        let mut root = test.take_shared<root::Root>();
        let mut clock = test.take_shared<clock::Clock>();

        // Advance clock time to the next round start time
        let next_round_start = root::nth_round_start_timestamp_ms(&root, 2);
        let current_time = clock::timestamp_ms(&clock);
        let time_to_advance = next_round_start - current_time;
        clock::increment_for_testing(&mut clock, time_to_advance);

        round::new(&mut root, &clock, test.ctx());
        test::return_shared(root);
        test::return_shared(clock);
    };

    test::end(scenario);
}

/// Test that meme registration works correctly
#[test]
fun test_meme_registration() {
    let mut scenario = test::begin(@0x1);
    let test = &mut scenario;

    // Step 1: Initialize round
    test.next_tx(ALICE); {
        let round = round::init_for_testing(test.ctx());
        transfer::public_share_object(round);
    };

    // Step 2: Register a meme
    test.next_tx(ALICE); {
        let mut round = test.take_shared<round::Round>();
        let name = string::utf8(b"Test Meme");
        let symbol = ascii::string(b"TM");
        let description = string::utf8(b"A test meme for battle market");
        let icon_url = url::new_unsafe_from_bytes(b"https://example.com/icon.png");

        round::register_meme(
            &mut round,
            name,
            symbol,
            description,
            icon_url,
            test.ctx()
        );
        test::return_shared(round);
    };

    test::end(scenario);
}

/// Test that battle market fails as expected
#[test, expected_failure(abort_code = ::battle_market::battle_market_tests::ENotImplemented)]
fun test_battle_market_fail() {
    abort ENotImplemented
}
