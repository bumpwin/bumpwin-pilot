module daymove::daymove;

use daymove::helpers;
use daymove::timezone::{Self, TimeZone};

// Error codes
const EInvalidDate: u64 = 1;
const EInvalidTime: u64 = 2;
const EPreUnixEpochDate: u64 = 3;

// New ZonedDateTime structure that stores timestamp_ms and timezone
public struct ZonedDateTime has copy, drop {
    timestamp_ms: u64,
    tz: TimeZone,
}

// =======================================
// 1. Constructors
// =======================================

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
    assert!(helpers::is_valid_ymd(y, m, d), EInvalidDate);
    assert!(h < 24 && min < 60 && s < 60, EInvalidTime);

    // Check if the date is before Unix epoch (1970-01-01)
    assert!(y > 1970 || (y == 1970 && (m > 1 || (m == 1 && d >= 1))), EPreUnixEpochDate);

    // Convert to Julian day
    let jd = helpers::ymd_to_jd(y, m, d);

    // Calculate epoch days and seconds within the day
    let epoch_days = jd - helpers::jd_unix_epoch();
    let day_seconds = (h as u64) * 3600 + (min as u64) * 60 + (s as u64);

    // Calculate UTC timestamp
    let local_seconds = epoch_days * helpers::seconds_per_day() + day_seconds;

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
    let timestamp_ms = utc_seconds * helpers::ms_per_second();

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
public fun from_unix_epoch_negative(unix_epoch_sec: u64, tz_offset_min: u16): ZonedDateTime {
    from_unix_epoch_with_tz(unix_epoch_sec, &timezone::new_negative(tz_offset_min))
}

// =======================================
// 2. Public API - Constructors with common timezones
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

// =======================================
// 3. Getters/Converters - Using method style with self
// =======================================

// Internal helper to decompose ZonedDateTime into components
fun decompose(self: &ZonedDateTime): (u16, u8, u8, u8, u8, u8) {
    let timestamp_ms = self.timestamp_ms;
    let utc_seconds = timestamp_ms / helpers::ms_per_second();

    // Apply timezone offset for local time
    let (offset_seconds, is_negative) = timezone::offset_seconds(&self.tz);
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
    let days = local_seconds / helpers::seconds_per_day();
    let day_seconds = local_seconds % helpers::seconds_per_day();

    // Convert to date and time components
    let (year, month, day) = helpers::jd_to_ymd(days + helpers::jd_unix_epoch());
    let hour = (day_seconds / 3600) as u8;
    let remainder = day_seconds % 3600;
    let minute = (remainder / 60) as u8;
    let second = (remainder % 60) as u8;

    (year, month, day, hour, minute, second)
}

// Get component methods
public fun year(self: &ZonedDateTime): u16 {
    let (y, _, _, _, _, _) = decompose(self);
    y
}

public fun month(self: &ZonedDateTime): u8 {
    let (_, m, _, _, _, _) = decompose(self);
    m
}

public fun day(self: &ZonedDateTime): u8 {
    let (_, _, d, _, _, _) = decompose(self);
    d
}

public fun hour(self: &ZonedDateTime): u8 {
    let (_, _, _, h, _, _) = decompose(self);
    h
}

public fun minute(self: &ZonedDateTime): u8 {
    let (_, _, _, _, m, _) = decompose(self);
    m
}

public fun second(self: &ZonedDateTime): u8 {
    let (_, _, _, _, _, s) = decompose(self);
    s
}

// Extract TimeZone from a ZonedDateTime
public fun timezone_from_zdt(self: &ZonedDateTime): TimeZone {
    self.tz
}

// Convert to timestamp in milliseconds
public fun to_timestamp_ms(self: &ZonedDateTime): u64 {
    self.timestamp_ms
}

// Creates a ZonedDateTime from a timestamp in milliseconds with specific TimeZone
public fun from_timestamp_ms_with_tz(timestamp_ms: u64, tz: &TimeZone): ZonedDateTime {
    ZonedDateTime {
        timestamp_ms,
        tz: *tz,
    }
}

// =======================================
// 4. Time arithmetic methods - Using method style with self
// =======================================

// Add operations
public fun add_days(self: &ZonedDateTime, delta: u64): ZonedDateTime {
    // Simply add days worth of milliseconds
    let new_timestamp = self.timestamp_ms + (delta * helpers::ms_per_day());

    ZonedDateTime {
        timestamp_ms: new_timestamp,
        tz: self.tz,
    }
}

public fun add_hours(self: &ZonedDateTime, delta: u64): ZonedDateTime {
    let new_timestamp = self.timestamp_ms + (delta * helpers::ms_per_hour());

    ZonedDateTime {
        timestamp_ms: new_timestamp,
        tz: self.tz,
    }
}

public fun add_minutes(self: &ZonedDateTime, delta: u64): ZonedDateTime {
    let new_timestamp = self.timestamp_ms + (delta * helpers::ms_per_minute());

    ZonedDateTime {
        timestamp_ms: new_timestamp,
        tz: self.tz,
    }
}

public fun add_seconds(self: &ZonedDateTime, delta: u64): ZonedDateTime {
    let new_timestamp = self.timestamp_ms + (delta * helpers::ms_per_second());

    ZonedDateTime {
        timestamp_ms: new_timestamp,
        tz: self.tz,
    }
}

public fun add_milliseconds(self: &ZonedDateTime, delta: u64): ZonedDateTime {
    let new_timestamp = self.timestamp_ms + delta;

    ZonedDateTime {
        timestamp_ms: new_timestamp,
        tz: self.tz,
    }
}

// Subtract operations
public fun sub_days(self: &ZonedDateTime, delta: u64): ZonedDateTime {
    // Handle underflow
    let ms_delta = delta * helpers::ms_per_day();
    let new_timestamp = if (self.timestamp_ms >= ms_delta) {
        self.timestamp_ms - ms_delta
    } else {
        0
    };

    ZonedDateTime {
        timestamp_ms: new_timestamp,
        tz: self.tz,
    }
}

public fun sub_hours(self: &ZonedDateTime, delta: u64): ZonedDateTime {
    let ms_delta = delta * helpers::ms_per_hour();
    let new_timestamp = if (self.timestamp_ms >= ms_delta) {
        self.timestamp_ms - ms_delta
    } else {
        0
    };

    ZonedDateTime {
        timestamp_ms: new_timestamp,
        tz: self.tz,
    }
}

public fun sub_minutes(self: &ZonedDateTime, delta: u64): ZonedDateTime {
    let ms_delta = delta * helpers::ms_per_minute();
    let new_timestamp = if (self.timestamp_ms >= ms_delta) {
        self.timestamp_ms - ms_delta
    } else {
        0
    };

    ZonedDateTime {
        timestamp_ms: new_timestamp,
        tz: self.tz,
    }
}

public fun sub_seconds(self: &ZonedDateTime, delta: u64): ZonedDateTime {
    let ms_delta = delta * helpers::ms_per_second();
    let new_timestamp = if (self.timestamp_ms >= ms_delta) {
        self.timestamp_ms - ms_delta
    } else {
        0
    };

    ZonedDateTime {
        timestamp_ms: new_timestamp,
        tz: self.tz,
    }
}

public fun sub_milliseconds(self: &ZonedDateTime, delta: u64): ZonedDateTime {
    let new_timestamp = if (self.timestamp_ms >= delta) {
        self.timestamp_ms - delta
    } else {
        0
    };

    ZonedDateTime {
        timestamp_ms: new_timestamp,
        tz: self.tz,
    }
}

// =======================================
// 5. Epoch seconds <--> DateTime conversion
// =======================================
public fun to_unix_epoch(self: &ZonedDateTime): u64 {
    self.timestamp_ms / helpers::ms_per_second()
}

// Convert epoch to ZonedDateTime using a TimeZone struct
public fun from_unix_epoch_with_tz(unix_epoch_sec: u64, tz: &TimeZone): ZonedDateTime {
    ZonedDateTime {
        timestamp_ms: unix_epoch_sec * helpers::ms_per_second(),
        tz: *tz,
    }
}

public fun from_unix_epoch(unix_epoch_sec: u64, tz_offset_min: u16): ZonedDateTime {
    from_unix_epoch_with_tz(unix_epoch_sec, &timezone::new_positive(tz_offset_min))
}

// =======================================
// 6. Additional utility methods
// =======================================

// Change the timezone of a ZonedDateTime without changing the actual moment in time
public fun with_timezone(self: &ZonedDateTime, tz: &TimeZone): ZonedDateTime {
    ZonedDateTime {
        timestamp_ms: self.timestamp_ms,
        tz: *tz,
    }
}

// Convert to UTC
public fun to_utc(self: &ZonedDateTime): ZonedDateTime {
    with_timezone(self, &timezone::utc())
}

// Convert to JST
public fun to_jst(self: &ZonedDateTime): ZonedDateTime {
    with_timezone(self, &timezone::jst())
}

// Convert to EST
public fun to_est(self: &ZonedDateTime): ZonedDateTime {
    with_timezone(self, &timezone::est())
}

// Convert to CET
public fun to_cet(self: &ZonedDateTime): ZonedDateTime {
    with_timezone(self, &timezone::cet())
}

// =======================================
// Tests
// =======================================
#[test]
public fun test_date_struct() {
    let jst = timezone::jst();
    let z = new_zdt_with_tz(2025, 5, 14, 9, 0, 0, &jst);
    let after = add_days(&z, 20); // 20 days later
    let epoch = to_unix_epoch(&after); // UTC epoch seconds
    let roundtrip = from_unix_epoch_with_tz(epoch, &jst);
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
    let epoch = to_unix_epoch(&after);
    let roundtrip = from_unix_epoch_with_tz(epoch, &jst);
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
    let epoch2 = to_unix_epoch(&z2);
    let roundtrip2 = from_unix_epoch_with_tz(epoch2, &est);
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
    let utc_epoch = to_unix_epoch(&utc_time);
    let jst_epoch = to_unix_epoch(&jst_time);
    let est_epoch = to_unix_epoch(&est_time);

    // Small error margin due to timezone differences
    let margin: u64 = 60; // 1 minute error margin

    // Test that all epochs are within margin of each other
    assert!(utc_epoch >= jst_epoch - margin && utc_epoch <= jst_epoch + margin, 0);
    assert!(utc_epoch >= est_epoch - margin && utc_epoch <= est_epoch + margin, 1);
}

#[test]
public fun test_add_sub_methods() {
    // Test addition methods
    let base = new_utc(2024, 1, 1, 0, 0, 0);

    // Add days
    let plus_days = add_days(&base, 5);
    assert!(day(&plus_days) == 6, 0);

    // Add hours
    let plus_hours = add_hours(&base, 48);
    assert!(day(&plus_hours) == 3, 1);

    // Add minutes
    let plus_minutes = add_minutes(&base, 120);
    assert!(hour(&plus_minutes) == 2, 2);

    // Add seconds
    let plus_seconds = add_seconds(&base, 3665); // 1 hour, 1 minute, 5 seconds
    assert!(hour(&plus_seconds) == 1, 3);
    assert!(minute(&plus_seconds) == 1, 4);
    assert!(second(&plus_seconds) == 5, 5);

    // Test subtraction methods
    let end_date = new_utc(2024, 1, 31, 12, 30, 45);

    // Subtract days
    let minus_days = sub_days(&end_date, 15);
    assert!(day(&minus_days) == 16, 6);

    // Subtract hours
    let minus_hours = sub_hours(&end_date, 24);
    assert!(day(&minus_hours) == 30, 7);

    // Subtract minutes
    let minus_minutes = sub_minutes(&end_date, 60);
    assert!(hour(&minus_minutes) == 11, 8);

    // Subtract seconds
    let minus_seconds = sub_seconds(&end_date, 3600);
    assert!(hour(&minus_seconds) == 11, 9);
    assert!(minute(&minus_seconds) == 30, 10);
}

#[test]
public fun test_timezone_conversion() {
    // Test timezone conversion methods
    let utc_date = new_utc(2024, 1, 1, 12, 0, 0);

    // Convert to JST (+9)
    let jst_date = to_jst(&utc_date);
    assert!(hour(&jst_date) == 21, 0); // UTC+9 -> 12h + 9h = 21h

    // Convert to EST (-5)
    let est_date = to_est(&utc_date);
    assert!(hour(&est_date) == 7, 1); // UTC-5 -> 12h - 5h = 7h

    // Convert back to UTC
    let back_to_utc = to_utc(&jst_date);
    assert!(hour(&back_to_utc) == 12, 2);

    // Ensure the underlying timestamp is unchanged
    assert!(to_timestamp_ms(&utc_date) == to_timestamp_ms(&jst_date), 3);
    assert!(to_timestamp_ms(&utc_date) == to_timestamp_ms(&est_date), 4);
}

#[test]
#[expected_failure(abort_code = EPreUnixEpochDate)]
public fun test_pre_epoch_date() {
    // This should fail because it's before Unix epoch
    let _pre_epoch = new_utc(1969, 7, 20, 20, 17, 40);
}
