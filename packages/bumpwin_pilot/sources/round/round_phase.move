module bumpwin_pilot::round_phase;

use bumpwin_pilot::config;
use sui::clock::Clock;

const EInvalidPhase: u64 = 0;

public enum DarkNightBatch has copy, drop {
    Batch1,
    // Batch2,
    // Batch3,
    // Batch4,
    // Batch5,
}

public enum RoundPhase has copy, drop {
    BeforeStart,
    Daytime,
    DarkNight(DarkNightBatch),
    AfterEnd,
}

public struct BattleRoundConfig has copy, drop, store {
    daytime_ms: u64,
    darknight_ms: u64,
    darknight_batch_ms: u64,
}

fun round_config(): BattleRoundConfig {
    BattleRoundConfig {
        daytime_ms: config::daytime_ms(),
        darknight_ms: config::darknight_ms(),
        darknight_batch_ms: config::darknight_batch_ms(),
    }
}

public fun round_phase(start_timestamp_ms: u64, clock: &Clock): RoundPhase {
    let now = clock.timestamp_ms();
    let cfg = round_config();

    if (now < start_timestamp_ms) {
        RoundPhase::BeforeStart
    } else if (now < start_timestamp_ms + cfg.daytime_ms) {
        RoundPhase::Daytime
    } else if (now < start_timestamp_ms + cfg.daytime_ms + cfg.darknight_batch_ms) {
        RoundPhase::DarkNight(DarkNightBatch::Batch1)
        // TODO: Uncomment in production
        // } else if (now < start_timestamp_ms + cfg.daytime_ms + 2 * cfg.darknight_batch_ms) {
        //     RoundPhase::DarkNight(DarkNightBatch::Batch2)
        // } else if (now < start_timestamp_ms + cfg.daytime_ms + 3 * cfg.darknight_batch_ms) {
        //     RoundPhase::DarkNight(DarkNightBatch::Batch3)
        // } else if (now < start_timestamp_ms + cfg.daytime_ms + 4 * cfg.darknight_batch_ms) {
        //     RoundPhase::DarkNight(DarkNightBatch::Batch4)
        // } else if (now < start_timestamp_ms + cfg.daytime_ms + 5 * cfg.darknight_batch_ms) {
        //     RoundPhase::DarkNight(DarkNightBatch::Batch5)
    } else {
        RoundPhase::AfterEnd
    }
}

public fun assert_after_end(phase: RoundPhase) {
    match (phase) {
        RoundPhase::AfterEnd => {},
        _ => {
            abort EInvalidPhase
        },
    }
}
