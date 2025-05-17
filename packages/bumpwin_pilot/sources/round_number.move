module bumpwin_pilot::round_number;

public struct RoundNumber has copy, drop, store {
    number: u64,
}

public fun new(number: u64): RoundNumber {
    RoundNumber { number }
}
