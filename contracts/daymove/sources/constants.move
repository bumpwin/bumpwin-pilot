module daymove::constants;

// Constants for date/time calculations
const JD_UNIX_EPOCH: u64 = 2_440_588; // 1970-01-01 Julian day
const SECONDS_PER_DAY: u64 = 86_400;
const MS_PER_SECOND: u64 = 1000;
const MS_PER_DAY: u64 = SECONDS_PER_DAY * MS_PER_SECOND;
const MS_PER_HOUR: u64 = 3600 * MS_PER_SECOND;
const MS_PER_MINUTE: u64 = 60 * MS_PER_SECOND;

// Time unit constants accessors
public fun seconds_per_day(): u64 { SECONDS_PER_DAY }

public fun ms_per_second(): u64 { MS_PER_SECOND }

public fun ms_per_day(): u64 { MS_PER_DAY }

public fun ms_per_hour(): u64 { MS_PER_HOUR }

public fun ms_per_minute(): u64 { MS_PER_MINUTE }

public fun jd_unix_epoch(): u64 { JD_UNIX_EPOCH }
