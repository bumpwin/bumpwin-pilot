#[test_only]
module e2e_test_cases::mint_to_vault;

use std::ascii;
use std::string;
use sui::test_scenario::{Self as test, ctx};
use sui::url;

use coin_launcher::launcher;


// Test constants
const ALICE: address = @0xA11CE;
const BOB: address = @0xB0B;

public struct MEME_A has drop {}

#[test]
fun test_mint_to_vault() {
    let mut scenario = test::begin(@0x1);
    let test = &mut scenario;

    launcher::init_for_testing(test.ctx());

    test.next_tx(ALICE); {
        let launch_cap = test.take_shared<launcher::LaunchCap<launcher::LAUNCHER>>();

        launcher::create_coin(
            launch_cap,
            string::utf8(b"TBD_NAME"),
            ascii::string(b"TBD_SYMBOL"),
            string::utf8(b"TBD_DESCRIPTION"),
            url::new_unsafe_from_bytes(b"TBD_ICON_URL"),
            test.ctx(),
        );
    };

    test::end(scenario);
}