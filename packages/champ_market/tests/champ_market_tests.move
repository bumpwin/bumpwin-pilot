module champ_market::test_cpmm;

use sui::coin;
use sui::sui::SUI;
use sui::test_scenario::{Self as test, ctx};

const ALICE: address = @0xA11CE;
const BOB: address = @0xB0B;
const INIT_X: u64 = 1_000_000;
const INIT_Y: u64 = 2_000_000;
const SWAP_IN_AMOUNT: u64 = 10_000;

#[test]
fun test_cpmm_swap_flow() {
    let mut scenario = test::begin(@0x1);
    let test = &mut scenario;

    // === Step 0: Setup initial Pool ===
    test.next_tx(ALICE);
    {
        let coin_x = coin::mint_for_testing<SUI>(INIT_X, test.ctx());
        let coin_y = coin::mint_for_testing<SUI>(INIT_Y, test.ctx());
        champ_market::cpmm::share_pool(coin_x, coin_y, test.ctx());
    };

    // === Step 1: BOB does swap_x_to_y ===
    test.next_tx(BOB);
    {
        let mut pool = test.take_shared<champ_market::cpmm::Pool<SUI, SUI>>();
        let coin_in = coin::mint_for_testing<SUI>(SWAP_IN_AMOUNT, test.ctx());
        let coin_out = pool.swap_x_to_y(coin_in, test.ctx());

        let amount_out = coin_out.value();
        let k_new = pool.reserve_amount_x() * pool.reserve_amount_y();
        let expected_k = (INIT_X + SWAP_IN_AMOUNT) * (INIT_Y - amount_out);
        assert!(k_new <= expected_k, 0);
        assert!(amount_out > 0, 1);

        transfer::public_transfer(coin_out, BOB);
        test::return_shared(pool);
    };

    scenario.end();
}

#[test]
fun test_cpmm_swap_y_to_x_flow() {
    let mut scenario = test::begin(@0x1);
    let test = &mut scenario;

    // === Step 0: Setup initial Pool with specified reserves ===
    test.next_tx(ALICE);
    {
        let coin_x = coin::mint_for_testing<SUI>(500_000_000_000_000, test.ctx());
        let coin_y = coin::mint_for_testing<SUI>(10_000_000_000_000, test.ctx());
        champ_market::cpmm::share_pool(coin_x, coin_y, test.ctx());
    };

    // === Step 1: BOB does swap_y_to_x ===
    test.next_tx(BOB);
    {
        let mut pool = test.take_shared<champ_market::cpmm::Pool<SUI, SUI>>();
        let coin_in = coin::mint_for_testing<SUI>(10_000_000_000_000, test.ctx());
        let coin_out = pool.swap_y_to_x(coin_in, test.ctx());
        assert!(coin_out.value() > 0, 1);

        transfer::public_transfer(coin_out, BOB);
        test::return_shared(pool);
    };

    scenario.end();
}
