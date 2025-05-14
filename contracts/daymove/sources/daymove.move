module daymove::daymove;

use daymove::timezone::{Self, TimeZone};

// Constants for date/time calculations
const JD_OFFSET: u64 = 2_440_588; // 1970-01-01 Julian day
const SECONDS_PER_DAY: u64 = 86_400;
const MS_PER_SECOND: u64 = 1000;
const MS_PER_DAY: u64 = SECONDS_PER_DAY * MS_PER_SECOND;

// Error codes
const EInvalidDate: u64 = 1;
const EInvalidTime: u64 = 2;
const EPreEpochDate: u64 = 3;

// New ZonedDateTime structure that stores timestamp_ms and timezone
public struct ZonedDateTime has copy, drop {
    timestamp_ms: u64,
    tz: TimeZone,
}

// =======================================
// 1. Constructors & Validators
// =======================================

// Helper function to validate YMD
fun is_valid_ymd(y: u16, m: u8, d: u8): bool {
    if (!(m >= 1 && m <= 12)) { return false };
    let dim = days_in_month(y, m);
    d >= 1 && d <= dim
}

fun days_in_month(y: u16, m: u8): u8 {
    if (m == 1 || m == 3 || m == 5 || m == 7 || m == 8 || m == 10 || m == 12) 31
    else if (m == 2) { if (is_leap(y)) 29 else 28 } else 30
}

fun is_leap(y: u16): bool {
    ((y % 4 == 0) && (y % 100 != 0)) || (y % 400 == 0)
}

// Create ZonedDateTime with a TimeZone
public fun new_zdt_with_tz(
    y: u16,
    m: u8,
    d: u8,
    h: u8,
    min: u8,
    s: u8,
    tz: &TimeZone,
): ZonedDateTime {
    assert!(is_valid_ymd(y, m, d), EInvalidDate);
    assert!(h < 24 && min < 60 && s < 60, EInvalidTime);

    // Check if the date is before Unix epoch (1970-01-01)
    assert!(y > 1970 || (y == 1970 && (m > 1 || (m == 1 && d >= 1))), EPreEpochDate);

    // Convert to Julian day
    let jd = ymd_to_jd(y, m, d);

    // Calculate epoch days and seconds within the day
    let epoch_days = jd - JD_OFFSET;
    let day_seconds = (h as u64) * 3600 + (min as u64) * 60 + (s as u64);

    // Calculate UTC timestamp
    let local_seconds = epoch_days * SECONDS_PER_DAY + day_seconds;

    // Apply timezone offset to get UTC
    let (offset_seconds, is_negative) = timezone::offset_seconds(tz);
    let utc_seconds = if (is_negative) {
        local_seconds + offset_seconds
    } else {
        // Avoid underflow
        if (local_seconds >= offset_seconds) {
            local_seconds - offset_seconds
        } else {
            0
        }
    };

    // Convert to milliseconds
    let timestamp_ms = utc_seconds * MS_PER_SECOND;

    ZonedDateTime {
        timestamp_ms,
        tz: *tz,
    }
}

public fun new_zdt(y: u16, m: u8, d: u8, h: u8, min: u8, s: u8, tz_offset_min: u16): ZonedDateTime {
    new_zdt_with_tz(y, m, d, h, min, s, &timezone::new_positive(tz_offset_min))
}

// Create a ZonedDateTime with a negative timezone offset
public fun new_zdt_negative(
    y: u16,
    m: u8,
    d: u8,
    h: u8,
    min: u8,
    s: u8,
    tz_offset_min: u16,
): ZonedDateTime {
    new_zdt_with_tz(y, m, d, h, min, s, &timezone::new_negative(tz_offset_min))
}

// Function to create a ZonedDateTime from epoch with a negative timezone offset
public fun from_epoch_negative(epoch_sec: u64, tz_offset_min: u16): ZonedDateTime {
    from_epoch_with_tz(epoch_sec, &timezone::new_negative(tz_offset_min))
}

// =======================================
// 2. Public API matching the test cases
// =======================================

// Creates a ZonedDateTime from a UTC timestamp in milliseconds
public fun from_timestamp_ms(timestamp_ms: u64): ZonedDateTime {
    ZonedDateTime {
        timestamp_ms,
        tz: timezone::utc(),
    }
}

// Convenience functions to create ZonedDateTime with common timezones
public fun new_utc(y: u16, m: u8, d: u8, h: u8, min: u8, s: u8): ZonedDateTime {
    new_zdt_with_tz(y, m, d, h, min, s, &timezone::utc())
}

public fun new_jst(y: u16, m: u8, d: u8, h: u8, min: u8, s: u8): ZonedDateTime {
    new_zdt_with_tz(y, m, d, h, min, s, &timezone::jst())
}

public fun new_est(y: u16, m: u8, d: u8, h: u8, min: u8, s: u8): ZonedDateTime {
    new_zdt_with_tz(y, m, d, h, min, s, &timezone::est())
}

public fun new_cet(y: u16, m: u8, d: u8, h: u8, min: u8, s: u8): ZonedDateTime {
    new_zdt_with_tz(y, m, d, h, min, s, &timezone::cet())
}

// Internal helper to decompose ZonedDateTime into components
fun decompose(zdt: &ZonedDateTime): (u16, u8, u8, u8, u8, u8) {
    let timestamp_ms = zdt.timestamp_ms;
    let utc_seconds = timestamp_ms / MS_PER_SECOND;

    // Apply timezone offset for local time
    let (offset_seconds, is_negative) = timezone::offset_seconds(&zdt.tz);
    let local_seconds = if (is_negative) {
        if (utc_seconds >= offset_seconds) {
            utc_seconds - offset_seconds
        } else {
            0
        }
    } else {
        utc_seconds + offset_seconds
    };

    // Calculate days and time
    let days = local_seconds / SECONDS_PER_DAY;
    let day_seconds = local_seconds % SECONDS_PER_DAY;

    // Convert to date and time components
    let (year, month, day) = jd_to_ymd(days + JD_OFFSET);
    let hour = (day_seconds / 3600) as u8;
    let remainder = day_seconds % 3600;
    let minute = (remainder / 60) as u8;
    let second = (remainder % 60) as u8;

    (year, month, day, hour, minute, second)
}

// Get component methods
public fun year(zdt: &ZonedDateTime): u16 {
    let (y, _, _, _, _, _) = decompose(zdt);
    y
}

public fun month(zdt: &ZonedDateTime): u8 {
    let (_, m, _, _, _, _) = decompose(zdt);
    m
}

public fun day(zdt: &ZonedDateTime): u8 {
    let (_, _, d, _, _, _) = decompose(zdt);
    d
}

public fun hour(zdt: &ZonedDateTime): u8 {
    let (_, _, _, h, _, _) = decompose(zdt);
    h
}

public fun minute(zdt: &ZonedDateTime): u8 {
    let (_, _, _, _, m, _) = decompose(zdt);
    m
}

public fun second(zdt: &ZonedDateTime): u8 {
    let (_, _, _, _, _, s) = decompose(zdt);
    s
}

// Extract TimeZone from a ZonedDateTime
public fun timezone_from_zdt(zdt: &ZonedDateTime): TimeZone {
    zdt.tz
}

// Convert to timestamp in milliseconds
public fun to_timestamp_ms(zdt: &ZonedDateTime): u64 {
    zdt.timestamp_ms
}

// Creates a ZonedDateTime from a timestamp in milliseconds with specific TimeZone
public fun from_timestamp_ms_with_tz(timestamp_ms: u64, tz: &TimeZone): ZonedDateTime {
    ZonedDateTime {
        timestamp_ms,
        tz: *tz,
    }
}

// Add days to the date
public fun add_days(zdt: &ZonedDateTime, delta: u64): ZonedDateTime {
    // Simply add days worth of milliseconds
    let new_timestamp = zdt.timestamp_ms + (delta * MS_PER_DAY);

    ZonedDateTime {
        timestamp_ms: new_timestamp,
        tz: zdt.tz,
    }
}

// =======================================
// 3. Epoch seconds <--> DateTime conversion
// =======================================
public fun to_epoch(zdt: &ZonedDateTime): u64 {
    zdt.timestamp_ms / MS_PER_SECOND
}

// Convert epoch to ZonedDateTime using a TimeZone struct
public fun from_epoch_with_tz(epoch_sec: u64, tz: &TimeZone): ZonedDateTime {
    ZonedDateTime {
        timestamp_ms: epoch_sec * MS_PER_SECOND,
        tz: *tz,
    }
}

public fun from_epoch(epoch_sec: u64, tz_offset_min: u16): ZonedDateTime {
    from_epoch_with_tz(epoch_sec, &timezone::new_positive(tz_offset_min))
}

// =======================================
// 4. Helper: Julian day conversion (integer algorithm)
// =======================================
fun ymd_to_jd(y: u16, m: u8, d: u8): u64 {
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

fun jd_to_ymd(jd: u64): (u16, u8, u8) {
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

#[test]
public fun test_date_struct() {
    let jst = timezone::jst();
    let z = new_zdt_with_tz(2025, 5, 14, 9, 0, 0, &jst);
    let after = add_days(&z, 20); // 20 days later
    let epoch = to_epoch(&after); // UTC epoch seconds
    let roundtrip = from_epoch_with_tz(epoch, &jst);
    assert!(day(&after) == day(&roundtrip), 0);
}

#[test]
public fun test_timezone_struct() {
    // Use the JST timezone constant
    let jst = timezone::jst();
    // Create a date using the timezone
    let z = new_zdt_with_tz(2025, 5, 14, 9, 0, 0, &jst);
    // Add 20 days
    let after = add_days(&z, 20);
    // Convert to epoch and back using the timezone
    let epoch = to_epoch(&after);
    let roundtrip = from_epoch_with_tz(epoch, &jst);
    // Verify
    assert!(year(&after) == year(&roundtrip), 0);
    assert!(month(&after) == month(&roundtrip), 1);
    assert!(day(&after) == day(&roundtrip), 2);
    assert!(hour(&after) == hour(&roundtrip), 3);
    assert!(minute(&after) == minute(&roundtrip), 4);
    assert!(second(&after) == second(&roundtrip), 5);

    // Test EST timezone
    let est = timezone::est();
    let z2 = new_zdt_with_tz(2025, 5, 14, 15, 30, 0, &est);
    let epoch2 = to_epoch(&z2);
    let roundtrip2 = from_epoch_with_tz(epoch2, &est);
    assert!(day(&z2) == day(&roundtrip2), 6);
    assert!(hour(&z2) == hour(&roundtrip2), 7);
}

#[test]
public fun test_convenience_functions() {
    // Create dates with convenience functions
    let utc_time = new_utc(2025, 1, 1, 0, 0, 0);
    let jst_time = new_jst(2025, 1, 1, 9, 0, 0);
    let est_time = new_est(2024, 12, 31, 19, 0, 0);

    // All should represent approximately the same moment
    let utc_epoch = to_epoch(&utc_time);
    let jst_epoch = to_epoch(&jst_time);
    let est_epoch = to_epoch(&est_time);

    // Small error margin due to timezone differences
    let margin: u64 = 60; // 1 minute error margin

    // Test that all epochs are within margin of each other
    assert!(utc_epoch >= jst_epoch - margin && utc_epoch <= jst_epoch + margin, 0);
    assert!(utc_epoch >= est_epoch - margin && utc_epoch <= est_epoch + margin, 1);
}

#[test]
#[expected_failure(abort_code = EPreEpochDate)]
public fun test_pre_epoch_date() {
    // This should fail because it's before Unix epoch
    let _pre_epoch = new_utc(1969, 7, 20, 20, 17, 40);
}
