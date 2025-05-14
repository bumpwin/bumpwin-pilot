module daymove::helpers;

use daymove::constants;
use daymove::utc_offset::{Self, UtcOffset};

// Helper function to validate YMD
public fun is_valid_ymd(y: u16, m: u8, d: u8): bool {
    if (!(m >= 1 && m <= 12)) { return false };
    let dim = days_in_month(y, m);
    d >= 1 && d <= dim
}

public fun days_in_month(y: u16, m: u8): u8 {
    match (m) {
        1 | 3 | 5 | 7 | 8 | 10 | 12 => 31,
        2 => if (is_leap(y)) 29 else 28,
        _ => 30,
    }
}

public fun is_leap(y: u16): bool {
    ((y % 4 == 0) && (y % 100 != 0)) || (y % 400 == 0)
}

// =======================================
// Julian day conversion (integer algorithm)
// =======================================
public fun ymd_to_jd(y: u16, m: u8, d: u8): u64 {
    // Special case for year 0 to avoid underflow
    if (y == 0) {
        return 1721060 + (m as u64) * 30 + (d as u64) // Approximate for year 0
    };

    let yy = y as u64;
    let mm = m as u64;
    let dd = d as u64;
    let a = (14 - mm) / 12;
    let y2 = yy + 4800 - a;
    let m2 = mm + 12 * a - 3;
    dd + (153 * m2 + 2) / 5 + 365 * y2 + y2 / 4 - y2 / 100 + y2 / 400 - 32045
}

public fun jd_to_ymd(jd: u64): (u16, u8, u8) {
    let b = jd + 32044;
    let c = (4 * b + 3) / 146097;
    let d = b - (146097 * c) / 4;
    let e = (4 * d + 3) / 1461;
    let f = d - (1461 * e) / 4;
    let g = (5 * f + 2) / 153;
    let day = (f - (153 * g + 2) / 5 + 1) as u8;
    let month = (g + 3 - 12 * (g / 10)) as u8;
    let year = (100 * c + e - 4800 + (g / 10)) as u16;
    (year, month, day)
}

// =======================================
// DateTime creation and decomposition
// =======================================

// Create timestamp from components
public fun components_to_timestamp(
    y: u16,
    m: u8,
    d: u8,
    h: u8,
    min: u8,
    s: u8,
    offset: &UtcOffset,
): u64 {
    // Pre-validate
    assert!(is_valid_ymd(y, m, d), 1); // EInvalidDate
    assert!(h < 24 && min < 60 && s < 60, 2); // EInvalidTime
    assert!(y > 1970 || (y == 1970 && (m > 1 || (m == 1 && d >= 1))), 3); // EPreUnixEpochDate

    // Convert to Julian day
    let jd = ymd_to_jd(y, m, d);

    // Calculate epoch days and seconds within the day
    let epoch_days = jd - constants::jd_unix_epoch();
    let day_seconds = (h as u64) * 3600 + (min as u64) * 60 + (s as u64);

    // Calculate UTC timestamp
    let local_seconds = epoch_days * constants::seconds_per_day() + day_seconds;

    // Apply offset to get UTC
    let offset_sec = utc_offset::offset_seconds(offset);
    let utc_seconds = if (utc_offset::is_negative(offset)) {
        local_seconds + offset_sec
    } else {
        // Avoid underflow
        if (local_seconds >= offset_sec) {
            local_seconds - offset_sec
        } else {
            0
        }
    };

    // Convert to milliseconds
    utc_seconds * constants::ms_per_second()
}

// Decompose timestamp into components using an offset
public fun decompose_timestamp(
    timestamp_ms: u64,
    offset: &UtcOffset,
): (u16, u8, u8, u8, u8, u8, u16) {
    let ms_part = (timestamp_ms % constants::ms_per_second()) as u16;
    let utc_seconds = timestamp_ms / constants::ms_per_second();

    // Apply timezone offset for local time
    let offset_sec = utc_offset::offset_seconds(offset);
    let local_seconds = if (utc_offset::is_negative(offset)) {
        if (utc_seconds >= offset_sec) {
            utc_seconds - offset_sec
        } else {
            0
        }
    } else {
        utc_seconds + offset_sec
    };

    // Calculate days and time
    let days = local_seconds / constants::seconds_per_day();
    let day_seconds = local_seconds % constants::seconds_per_day();

    // Convert to date and time components
    let (year, month, day) = jd_to_ymd(days + constants::jd_unix_epoch());
    let hour = (day_seconds / 3600) as u8;
    let remainder = day_seconds % 3600;
    let minute = (remainder / 60) as u8;
    let second = (remainder % 60) as u8;

    (year, month, day, hour, minute, second, ms_part)
}
