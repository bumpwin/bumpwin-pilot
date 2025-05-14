#[test_only]
module daymove::daymove_tests;

use daymove::daymove;
use daymove::utc_offset;
use std::unit_test::assert_eq;

/// Comprehensive test suite for UTC-based APIs and date calculations
#[test]
fun timestamp_roundtrip_and_components() {
    // 2024-05-14T00:00:00Z = 1715644800000 ms (corrected timestamp)
    let utc = daymove::from_timestamp_ms(1715644800000);

    assert_eq!(utc.year(), 2024);
    assert_eq!(utc.month(), 5);
    assert_eq!(utc.day(), 14);
    assert_eq!(utc.hour(), 0);
    assert_eq!(utc.minute(), 0);
    assert_eq!(utc.second(), 0);

    // round-trip (UTC → ms → UTC)
    let ms = utc.to_timestamp_ms();
    let utc2 = daymove::from_timestamp_ms(ms);
    assert_eq!(utc2.day(), 14);
}

#[test]
fun add_days_test() {
    // 2024-05-14T00:00:00Z = 1715644800000 ms (corrected timestamp)
    let base = daymove::from_timestamp_ms(1715644800000);
    let plus = base.add_days(10); // +10 days
    assert_eq!(plus.day(), 24);
    assert_eq!(plus.month(), 5);
    assert_eq!(plus.year(), 2024);
}

#[test]
fun leap_year_boundary() {
    // 2024-02-28T12:00:00Z = 1709121600000 ms
    // Recalculated timestamp for 2024-02-28T12:00:00Z
    let feb28 = daymove::from_timestamp_ms(1709121600000);
    let feb29 = feb28.add_days(1);
    assert_eq!(feb29.month(), 2);
    assert_eq!(feb29.day(), 29);

    let mar01 = feb29.add_days(1);
    assert_eq!(mar01.month(), 3);
    assert_eq!(mar01.day(), 1);
}

#[test]
fun month_boundary_transition() {
    // 2024-05-31T12:00:00Z
    let may31 = daymove::new_utc(2024, 5, 31, 12, 0, 0);
    let jun01 = may31.add_days(1);
    assert_eq!(jun01.month(), 6);
    assert_eq!(jun01.day(), 1);

    // 2024-12-31T23:59:59Z
    let dec31 = daymove::new_utc(2024, 12, 31, 23, 59, 59);
    let jan01 = dec31.add_days(1);
    assert_eq!(jan01.year(), 2025);
    assert_eq!(jan01.month(), 1);
    assert_eq!(jan01.day(), 1);
}

#[test]
fun timezone_offsets() {
    // Test UTC timestamp in different time zones
    // 2024-05-14T00:00:00Z = 1715644800000 ms (corrected timestamp)
    let timestamp_ms = 1715644800000;

    // UTC (no offset)
    let _utc = daymove::from_timestamp_ms(timestamp_ms); // prefix with underscore to silence warning

    // Tokyo (UTC+9 = +540 minutes)
    let tokyo_tz = utc_offset::jst();
    let utc_dt = daymove::from_timestamp_ms(timestamp_ms);
    let tokyo = utc_dt.to_offset(&tokyo_tz);
    assert_eq!(tokyo.year(), 2024);
    assert_eq!(tokyo.month(), 5);
    assert_eq!(tokyo.day(), 14);
    assert_eq!(tokyo.hour(), 9);
    assert_eq!(tokyo.minute(), 0);

    // New York (UTC-5 = -300 minutes) - using EST
    let ny_tz = utc_offset::est();
    let ny = utc_dt.to_offset(&ny_tz);
    assert_eq!(ny.year(), 2024);
    assert_eq!(ny.month(), 5);
    assert_eq!(ny.day(), 13);
    assert_eq!(ny.hour(), 19); // EST is UTC-5
    assert_eq!(ny.minute(), 0);
}

#[test]
fun non_leap_year_feb_29() {
    // Test Feb 29 in a non-leap year (2023)
    // Should wrap to March 1
    let feb28_2023 = daymove::new_utc(2023, 2, 28, 12, 0, 0);
    let next_day = feb28_2023.add_days(1);
    assert_eq!(next_day.month(), 3);
    assert_eq!(next_day.day(), 1);
}

#[test]
fun long_term_date_add() {
    // Add 365 days to 2024-01-01
    let jan1_2024 = daymove::new_utc(2024, 1, 1, 12, 0, 0);
    let year_later = jan1_2024.add_days(365);
    // Because 2024 is a leap year, 365 days later is Dec 31, not Jan 1
    assert_eq!(year_later.year(), 2024);
    assert_eq!(year_later.month(), 12);
    assert_eq!(year_later.day(), 31);

    // Add 366 days to get to 2025-01-01
    let next_year = jan1_2024.add_days(366);
    assert_eq!(next_year.year(), 2025);
    assert_eq!(next_year.month(), 1);
    assert_eq!(next_year.day(), 1);

    // Add 20 years (reasonable date range)
    let decades_later = jan1_2024.add_days(7305); // ~20 years (365.25*20)
    assert_eq!(decades_later.year(), 2044);
    // Not checking exact month/day as leap years may affect the precise date
}

#[test]
fun ms_timestamp_boundaries() {
    // Test Unix epoch start
    let unix_epoch_start = daymove::from_timestamp_ms(0);
    assert_eq!(unix_epoch_start.year(), 1970);
    assert_eq!(unix_epoch_start.month(), 1);
    assert_eq!(unix_epoch_start.day(), 1);
    assert_eq!(unix_epoch_start.hour(), 0);
    assert_eq!(unix_epoch_start.minute(), 0);
    assert_eq!(unix_epoch_start.second(), 0);

    // Test Y2K timestamp (2000-01-01T00:00:00Z = 946684800000 ms)
    let y2k = daymove::from_timestamp_ms(946684800000);
    assert_eq!(y2k.year(), 2000);
    assert_eq!(y2k.month(), 1);
    assert_eq!(y2k.day(), 1);
}

#[test]
fun month_days() {
    // Test each month's length
    // Feb in leap year (2024)
    let feb_2024 = daymove::new_utc(2024, 2, 1, 12, 0, 0);
    let feb_days = feb_2024.add_days(28);
    assert_eq!(feb_days.month(), 2);
    assert_eq!(feb_days.day(), 29);

    // Apr (30 days)
    let apr_2024 = daymove::new_utc(2024, 4, 1, 12, 0, 0);
    let apr_days = apr_2024.add_days(29);
    assert_eq!(apr_days.month(), 4);
    assert_eq!(apr_days.day(), 30);

    let may_1 = apr_days.add_days(1);
    assert_eq!(may_1.month(), 5);
    assert_eq!(may_1.day(), 1);
}

#[test]
fun historical_dates() {
    // Test some historically significant dates

    // Y2K: 2000-01-01T00:00:00Z
    let y2k_ms = 946684800000; // Y2K timestamp in ms
    let y2k = daymove::from_timestamp_ms(y2k_ms);
    assert_eq!(y2k.year(), 2000);
    assert_eq!(y2k.month(), 1);
    assert_eq!(y2k.day(), 1);

    // Unix Epoch + 1 day (86400000 ms = 1 day)
    let unix_epoch_plus_day = daymove::from_timestamp_ms(86400000);
    assert_eq!(unix_epoch_plus_day.year(), 1970);
    assert_eq!(unix_epoch_plus_day.month(), 1);
    assert_eq!(unix_epoch_plus_day.day(), 2);
    assert_eq!(unix_epoch_plus_day.hour(), 0);

    // Historical date: First iPhone release (2007-06-29)
    let iphone_release = daymove::new_utc(2007, 6, 29, 0, 0, 0);
    assert_eq!(iphone_release.year(), 2007);
    assert_eq!(iphone_release.month(), 6);
    assert_eq!(iphone_release.day(), 29);
}

#[test]
fun time_component_tests() {
    // Test hour/minute/second components
    let time_test = daymove::new_utc(2024, 6, 15, 23, 59, 59);
    let time_test_ms = time_test.to_timestamp_ms();

    // After 1 second, it should roll over to the next day
    let next_sec = daymove::new_utc(2024, 6, 16, 0, 0, 0);
    let next_sec_ms = next_sec.to_timestamp_ms();

    // Check the difference is 1000ms = 1 second
    assert_eq!(next_sec_ms - time_test_ms, 1000);

    // Test hour boundaries
    let hour_test = daymove::new_utc(2024, 6, 15, 0, 0, 0);
    let hour_ms = hour_test.to_timestamp_ms();

    // 1 hour later (3600000 ms = 1 hour)
    let hour_plus = daymove::from_timestamp_ms(hour_ms + 3600000);
    assert_eq!(hour_plus.hour(), 1);
    assert_eq!(hour_plus.minute(), 0);
    assert_eq!(hour_plus.second(), 0);
}

#[test]
fun timestamp_ms_precision() {
    // Test millisecond precision in conversions
    let date = daymove::new_utc(2024, 1, 1, 12, 30, 45);

    // Convert to milliseconds
    let ms = date.to_timestamp_ms();

    // Convert back
    let date2 = daymove::from_timestamp_ms(ms);

    // Check equality of all components
    assert_eq!(date2.year(), 2024);
    assert_eq!(date2.month(), 1);
    assert_eq!(date2.day(), 1);
    assert_eq!(date2.hour(), 12);
    assert_eq!(date2.minute(), 30);
    assert_eq!(date2.second(), 45);

    // Add 1 millisecond to timestamp
    let date3 = daymove::from_timestamp_ms(ms + 1);

    // Should be the same date (1ms doesn't affect second granularity)
    assert_eq!(date3.year(), 2024);
    assert_eq!(date3.month(), 1);
    assert_eq!(date3.day(), 1);
    assert_eq!(date3.hour(), 12);
    assert_eq!(date3.minute(), 30);
    assert_eq!(date3.second(), 45);
}

#[test]
fun timezone_offset_symmetry() {
    // Test that positive and negative timezone offsets are correctly handled

    // Base timestamp for 2024-01-01T12:00:00Z
    let base_ms = 1704110400000; // Milliseconds since epoch
    let base_dt = daymove::from_timestamp_ms(base_ms);

    // Same moment in different timezones:
    // UTC+9 (Tokyo): 2024-01-01T21:00:00+09:00
    let tokyo = base_dt.to_offset(&utc_offset::jst());
    assert_eq!(tokyo.year(), 2024);
    assert_eq!(tokyo.month(), 1);
    assert_eq!(tokyo.day(), 1);
    assert_eq!(tokyo.hour(), 21);
    assert_eq!(tokyo.minute(), 0);

    // UTC-5 (New York): 2024-01-01T07:00:00-05:00
    let ny = base_dt.to_offset(&utc_offset::est());
    assert_eq!(ny.year(), 2024);
    assert_eq!(ny.month(), 1);
    assert_eq!(ny.day(), 1);
    assert_eq!(ny.hour(), 7);
    assert_eq!(ny.minute(), 0);

    // Both should have the same underlying timestamp
    let tokyo_ms = tokyo.to_timestamp_ms();
    let ny_ms = ny.to_timestamp_ms();
    assert_eq!(tokyo_ms, base_ms);
    assert_eq!(ny_ms, base_ms);

    // International Date Line test
    // UTC: 2024-01-01T00:00:00Z
    let date_line_ms = 1704067200000;
    let date_line_dt = daymove::from_timestamp_ms(date_line_ms);

    // Tokyo: 2024-01-01T09:00:00+09:00 (same day)
    let tokyo_dl = date_line_dt.to_offset(&utc_offset::jst());
    assert_eq!(tokyo_dl.year(), 2024);
    assert_eq!(tokyo_dl.month(), 1);
    assert_eq!(tokyo_dl.day(), 1);

    // Honolulu: 2023-12-31T14:00:00-10:00 (previous day)
    let honolulu_tz = utc_offset::new_negative(600); // UTC-10
    let honolulu = date_line_dt.to_offset(&honolulu_tz);
    assert_eq!(honolulu.year(), 2023);
    assert_eq!(honolulu.month(), 12);
    assert_eq!(honolulu.day(), 31);
    assert_eq!(honolulu.hour(), 14);
}

#[test]
fun timezone_conversion_with_to_offset() {
    // Test timezone conversion using to_offset
    let utc_date = daymove::new_utc(2024, 1, 1, 12, 0, 0);

    // Convert to JST (+9)
    let jst_date = utc_date.to_offset(&utc_offset::jst());
    assert_eq!(jst_date.hour(), 21); // UTC+9 -> 12h + 9h = 21h

    // Convert to EST (-5)
    let est_date = utc_date.to_offset(&utc_offset::est());
    assert_eq!(est_date.hour(), 7); // UTC-5 -> 12h - 5h = 7h

    // Convert back to UTC
    let back_to_utc = jst_date.to_offset(&utc_offset::utc());
    assert_eq!(back_to_utc.hour(), 12);

    // Ensure the underlying timestamp is unchanged
    assert_eq!(utc_date.to_timestamp_ms(), jst_date.to_timestamp_ms());
    assert_eq!(utc_date.to_timestamp_ms(), est_date.to_timestamp_ms());
}

#[test]
#[expected_failure(abort_code = 3)]
fun test_pre_epoch_date() {
    // This should fail because it's before Unix epoch
    let _pre_epoch = daymove::new_utc(1969, 7, 20, 20, 17, 40);
}

#[test]
fun test_millisecond_precision() {
    // Test with specific millisecond values
    let base_ms = 1715644800123; // Some timestamp with milliseconds
    let dt = daymove::from_timestamp_ms(base_ms);

    // Verify millisecond part
    assert_eq!(dt.millisecond(), 123);

    // Add some milliseconds
    let dt2 = dt.add_milliseconds(456);
    assert_eq!(dt2.millisecond(), 579); // 123 + 456 = 579

    // Verify rollover when adding milliseconds
    let dt3 = dt.add_milliseconds(900);
    assert_eq!(dt3.millisecond(), 23); // 123 + 900 = 1023 -> 23ms
    assert_eq!(dt3.second(), dt.second() + 1); // And second incremented

    // Test nanosecond rounding (we don't store nanoseconds, just milliseconds)
    let dt4 = daymove::from_timestamp_ms(base_ms + 0); // Same millisecond
    let dt5 = daymove::from_timestamp_ms(base_ms + 1); // Next millisecond

    assert_eq!(dt4.millisecond(), 123);
    assert_eq!(dt5.millisecond(), 124);

    // Verify that to_timestamp_ms preserves milliseconds
    assert_eq!(dt.to_timestamp_ms(), base_ms);
}
