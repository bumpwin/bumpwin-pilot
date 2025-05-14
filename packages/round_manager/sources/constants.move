module round_manager::constants;

const TOTAL_SUPPLY: u64 = 1_000_000_000_000_000; // 1 billion coins (10^9), with 6 decimals → 10^(9+6) base units
const HALF_TOTAL_SUPPLY: u64 = 500_000_000_000_000; // 500 million coins (10^9), with 6 decimals → 10^(9+6) base units
const DECIMALS: u8 = 6; // Number of decimal places (1 coin = 10^6 base units)

const HOUR_MS: u64 = 3_600_000;

public fun total_supply(): u64 { TOTAL_SUPPLY }

public fun half_total_supply(): u64 { HALF_TOTAL_SUPPLY }

public fun decimals(): u8 { DECIMALS }

