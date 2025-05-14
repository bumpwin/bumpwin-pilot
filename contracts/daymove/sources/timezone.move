module daymove::timezone;

// TimeZone struct representing a timezone with offset in minutes
public struct TimeZone has copy, drop {
    offset_min: u16,     // Offset in minutes (e.g., 540 for UTC+9)
    is_negative: bool,   // Whether offset is negative (east/west of UTC)
}

// Create a new TimeZone with specified offset
public fun new(offset_min: u16, is_negative: bool): TimeZone {
    TimeZone { offset_min, is_negative }
}

// Create a positive timezone offset (east of UTC)
public fun new_positive(offset_min: u16): TimeZone {
    new(offset_min, false)
}

// Create a negative timezone offset (west of UTC)
public fun new_negative(offset_min: u16): TimeZone {
    new(offset_min, true)
}

// Common timezone constants
public fun utc(): TimeZone {
    new(0, false)
}

public fun jst(): TimeZone {  // Japan Standard Time (UTC+9)
    new_positive(540)
}

public fun est(): TimeZone {  // Eastern Standard Time (UTC-5)
    new_negative(300)
}

public fun cet(): TimeZone {  // Central European Time (UTC+1)
    new_positive(60)
}

// Get timezone offset in minutes
public fun offset_minutes(tz: &TimeZone): u16 {
    tz.offset_min
}

// Check if timezone has negative offset
public fun is_negative(tz: &TimeZone): bool {
    tz.is_negative
}

// Get offset in seconds (with sign)
public fun offset_seconds(tz: &TimeZone): (u64, bool) {
    let seconds = (tz.offset_min as u64) * 60;
    (seconds, tz.is_negative)
}

// Format TimeZone as string representation (only for debug/test purposes)
public fun format(tz: &TimeZone): (bool, u8, u8) {
    let hours = tz.offset_min / 60;
    let minutes = tz.offset_min % 60;
    (tz.is_negative, (hours as u8), (minutes as u8))
}
