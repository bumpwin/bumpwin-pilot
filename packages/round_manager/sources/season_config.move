module round_manager::season_config;

use round_manager::constants;
use sui::clock::Clock;

public struct SeasonConfig has key, store {
    id: UID,
    round: u64,
    genesis_ms: u64,
    ms_per_round: u64,
    daytime_ms: u64,
    night_ms: u64,
    num_rounds: u64,
}

fun new(round: u64, num_rounds: u64, clock: &mut Clock, ctx: &mut TxContext): SeasonConfig {
    SeasonConfig {
        id: object::new(ctx),
        round,
        genesis_ms: clock.timestamp_ms(),
        ms_per_round: 25*constants::hour_ms(),
        daytime_ms: 24*constants::hour_ms(),
        night_ms: 1*constants::hour_ms(),
        num_rounds,
    }
}
