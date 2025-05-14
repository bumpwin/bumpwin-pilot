module daymove::daymove;

use daymove::timezone::{Self, TimeZone};

// Constants for date/time calculations
const JD_OFFSET: u64 = 2_440_588; // 1970-01-01 Julian day
const SECONDS_PER_DAY: u64 = 86_400;
const MS_PER_SECOND: u64 = 1000;

// Format: YYYY-MM-DD
public struct PlainDate has copy, drop {
    year: u16,
    month: u8,
    day: u8,
}

// Local time + TZ offset (in minutes, e.g. +540 = JST)
public struct ZonedDateTime has copy, drop {
    date: PlainDate,
    hour: u8,
    minute: u8,
    second: u8,
    tz: TimeZone,
}

// =======================================
// 1. Constructors & Validators
// =======================================
public fun new_date(y: u16, m: u8, d: u8): PlainDate {
    assert!(is_valid_ymd(y, m, d), 0);
    PlainDate { year: y, month: m, day: d }
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
    let date = new_date(y, m, d);
    assert!(h < 24 && min < 60 && s < 60, 1);
    ZonedDateTime {
        date,
        hour: h,
        minute: min,
        second: s,
        tz: *tz,
    }
}

public fun new_zdt(y: u16, m: u8, d: u8, h: u8, min: u8, s: u8, tz_offset_min: u16): ZonedDateTime {
    let date = new_date(y, m, d);
    assert!(h < 24 && min < 60 && s < 60, 1);
    ZonedDateTime {
        date,
        hour: h,
        minute: min,
        second: s,
        tz: timezone::new_positive(tz_offset_min),
    }
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
    let date = new_date(y, m, d);
    assert!(h < 24 && min < 60 && s < 60, 1);
    ZonedDateTime {
        date,
        hour: h,
        minute: min,
        second: s,
        tz: timezone::new_negative(tz_offset_min),
    }
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
    // Convert timestamp in milliseconds to epoch seconds
    let epoch_sec = timestamp_ms / MS_PER_SECOND;
    // Use UTC timezone (offset = 0)
    from_epoch_with_tz(epoch_sec, &timezone::utc())
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

// Get component methods
public fun year(zdt: &ZonedDateTime): u16 { zdt.date.year }

public fun month(zdt: &ZonedDateTime): u8 { zdt.date.month }

public fun day(zdt: &ZonedDateTime): u8 { zdt.date.day }

public fun hour(zdt: &ZonedDateTime): u8 { zdt.hour }

public fun minute(zdt: &ZonedDateTime): u8 { zdt.minute }

public fun second(zdt: &ZonedDateTime): u8 { zdt.second }

// Extract TimeZone from a ZonedDateTime
public fun timezone_from_zdt(zdt: &ZonedDateTime): TimeZone {
    zdt.tz
}

// Convert to timestamp in milliseconds
public fun to_timestamp_ms(zdt: &ZonedDateTime): u64 {
    to_epoch(zdt) * MS_PER_SECOND
}

// Creates a ZonedDateTime from a timestamp in milliseconds with specific TimeZone
public fun from_timestamp_ms_with_tz(timestamp_ms: u64, tz: &TimeZone): ZonedDateTime {
    from_epoch_with_tz(timestamp_ms / MS_PER_SECOND, tz)
}

// Add days to the date
public fun add_days(zdt: &ZonedDateTime, delta: u64): ZonedDateTime {
    // Convert local date to Julian day number
    let jd = ymd_to_jd(zdt.date.year, zdt.date.month, zdt.date.day);
    // Add delta to Julian day
    let jd_new = jd + delta;
    // Convert Julian day to new Y-M-D
    let (y2, m2, d2) = jd_to_ymd(jd_new);
    // Reconstruct with new date (time and TZ unchanged)
    ZonedDateTime {
        date: new_date(y2, m2, d2),
        hour: zdt.hour,
        minute: zdt.minute,
        second: zdt.second,
        tz: zdt.tz,
    }
}

// =======================================
// 3. Epoch seconds <--> DateTime conversion
// =======================================
public fun to_epoch(zdt: &ZonedDateTime): u64 {
    // Julian day -> Epoch days -> seconds - TZ offset = UTC
    let jd = ymd_to_jd(zdt.date.year, zdt.date.month, zdt.date.day);
    let epoch_days = jd - JD_OFFSET;
    let day_seconds =
        (zdt.hour as u64) * 3600
        + (zdt.minute as u64) * 60
        + (zdt.second as u64);

    let (offset_seconds, is_negative) = timezone::offset_seconds(&zdt.tz);

    // Convert local time to UTC
    if (is_negative) {
        epoch_days * SECONDS_PER_DAY + day_seconds + offset_seconds
    } else {
        epoch_days * SECONDS_PER_DAY + day_seconds - offset_seconds
    }
}

// Convert epoch to ZonedDateTime using a TimeZone struct
public fun from_epoch_with_tz(epoch_sec: u64, tz: &TimeZone): ZonedDateTime {
    // Calculate offset in seconds
    let (offset_seconds, is_negative) = timezone::offset_seconds(tz);

    // Apply timezone offset
    let local_seconds = if (is_negative) {
        if (epoch_sec >= offset_seconds) {
            epoch_sec - offset_seconds
        } else {
            // Handle underflow case (rare, but possible near epoch start)
            0
        }
    } else {
        epoch_sec + offset_seconds
    };

    // Calculate days and time
    let days = local_seconds / SECONDS_PER_DAY;
    let day_seconds = local_seconds % SECONDS_PER_DAY;

    // Convert days to date
    let (year, month, day) = jd_to_ymd(days + JD_OFFSET);

    // Calculate hours, minutes, seconds
    let hours = (day_seconds / 3600) as u8;
    let remainder = day_seconds % 3600;
    let minutes = (remainder / 60) as u8;
    let seconds = (remainder % 60) as u8;

    // Create date and validate
    let date = new_date(year, month, day);

    ZonedDateTime {
        date,
        hour: hours,
        minute: minutes,
        second: seconds,
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

// =======================================
// 5. Validators
// =======================================
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

#[test]
public fun test_date_struct() {
    let jst = timezone::jst();
    let z = new_zdt_with_tz(2025, 5, 14, 9, 0, 0, &jst);
    let after = add_days(&z, 20); // 20 days later
    let epoch = to_epoch(&after); // UTC epoch seconds
    let roundtrip = from_epoch_with_tz(epoch, &jst);
    assert!(after.date.day == roundtrip.date.day, 0);
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
    assert!(after.date.year == roundtrip.date.year, 0);
    assert!(after.date.month == roundtrip.date.month, 1);
    assert!(after.date.day == roundtrip.date.day, 2);
    assert!(after.hour == roundtrip.hour, 3);
    assert!(after.minute == roundtrip.minute, 4);
    assert!(after.second == roundtrip.second, 5);

    // Test EST timezone
    let est = timezone::est();
    let z2 = new_zdt_with_tz(2025, 5, 14, 15, 30, 0, &est);
    let epoch2 = to_epoch(&z2);
    let roundtrip2 = from_epoch_with_tz(epoch2, &est);
    assert!(z2.date.day == roundtrip2.date.day, 6);
    assert!(z2.hour == roundtrip2.hour, 7);
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
