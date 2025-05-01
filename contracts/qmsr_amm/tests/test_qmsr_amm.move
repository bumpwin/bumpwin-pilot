#[test_only]
module qmsr_amm::test_qmsr_amm;

use sui::test_scenario::{Self as test, ctx};
use sui::coin::{Self, Coin};
use sui::sui::SUI;
use qmsr_amm::qmsr_amm::{Self, QMSR_AMM, ShareVault, ShareCoin};
use sui::transfer;

const ALICE: address = @0xA11CE;
const BOB: address = @0xB0B;

#[test]
fun test_swap_quote_to_share() {
    let mut scenario = test::begin(@0x1);
    let test = &mut scenario;

    // Setup: Alice creates AMM and share vault
    test.next_tx(ALICE);
    {
        let mut amm = qmsr_amm::create(test.ctx());
        qmsr_amm::create_share_vault<SUI>(&mut amm, test.ctx());
        transfer::public_share_object(amm);
    };

    // Mint some SUI for Alice
    test.next_tx(ALICE);
    {
        let coin = coin::mint_for_testing<SUI>(100, test.ctx());
        transfer::public_transfer(coin, ALICE);
    };

    // Alice deposits 100 SUI into AMM
    test.next_tx(ALICE);
    {
        let mut amm = test::take_shared<QMSR_AMM>(test);
        let mut vault = test::take_shared<ShareVault<SUI>>(test);
        let sui = test::take_from_address<Coin<SUI>>(test, ALICE);

        let share_coin = qmsr_amm::swap_quote_to_share(&mut amm, &mut vault, sui, test.ctx());
        assert!(coin::value(&share_coin) > 0, 1);

        transfer::public_transfer(share_coin, ALICE);
        transfer::public_share_object(amm);
        transfer::public_share_object(vault);
    };

    test::end(scenario);
}

#[test]
fun test_swap_share_to_quote() {
    let mut scenario = test::begin(@0x1);
    let test = &mut scenario;

    // Setup: Alice creates AMM and share vault
    test.next_tx(ALICE);
    {
        let mut amm = qmsr_amm::create(test.ctx());
        qmsr_amm::create_share_vault<SUI>(&mut amm, test.ctx());
        transfer::public_share_object(amm);
    };

    // Alice first swaps SUI to shares
    test.next_tx(ALICE);
    {
        let mut amm = test::take_shared<QMSR_AMM>(test);
        let mut vault = test::take_shared<ShareVault<SUI>>(test);
        let sui = test::take_from_address<Coin<SUI>>(test, ALICE);

        let share_coin = qmsr_amm::swap_quote_to_share(&mut amm, &mut vault, sui, test.ctx());
        assert!(coin::value(&share_coin) > 0, 1);

        transfer::public_transfer(share_coin, ALICE);
        transfer::public_share_object(amm);
        transfer::public_share_object(vault);
    };

    // Then Alice swaps shares back to SUI
    test.next_tx(ALICE);
    {
        let mut amm = test::take_shared<QMSR_AMM>(test);
        let mut vault = test::take_shared<ShareVault<SUI>>(test);
        let share_coin = test::take_from_address<Coin<ShareCoin<SUI>>>(test, ALICE);

        let sui = qmsr_amm::swap_share_to_quote(&mut amm, &mut vault, share_coin, test.ctx());
        assert!(coin::value(&sui) > 0, 1);

        transfer::public_transfer(sui, ALICE);
        transfer::public_share_object(amm);
        transfer::public_share_object(vault);
    };

    test::end(scenario);
}

#[test]
fun test_swap_rates() {
    let mut scenario = test::begin(@0x1);
    let test = &mut scenario;

    // Setup: Alice creates AMM and share vault
    test.next_tx(ALICE);
    {
        let mut amm = qmsr_amm::create(test.ctx());
        qmsr_amm::create_share_vault<SUI>(&mut amm, test.ctx());
        transfer::public_share_object(amm);
    };

    // Mint some SUI for Alice
    test.next_tx(ALICE);
    {
        let coin = coin::mint_for_testing<SUI>(100, test.ctx());
        transfer::public_transfer(coin, ALICE);
    };

    // Test swap rates
    test.next_tx(ALICE);
    {
        let mut amm = test::take_shared<QMSR_AMM>(test);
        let mut vault = test::take_shared<ShareVault<SUI>>(test);
        let sui = test::take_from_address<Coin<SUI>>(test, ALICE);

        let share_coin = qmsr_amm::swap_quote_to_share(&mut amm, &mut vault, sui, test.ctx());
        let share_amount = coin::value(&share_coin);

        // Test that swap rates are consistent
        let expected_quote = qmsr_amm::swap_rate_share_to_quote(&mut vault, share_amount);
        assert!(expected_quote > 0, 1);

        transfer::public_transfer(share_coin, ALICE);
        transfer::public_share_object(amm);
        transfer::public_share_object(vault);
    };

    test::end(scenario);
}