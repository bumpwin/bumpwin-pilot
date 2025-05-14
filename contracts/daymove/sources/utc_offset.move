module daymove::utc_offset;

// UtcOffset structure that stores offset minutes and sign
public struct UtcOffset has copy, drop {
    minutes: u16,
    is_negative: bool,
}

// Create a positive UTC offset
public fun new_positive(minutes: u16): UtcOffset {
    UtcOffset {
        minutes,
        is_negative: false,
    }
}

// Create a negative UTC offset
public fun new_negative(minutes: u16): UtcOffset {
    UtcOffset {
        minutes,
        is_negative: true,
    }
}

// UTC offset (±00:00)
public fun utc(): UtcOffset {
    new_positive(0)
}

// JST offset (+09:00)
public fun jst(): UtcOffset {
    new_positive(540)
}

// EST offset (-05:00)
public fun est(): UtcOffset {
    new_negative(300)
}

// CET offset (+01:00)
public fun cet(): UtcOffset {
    new_positive(60)
}

// Get offset seconds from UtcOffset
public fun offset_seconds(offset: &UtcOffset): u64 {
    (offset.minutes as u64) * 60
}

// Get the minutes of the offset
public fun minutes(offset: &UtcOffset): u16 {
    offset.minutes
}

// Check if the offset is negative
public fun is_negative(offset: &UtcOffset): bool {
    offset.is_negative
}

// Format offset as hours and minutes
public fun to_hm(offset: &UtcOffset): (u8, u8) {
    let hours = offset.minutes / 60;
    let minutes = offset.minutes % 60;
    ((hours as u8), (minutes as u8))
}
