#[test_only]
module bumpwin_pilot::mockmemes;

use bumpwin_pilot::meme_vault;
use mockcoins::cyan::CYAN;
use mockcoins::pink::PINK;
use mockcoins::yellow::YELLOW;
use std::ascii;
use std::string;
use sui::coin::{TreasuryCap, CoinMetadata};
use sui::test_scenario::{Self as test, ctx};
use sui::url;

public fun setup_pink_coin(test: &mut test::Scenario, owner: address) {
    test.next_tx(owner);
    {
        mockcoins::pink::init_for_testing(test.ctx());
    };

    test.next_tx(owner);
    {
        let treasury_cap = test.take_from_address<TreasuryCap<PINK>>(owner);
        let metadata = test.take_from_address<CoinMetadata<PINK>>(owner);
        meme_vault::share(treasury_cap, metadata, test.ctx());
    };

    test.next_tx(owner);
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
}

public fun setup_cyan_coin(test: &mut test::Scenario, owner: address) {
    test.next_tx(owner);
    {
        mockcoins::cyan::init_for_testing(test.ctx());
    };

    test.next_tx(owner);
    {
        let treasury_cap = test.take_from_address<TreasuryCap<CYAN>>(owner);
        let metadata = test.take_from_address<CoinMetadata<CYAN>>(owner);
        meme_vault::share(treasury_cap, metadata, test.ctx());
    };

    test.next_tx(owner);
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
}

public fun setup_yellow_coin(test: &mut test::Scenario, owner: address) {
    test.next_tx(owner);
    {
        mockcoins::yellow::init_for_testing(test.ctx());
    };

    test.next_tx(owner);
    {
        let treasury_cap = test.take_from_address<TreasuryCap<YELLOW>>(owner);
        let metadata = test.take_from_address<CoinMetadata<YELLOW>>(owner);
        meme_vault::share(treasury_cap, metadata, test.ctx());
    };

    test.next_tx(owner);
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
}
