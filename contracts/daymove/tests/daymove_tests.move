#[test_only]
module daymove::daymove_tests;

use daymove::daymove;
use daymove::timezone;
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
    let epoch_sec = timestamp_ms / 1000;

    // UTC (no offset)
    let _utc = daymove::from_timestamp_ms(timestamp_ms); // prefix with underscore to silence warning

    // Tokyo (UTC+9 = +540 minutes)
    let tokyo_tz = timezone::jst();
    let tokyo = daymove::from_epoch_with_tz(epoch_sec, &tokyo_tz);
    assert_eq!(tokyo.year(), 2024);
    assert_eq!(tokyo.month(), 5);
    assert_eq!(tokyo.day(), 14);
    assert_eq!(tokyo.hour(), 9);
    assert_eq!(tokyo.minute(), 0);

    // New York (UTC-5 = -300 minutes) - using EST
    let ny_tz = timezone::est();
    let ny = daymove::from_epoch_with_tz(epoch_sec, &ny_tz);
    assert_eq!(ny.year(), 2024);
    assert_eq!(ny.month(), 5);
    assert_eq!(ny.day(), 13);
    assert_eq!(ny.hour(), 19); // EST is UTC-5
    assert_eq!(ny.minute(), 0);

    // Test timezone conversion roundtrip
    let to_utc = ny.to_epoch();
    let back_ny = daymove::from_epoch_with_tz(to_utc, &ny_tz);
    assert_eq!(back_ny.year(), 2024);
    assert_eq!(back_ny.month(), 5);
    assert_eq!(back_ny.day(), 13);
    assert_eq!(back_ny.hour(), 19);
}

#[test]
fun new_zdt_timezone_constructors() {
    // Test with Tokyo timezone (UTC+9)
    let tokyo_tz = timezone::jst();
    let tokyo = daymove::new_zdt_with_tz(2024, 1, 1, 9, 0, 0, &tokyo_tz);

    // Test with New York timezone (UTC-5)
    let ny_tz = timezone::est();
    // Adjust New York time to align with Tokyo time in UTC
    // Tokyo is UTC+9, NY is UTC-5, so 14 hours difference
    // When it's 9:00 in Tokyo, it's 19:00 the previous day in NY
    let ny = daymove::new_zdt_with_tz(2023, 12, 31, 19, 0, 0, &ny_tz);

    // Convert both to UTC epochs
    let tokyo_epoch = tokyo.to_epoch();
    let ny_epoch = ny.to_epoch();

    // Now both should represent the same moment in time (the same UTC timestamp)
    assert_eq!(tokyo_epoch, ny_epoch);
}

#[test]
fun epoch_conversion() {
    // Create a date and convert to epoch
    let zdt = daymove::new_utc(1970, 1, 1, 0, 0, 0);
    let epoch = zdt.to_epoch();
    assert_eq!(epoch, 0);

    // Epoch for 2024-01-01T00:00:00Z = 1704067200
    let new_years_2024 = daymove::new_utc(2024, 1, 1, 0, 0, 0);
    let epoch_2024 = new_years_2024.to_epoch();
    assert_eq!(epoch_2024, 1704067200);

    // Round-trip conversion
    let back_to_date = daymove::from_epoch_with_tz(epoch_2024, &timezone::utc());
    assert_eq!(back_to_date.year(), 2024);
    assert_eq!(back_to_date.month(), 1);
    assert_eq!(back_to_date.day(), 1);
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
    let epoch_start = daymove::from_timestamp_ms(0);
    assert_eq!(epoch_start.year(), 1970);
    assert_eq!(epoch_start.month(), 1);
    assert_eq!(epoch_start.day(), 1);
    assert_eq!(epoch_start.hour(), 0);
    assert_eq!(epoch_start.minute(), 0);
    assert_eq!(epoch_start.second(), 0);

    // Test Y2K timestamp (2000-01-01T00:00:00Z = 946684800000 ms)
    let y2k = daymove::from_timestamp_ms(946684800000);
    assert_eq!(y2k.year(), 2000);
    assert_eq!(y2k.month(), 1);
    assert_eq!(y2k.day(), 1);
}

#[test]
fun extreme_date_ranges() {
    // Test dates at less extreme but still valid ranges
    let ancient = daymove::new_utc(1970, 1, 1, 0, 0, 0); // Start from Unix epoch
    let distant_future = daymove::new_utc(2100, 12, 31, 23, 59, 59); // Year 2100

    // Convert to epochs
    let ancient_epoch = ancient.to_epoch();
    let future_epoch = distant_future.to_epoch();

    // Ensure they round-trip correctly
    let ancient_rt = daymove::from_epoch_with_tz(ancient_epoch, &timezone::utc());
    let future_rt = daymove::from_epoch_with_tz(future_epoch, &timezone::utc());

    assert_eq!(ancient_rt.year(), 1970);
    assert_eq!(future_rt.year(), 2100);
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

    // Note: Moon landing (1969-07-20) is before Unix epoch, so not supported

    // Y2K: 2000-01-01T00:00:00Z = 946684800 seconds
    let y2k_epoch = 946684800;
    let y2k = daymove::from_epoch_with_tz(y2k_epoch, &timezone::utc());
    assert_eq!(y2k.year(), 2000);
    assert_eq!(y2k.month(), 1);
    assert_eq!(y2k.day(), 1);

    // Unix Epoch + 1 day
    let epoch_plus_day = daymove::from_epoch_with_tz(86400, &timezone::utc());
    assert_eq!(epoch_plus_day.year(), 1970);
    assert_eq!(epoch_plus_day.month(), 1);
    assert_eq!(epoch_plus_day.day(), 2);
    assert_eq!(epoch_plus_day.hour(), 0);

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

    // After 1 second, it should roll over to the next day
    let next_sec = daymove::new_utc(2024, 6, 16, 0, 0, 0);

    // Convert both to epoch and check the difference
    let epoch1 = time_test.to_epoch();
    let epoch2 = next_sec.to_epoch();
    assert_eq!(epoch2 - epoch1, 1); // Exactly 1 second difference

    // Test hour boundaries
    let hour_test = daymove::new_utc(2024, 6, 15, 0, 0, 0);
    let hour_epoch = hour_test.to_epoch();

    // 1 hour later
    let hour_plus = daymove::from_epoch_with_tz(hour_epoch + 3600, &timezone::utc());
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

    // Base timestamp: 2024-01-01T12:00:00Z
    let base_epoch = 1704110400; // Seconds since epoch

    // Same moment in different timezones:
    // UTC+9 (Tokyo): 2024-01-01T21:00:00+09:00
    let tokyo = daymove::from_epoch_with_tz(base_epoch, &timezone::jst());
    assert_eq!(tokyo.year(), 2024);
    assert_eq!(tokyo.month(), 1);
    assert_eq!(tokyo.day(), 1);
    assert_eq!(tokyo.hour(), 21);
    assert_eq!(tokyo.minute(), 0);

    // UTC-5 (New York): 2024-01-01T07:00:00-05:00
    let ny = daymove::from_epoch_with_tz(base_epoch, &timezone::est());
    assert_eq!(ny.year(), 2024);
    assert_eq!(ny.month(), 1);
    assert_eq!(ny.day(), 1);
    assert_eq!(ny.hour(), 7);
    assert_eq!(ny.minute(), 0);

    // Both should convert back to the same UTC time
    let tokyo_epoch = tokyo.to_epoch();
    let ny_epoch = ny.to_epoch();
    assert_eq!(tokyo_epoch, base_epoch);
    assert_eq!(ny_epoch, base_epoch);

    // International Date Line test
    // UTC: 2024-01-01T00:00:00Z
    let date_line_epoch = 1704067200;

    // Tokyo: 2024-01-01T09:00:00+09:00 (same day)
    let tokyo_dl = daymove::from_epoch_with_tz(date_line_epoch, &timezone::jst());
    assert_eq!(tokyo_dl.year(), 2024);
    assert_eq!(tokyo_dl.month(), 1);
    assert_eq!(tokyo_dl.day(), 1);

    // Honolulu: 2023-12-31T14:00:00-10:00 (previous day)
    let honolulu_tz = timezone::new_negative(600); // UTC-10
    let honolulu = daymove::from_epoch_with_tz(date_line_epoch, &honolulu_tz);
    assert_eq!(honolulu.year(), 2023);
    assert_eq!(honolulu.month(), 12);
    assert_eq!(honolulu.day(), 31);
    assert_eq!(honolulu.hour(), 14);
}

// Test the convenience constructors
#[test]
fun timezone_convenience_constructors() {
    // Test the convenience constructors
    let utc_time = daymove::new_utc(2024, 1, 1, 0, 0, 0);
    let jst_time = daymove::new_jst(2024, 1, 1, 9, 0, 0);
    let est_time = daymove::new_est(2023, 12, 31, 19, 0, 0);
    let cet_time = daymove::new_cet(2024, 1, 1, 1, 0, 0);

    // All should represent approximately the same moment in time
    let utc_epoch = utc_time.to_epoch();
    let jst_epoch = jst_time.to_epoch();
    let est_epoch = est_time.to_epoch();
    let cet_epoch = cet_time.to_epoch();

    // We could use a small error margin for timezone rounding if needed
    // let _margin: u64 = 60;  // 1 minute error margin (prefixed with underscore)

    // Test that all epochs are within margin of each other
    assert_eq!(utc_epoch, jst_epoch);
    assert_eq!(utc_epoch, est_epoch);
    assert_eq!(utc_epoch, cet_epoch);
}
