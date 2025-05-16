#[test_only]
module bumpwin_pilot::go;

use bumpwin_pilot::battle_market;
use bumpwin_pilot::coinutils::mint_to;
use bumpwin_pilot::mockmemes;
use bumpwin_pilot::round_number;
use bumpwin_pilot::wsui::{Self, WSUI};
use mockcoins::cyan::CYAN;
use mockcoins::pink::PINK;
use mockcoins::yellow::YELLOW;
use sui::clock;
use sui::coin::{Self, TreasuryCap, Coin};
use sui::test_scenario::{Self as test, ctx};

#[test]
public fun test_battle_market() {
    let mut scenario = test::begin(@alice);
    let test = &mut scenario;

    clock::create_for_testing(test.ctx()).share_for_testing();

    wsui::init_for_testing(test.ctx());

    mockmemes::setup_pink_coin(test, @alice);
    mockmemes::setup_cyan_coin(test, @bob);
    mockmemes::setup_yellow_coin(test, @carol);

    test.next_tx(@alice);
    {
        let battle_market = battle_market::new(round_number::new(1), test.ctx());
        transfer::public_share_object(battle_market);
    };

    test.next_tx(@alice);
    {
        let mut battle_market = test.take_shared<battle_market::BattleMarket>();
        battle_market.register_meme<PINK>();
        battle_market.register_meme<CYAN>();
        battle_market.register_meme<YELLOW>();
        test::return_shared(battle_market);
    };

    mint_to<WSUI>(1000, @alice, test);
    mint_to<WSUI>(1000, @bob, test);
    (100, @alice, test);

    test.next_tx(@alice);
    {
        let wsui_in = coin::mint_for_testing<WSUI>(100, test.ctx());
        transfer::public_transfer(wsui_in, @alice);
    };

    test.next_tx(@alice);
    {
        let mut battle_market = test.take_shared<battle_market::BattleMarket>();
        let wsui_in = coin::mint_for_testing<WSUI>(100, test.ctx());
        let share = battle_market.buy_shares<PINK>(wsui_in, test.ctx());
        transfer::public_transfer(share, @alice);
        test::return_shared(battle_market);
    };

    scenario.end();
}
