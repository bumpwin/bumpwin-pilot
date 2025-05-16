module bumpwin_pilot::season_config;

use sui::clock::Clock;

public struct SeasonConfig has key, store {
    id: UID,
    genesis_ms: u64,
    max_num_rounds: u64,
}

public fun new(max_num_rounds: u64, clock: &Clock, ctx: &mut TxContext): SeasonConfig {
    SeasonConfig {
        id: object::new(ctx),
        genesis_ms: clock.timestamp_ms(),
        max_num_rounds,
    }
}
