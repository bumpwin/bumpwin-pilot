module round_manager::config;

const MS_PER_HOUR: u64 = 3600_000;
const MS_PER_MINUTE: u64 = 60_000;

public fun daytime_ms(): u64 {
    24 * MS_PER_HOUR
}

public fun darknight_ms(): u64 {
    1 * MS_PER_HOUR
}

public fun darknight_batch_ms(): u64 {
    12 * MS_PER_MINUTE
}
