#[test_only]
module e2e_test_cases::test_mint_meme_to_treasury;

use std::ascii;
use std::string;

use sui::test_scenario::{Self as test, ctx};
use sui::coin;
use sui::url;

use coin_launcher::launcher;
use battle_market::meme_vault::{Self, MemeVault};
const ENotImplemented: u64 = 0;

// Test constants
const ALICE: address = @0xA11CE;
const BOB: address = @0xB0B;

public struct MEME_A has drop {}

#[test]
fun test_mint_meme_to_treasury() {
    let mut scenario = test::begin(@0x1);
    let test = &mut scenario;

    launcher::init_for_testing(test.ctx());
    meme_vault::create<MEME_A>(test.ctx());

    test.next_tx(ALICE); {
        let mut treasury_cap = test.take_from_address<coin::TreasuryCap<launcher::LAUNCHER>>(ALICE);
        let metadata = test.take_from_address<coin::CoinMetadata<launcher::LAUNCHER>>(ALICE);
        let mut vault = test.take_shared<MemeVault<launcher::LAUNCHER>>();

        launcher::create_coin(
            &mut treasury_cap,
            metadata,
            &mut vault,
            string::utf8(b"TBD_NAME"),
            string::utf8(b"TBD_SYMBOL"),
            string::utf8(b"TBD_DESCRIPTION"),
            url::new_unsafe_from_bytes(b"TBD_ICON_URL"),
            test.ctx(),
        );

        test.transfer_to_address(treasury_cap, ALICE);
        test.transfer_to_address(metadata, ALICE);
        test.transfer_to_address(vault, ALICE);
    };
}

#[test, expected_failure(abort_code = ::e2e_test_cases::e2e_test_cases_tests::ENotImplemented)]
fun test_e2e_test_cases_fail() {
    abort ENotImplemented
}

