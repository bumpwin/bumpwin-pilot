#[test_only]
module bumpwin_pilot::go;

use bumpwin_pilot::meme_vault;
use mockcoins::blue::BLUE;
use mockcoins::green::GREEN;
use mockcoins::pink::PINK;
use mockcoins::red::RED;
use std::ascii;
use std::string;
use sui::clock;
use sui::coin::{Self, TreasuryCap, CoinMetadata};
use sui::test_scenario::{Self as test, ctx};
use sui::url;

const ALICE: address = @0x1;

#[test]
public fun test_season_config() {
    let mut scenario = test::begin(@0x1);
    let test = &mut scenario;

    clock::create_for_testing(test.ctx()).share_for_testing();
    mockcoins::red::init_for_testing(test.ctx());
    mockcoins::green::init_for_testing(test.ctx());
    mockcoins::blue::init_for_testing(test.ctx());

    test.next_tx(ALICE);
    {
        transfer::public_transfer(
            coin::mint_for_testing<RED>(100, test.ctx()),
            ALICE,
        );
        transfer::public_transfer(
            coin::mint_for_testing<GREEN>(100, test.ctx()),
            ALICE,
        );
        transfer::public_transfer(
            coin::mint_for_testing<BLUE>(100, test.ctx()),
            ALICE,
        );
    };

    test.next_tx(ALICE);
    {
        mockcoins::pink::init_for_testing(test.ctx());
    };

    test.next_tx(ALICE);
    {
        let treasury_cap = test.take_from_address<TreasuryCap<PINK>>(ALICE);
        let metadata = test.take_from_address<CoinMetadata<PINK>>(ALICE);
        meme_vault::share(treasury_cap, metadata, test.ctx());
    };

    test.next_tx(ALICE);
    {
        let mut vault = test.take_shared<meme_vault::MemeVault<PINK>>();
        vault.update_metadata(
            string::utf8(b"Sui Doge"),
            ascii::string(b"SDOGE"),
            string::utf8(b"Sui Doge is a meme coin"),
            url::new_unsafe_from_bytes(
                b"https://s2.coinmarketcap.com/static/img/coins/200x200/1027.png",
            ),
        );
        test::return_shared(vault);
    };

    // let clock = test.take_shared<clock::Clock>();

    scenario.end();
}
