#[test_only]
module msr_amm::test_amm;

use sui::test_scenario::{Self as test, ctx};
use sui::coin::{Self, Coin};
use sui::sui::SUI;
use msr_amm::msr_amm::{Self, PredictionMarket, OutcomeVault, OutcomeShare};
use sui::transfer;

const ALICE: address = @0xA11CE;
const BOB: address = @0xB0B;

#[test]
fun test_buy_prediction() {
    let mut scenario = test::begin(@0x1);
    let test = &mut scenario;

    // Setup: Alice creates prediction market and outcome vault
    test.next_tx(ALICE);
    {
        let mut market = msr_amm::create_prediction_market(test.ctx());
        msr_amm::add_market_outcome<SUI>(&mut market, test.ctx());
        transfer::public_share_object(market);
    };

    // Mint some SUI for Alice
    test.next_tx(ALICE);
    {
        let coin = coin::mint_for_testing<SUI>(100, test.ctx());
        transfer::public_transfer(coin, ALICE);
    };

    // Alice buys prediction tokens with 100 SUI
    test.next_tx(ALICE);
    {
        let mut market = test::take_shared<PredictionMarket>(test);
        let mut vault = test::take_shared<OutcomeVault<SUI>>(test);
        let sui = test::take_from_address<Coin<SUI>>(test, ALICE);

        let prediction_tokens = msr_amm::buy_prediction(&mut market, &mut vault, sui, test.ctx());
        assert!(coin::value(&prediction_tokens) > 0, 1);

        transfer::public_transfer(prediction_tokens, ALICE);
        transfer::public_share_object(market);
        transfer::public_share_object(vault);
    };

    test::end(scenario);
}

#[test]
fun test_sell_prediction() {
    let mut scenario = test::begin(@0x1);
    let test = &mut scenario;

    // Setup: Alice creates prediction market and outcome vault
    test.next_tx(ALICE);
    {
        let mut market = msr_amm::create_prediction_market(test.ctx());
        msr_amm::add_market_outcome<SUI>(&mut market, test.ctx());
        transfer::public_share_object(market);
    };

    // Alice first buys prediction tokens
    test.next_tx(ALICE);
    {
        let mut market = test::take_shared<PredictionMarket>(test);
        let mut vault = test::take_shared<OutcomeVault<SUI>>(test);
        let sui = test::take_from_address<Coin<SUI>>(test, ALICE);

        let prediction_tokens = msr_amm::buy_prediction(&mut market, &mut vault, sui, test.ctx());
        assert!(coin::value(&prediction_tokens) > 0, 1);

        transfer::public_transfer(prediction_tokens, ALICE);
        transfer::public_share_object(market);
        transfer::public_share_object(vault);
    };

    // Then Alice sells prediction tokens back
    test.next_tx(ALICE);
    {
        let mut market = test::take_shared<PredictionMarket>(test);
        let mut vault = test::take_shared<OutcomeVault<SUI>>(test);
        let prediction_tokens = test::take_from_address<Coin<OutcomeShare<SUI>>>(test, ALICE);

        let sui = msr_amm::sell_prediction(&mut market, &mut vault, prediction_tokens, test.ctx());
        assert!(coin::value(&sui) > 0, 1);

        transfer::public_transfer(sui, ALICE);
        transfer::public_share_object(market);
        transfer::public_share_object(vault);
    };

    test::end(scenario);
}

#[test]
fun test_market_state() {
    let mut scenario = test::begin(@0x1);
    let test = &mut scenario;

    // Setup: Alice creates prediction market and outcome vault
    test.next_tx(ALICE);
    {
        let mut market = msr_amm::create_prediction_market(test.ctx());
        msr_amm::add_market_outcome<SUI>(&mut market, test.ctx());
        transfer::public_share_object(market);
    };

    // Mint some SUI for Alice
    test.next_tx(ALICE);
    {
        let coin = coin::mint_for_testing<SUI>(100, test.ctx());
        transfer::public_transfer(coin, ALICE);
    };

    // Test market state
    test.next_tx(ALICE);
    {
        let mut market = test::take_shared<PredictionMarket>(test);
        let mut vault = test::take_shared<OutcomeVault<SUI>>(test);
        let sui = test::take_from_address<Coin<SUI>>(test, ALICE);

        let prediction_tokens = msr_amm::buy_prediction(&mut market, &mut vault, sui, test.ctx());
        let token_amount = coin::value(&prediction_tokens);

        // Test that market state is consistent
        let (sum_q, sum_q_squared, cost, outcome_count) = msr_amm::get_market_state(&market);
        assert!(sum_q > 0, 1);
        assert!(sum_q_squared > 0, 1);
        assert!(cost > 0, 1);
        assert!(outcome_count == 1, 1);

        transfer::public_transfer(prediction_tokens, ALICE);
        transfer::public_share_object(market);
        transfer::public_share_object(vault);
    };

    test::end(scenario);
}