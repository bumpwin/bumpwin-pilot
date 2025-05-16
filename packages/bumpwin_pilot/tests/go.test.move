#[test_only]
module bumpwin_pilot::go;

use bumpwin_pilot::mockmemes;
use sui::clock;
use sui::test_scenario::{Self as test, ctx};

#[test]
public fun test_season_config() {
    let mut scenario = test::begin(@alice);
    let test = &mut scenario;

    clock::create_for_testing(test.ctx()).share_for_testing();

    mockmemes::setup_pink_coin(test, @alice);
    mockmemes::setup_cyan_coin(test, @bob);
    mockmemes::setup_yellow_coin(test, @carol);

    scenario.end();
}
