#[test_only]
module battle_market::test_amm;
use sui::test_scenario::{Self as test};
use sui::coin::{Self};
use sui::sui::SUI;
use battle_market::market_vault::{Self, MarketVault};


public struct MemeA has drop { }
public struct MemeB has drop { }

const ALICE: address = @0xA11CE;
const INITIAL_LIQUIDITY: u64 = 1000000;

#[test]
fun test_buy_prediction() {
    let mut scenario = test::begin(ALICE);
    let test = &mut scenario;

    // Setup: Create vault and register coins
    test.next_tx(ALICE); {
        let mut market = market_vault::new(test.ctx());
        market.register_coin<MemeA>(test.ctx());
        market.register_coin<MemeB>(test.ctx());

        assert!(market.num_outcomes() == 2, 0);

        transfer::public_share_object(market);
    };

    // Add initial liquidity
    test.next_tx(ALICE); {
        let sui_coin = coin::mint_for_testing<SUI>(INITIAL_LIQUIDITY, test.ctx());
        let mut market = test.take_shared<MarketVault>();

        let share = market.buy_shares<MemeA>(sui_coin, test.ctx());
        transfer::public_transfer(share, ALICE);

        test::return_shared(market);
    };

    scenario.end();
}