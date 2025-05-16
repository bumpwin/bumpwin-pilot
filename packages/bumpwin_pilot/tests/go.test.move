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
use mockcoins::cyan::CYAN;
use mockcoins::yellow::YELLOW;

#[test]
public fun test_season_config() {
    let mut scenario = test::begin(@alice);
    let test = &mut scenario;

    clock::create_for_testing(test.ctx()).share_for_testing();

    test.next_tx(@alice);
    {
        mockcoins::pink::init_for_testing(test.ctx());
    };

    test.next_tx(@alice);
    {
        let treasury_cap = test.take_from_address<TreasuryCap<PINK>>(@alice);
        let metadata = test.take_from_address<CoinMetadata<PINK>>(@alice);
        meme_vault::share(treasury_cap, metadata, test.ctx());
    };

    test.next_tx(@alice);
    {
        let mut vault = test.take_shared<meme_vault::MemeVault<PINK>>();
        vault.update_metadata(
            string::utf8(b"Pink Panther"),
            ascii::string(b"PINK"),
            string::utf8(b"The coolest pink coin in town"),
            url::new_unsafe_from_bytes(
                b"https://example.com/pink-panther.png",
            ),
        );
        test::return_shared(vault);
    };

    test.next_tx(@bob);
    {
        mockcoins::cyan::init_for_testing(test.ctx());
    };

    test.next_tx(@bob);
    {
        let treasury_cap = test.take_from_address<TreasuryCap<CYAN>>(@bob);
        let metadata = test.take_from_address<CoinMetadata<CYAN>>(@bob);
        meme_vault::share(treasury_cap, metadata, test.ctx());
    };

    test.next_tx(@bob);
    {
        let mut vault = test.take_shared<meme_vault::MemeVault<CYAN>>();
        vault.update_metadata(
            string::utf8(b"Cyan Dragon"),
            ascii::string(b"CYAN"),
            string::utf8(b"A mythical cyan dragon coin"),
            url::new_unsafe_from_bytes(
                b"https://example.com/cyan-dragon.png",
            ),
        );
        test::return_shared(vault);
    };

    // Yellow coin tests
    test.next_tx(@carol);
    {
        mockcoins::yellow::init_for_testing(test.ctx());
    };

    test.next_tx(@carol);
    {
        let treasury_cap = test.take_from_address<TreasuryCap<YELLOW>>(@carol);
        let metadata = test.take_from_address<CoinMetadata<YELLOW>>(@carol);
        meme_vault::share(treasury_cap, metadata, test.ctx());
    };

    test.next_tx(@carol);
    {
        let mut vault = test.take_shared<meme_vault::MemeVault<YELLOW>>();
        vault.update_metadata(
            string::utf8(b"Yellow Phoenix"),
            ascii::string(b"YELLOW"),
            string::utf8(b"A legendary yellow phoenix coin"),
            url::new_unsafe_from_bytes(
                b"https://example.com/yellow-phoenix.png",
            ),
        );
        test::return_shared(vault);
    };

    scenario.end();
}
