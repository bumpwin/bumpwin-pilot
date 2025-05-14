#[test_only]
module round_manager::season_config_tests;

use round_manager::season_config;
use sui::clock;
use sui::test_scenario::{Self as test, ctx};

const ALICE: address = @0x1;

#[test]
public fun test_season_config() {
    let mut scenario = test::begin(@0x1);
    let test = &mut scenario;

    clock::create_for_testing(test.ctx()).share_for_testing();

    test.next_tx(ALICE);
    {
        let clock = test.take_shared<clock::Clock>();

        let season_config = season_config::new(1, 10, clock, test.ctx());

    };

    scenario.end();
}
