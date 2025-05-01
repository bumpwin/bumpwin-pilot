#[test_only]
module e2e_test_cases::mint_ooze_fam_coin;

use std::ascii;
use std::string;
use sui::coin::{Coin, TreasuryCap, CoinMetadata};
use sui::test_scenario::{Self as test, ctx};
use sui::url;
use sui::transfer;

use ooze_fam_factory::ooze_fam_factory;
use ooze_fam_coin::ooze_fam_coin::{Self, OOZE_FAM_COIN};


// Test constants
const ALICE: address = @0xA11CE;
const BOB: address = @0xB0B;


#[test]
fun test_mint_ooze_fam_coin() {
    let mut scenario = test::begin(@0x1);
    let test = &mut scenario;

    // Alice publishes the ooze fam coin contract
    test.next_tx(ALICE); {
        ooze_fam_coin::init_for_testing(test.ctx());
    };

    // Alice creates a new ooze fam coin
    test.next_tx(ALICE); {
        let mut cap = test.take_from_address<TreasuryCap<OOZE_FAM_COIN>>(ALICE);
        let metadata = test.take_from_address<CoinMetadata<OOZE_FAM_COIN>>(ALICE);

        ooze_fam_factory::create_coin(
            cap,
            metadata,
            string::utf8(b"TBD_NAME"),
            ascii::string(b"TBD_SYMBOL"),
            string::utf8(b"TBD_DESCRIPTION"),
            url::new_unsafe_from_bytes(b"TBD_ICON_URL"),
            test.ctx(),
        );
    };

    test::end(scenario);
}

#[test, expected_failure(abort_code = ooze_fam_factory::EInvalidSupply)]
fun test_mint_before_create_coin() {
    let mut scenario = test::begin(@0x1);
    let test = &mut scenario;

    // Alice publishes the ooze fam coin contract
    test.next_tx(ALICE); {
        ooze_fam_coin::init_for_testing(test.ctx());
    };

    // Alice tries to mint before create_coin
    test.next_tx(ALICE); {
        let mut cap = test.take_from_address<TreasuryCap<OOZE_FAM_COIN>>(ALICE);
        let metadata = test.take_from_address<CoinMetadata<OOZE_FAM_COIN>>(ALICE);

        // Mint some coins first
        let coins = cap.mint(1000, test.ctx());
        transfer::public_transfer(coins, ALICE);

        // Then try to create coin (should fail)
        ooze_fam_factory::create_coin(
            cap,
            metadata,
            string::utf8(b"TBD_NAME"),
            ascii::string(b"TBD_SYMBOL"),
            string::utf8(b"TBD_DESCRIPTION"),
            url::new_unsafe_from_bytes(b"TBD_ICON_URL"),
            test.ctx(),
        );
    };

    test::end(scenario);
}