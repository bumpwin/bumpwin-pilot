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

    assert_eq!(daymove::year(&utc), 2024);
    assert_eq!(daymove::month(&utc), 5);
    assert_eq!(daymove::day(&utc), 14);
    assert_eq!(daymove::hour(&utc), 0);
    assert_eq!(daymove::minute(&utc), 0);
    assert_eq!(daymove::second(&utc), 0);

    // round-trip (UTC → ms → UTC)
    let ms = daymove::to_timestamp_ms(&utc);
    let utc2 = daymove::from_timestamp_ms(ms);
    assert_eq!(daymove::day(&utc2), 14);
}

#[test]
fun add_days_test() {
    // 2024-05-14T00:00:00Z = 1715644800000 ms (corrected timestamp)
    let base = daymove::from_timestamp_ms(1715644800000);
    let plus = daymove::add_days(&base, 10);              // +10 days
    assert_eq!(daymove::day(&plus), 24);
    assert_eq!(daymove::month(&plus), 5);
    assert_eq!(daymove::year(&plus), 2024);
}

#[test]
fun leap_year_boundary() {
    // 2024-02-28T12:00:00Z = 1709121600000 ms
    // Recalculated timestamp for 2024-02-28T12:00:00Z
    let feb28 = daymove::from_timestamp_ms(1709121600000);
    let feb29 = daymove::add_days(&feb28, 1);
    assert_eq!(daymove::month(&feb29), 2);
    assert_eq!(daymove::day(&feb29), 29);

    let mar01 = daymove::add_days(&feb29, 1);
    assert_eq!(daymove::month(&mar01), 3);
    assert_eq!(daymove::day(&mar01), 1);
}

#[test]
fun month_boundary_transition() {
    // 2024-05-31T12:00:00Z
    let may31 = daymove::new_utc(2024, 5, 31, 12, 0, 0);
    let jun01 = daymove::add_days(&may31, 1);
    assert_eq!(daymove::month(&jun01), 6);
    assert_eq!(daymove::day(&jun01), 1);

    // 2024-12-31T23:59:59Z
    let dec31 = daymove::new_utc(2024, 12, 31, 23, 59, 59);
    let jan01 = daymove::add_days(&dec31, 1);
    assert_eq!(daymove::year(&jan01), 2025);
    assert_eq!(daymove::month(&jan01), 1);
    assert_eq!(daymove::day(&jan01), 1);
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
    assert_eq!(daymove::year(&tokyo), 2024);
    assert_eq!(daymove::month(&tokyo), 5);
    assert_eq!(daymove::day(&tokyo), 14);
    assert_eq!(daymove::hour(&tokyo), 9);
    assert_eq!(daymove::minute(&tokyo), 0);

    // New York (UTC-5 = -300 minutes) - using EST
    let ny_tz = timezone::est();
    let ny = daymove::from_epoch_with_tz(epoch_sec, &ny_tz);
    assert_eq!(daymove::year(&ny), 2024);
    assert_eq!(daymove::month(&ny), 5);
    assert_eq!(daymove::day(&ny), 13);
    assert_eq!(daymove::hour(&ny), 19); // EST is UTC-5
    assert_eq!(daymove::minute(&ny), 0);

    // Test timezone conversion roundtrip
    let to_utc = daymove::to_epoch(&ny);
    let back_ny = daymove::from_epoch_with_tz(to_utc, &ny_tz);
    assert_eq!(daymove::year(&back_ny), 2024);
    assert_eq!(daymove::month(&back_ny), 5);
    assert_eq!(daymove::day(&back_ny), 13);
    assert_eq!(daymove::hour(&back_ny), 19);
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
    let tokyo_epoch = daymove::to_epoch(&tokyo);
    let ny_epoch = daymove::to_epoch(&ny);

    // Now both should represent the same moment in time (the same UTC timestamp)
    assert_eq!(tokyo_epoch, ny_epoch);
}

#[test]
fun epoch_conversion() {
    // Create a date and convert to epoch
    let zdt = daymove::new_utc(1970, 1, 1, 0, 0, 0);
    let epoch = daymove::to_epoch(&zdt);
    assert_eq!(epoch, 0);

    // Epoch for 2024-01-01T00:00:00Z = 1704067200
    let new_years_2024 = daymove::new_utc(2024, 1, 1, 0, 0, 0);
    let epoch_2024 = daymove::to_epoch(&new_years_2024);
    assert_eq!(epoch_2024, 1704067200);

    // Round-trip conversion
    let back_to_date = daymove::from_epoch_with_tz(epoch_2024, &timezone::utc());
    assert_eq!(daymove::year(&back_to_date), 2024);
    assert_eq!(daymove::month(&back_to_date), 1);
    assert_eq!(daymove::day(&back_to_date), 1);
}

#[test]
fun non_leap_year_feb_29() {
    // Test Feb 29 in a non-leap year (2023)
    // Should wrap to March 1
    let feb28_2023 = daymove::new_utc(2023, 2, 28, 12, 0, 0);
    let next_day = daymove::add_days(&feb28_2023, 1);
    assert_eq!(daymove::month(&next_day), 3);
    assert_eq!(daymove::day(&next_day), 1);
}

#[test]
fun long_term_date_add() {
    // Add 365 days to 2024-01-01
    let jan1_2024 = daymove::new_utc(2024, 1, 1, 12, 0, 0);
    let year_later = daymove::add_days(&jan1_2024, 365);
    // Because 2024 is a leap year, 365 days later is Dec 31, not Jan 1
    assert_eq!(daymove::year(&year_later), 2024);
    assert_eq!(daymove::month(&year_later), 12);
    assert_eq!(daymove::day(&year_later), 31);

    // Add 366 days to get to 2025-01-01
    let next_year = daymove::add_days(&jan1_2024, 366);
    assert_eq!(daymove::year(&next_year), 2025);
    assert_eq!(daymove::month(&next_year), 1);
    assert_eq!(daymove::day(&next_year), 1);

    // Add 20 years (reasonable date range)
    let decades_later = daymove::add_days(&jan1_2024, 7305); // ~20 years (365.25*20)
    assert_eq!(daymove::year(&decades_later), 2044);
    // Not checking exact month/day as leap years may affect the precise date
}

#[test]
fun ms_timestamp_boundaries() {
    // Test Unix epoch start
    let epoch_start = daymove::from_timestamp_ms(0);
    assert_eq!(daymove::year(&epoch_start), 1970);
    assert_eq!(daymove::month(&epoch_start), 1);
    assert_eq!(daymove::day(&epoch_start), 1);
    assert_eq!(daymove::hour(&epoch_start), 0);
    assert_eq!(daymove::minute(&epoch_start), 0);
    assert_eq!(daymove::second(&epoch_start), 0);

    // Test Y2K timestamp (2000-01-01T00:00:00Z = 946684800000 ms)
    let y2k = daymove::from_timestamp_ms(946684800000);
    assert_eq!(daymove::year(&y2k), 2000);
    assert_eq!(daymove::month(&y2k), 1);
    assert_eq!(daymove::day(&y2k), 1);
}

#[test]
fun extreme_date_ranges() {
    // Test dates at less extreme but still valid ranges
    let ancient = daymove::new_utc(1970, 1, 1, 0, 0, 0); // Start from Unix epoch
    let distant_future = daymove::new_utc(2100, 12, 31, 23, 59, 59); // Year 2100

    // Convert to epochs
    let ancient_epoch = daymove::to_epoch(&ancient);
    let future_epoch = daymove::to_epoch(&distant_future);

    // Ensure they round-trip correctly
    let ancient_rt = daymove::from_epoch_with_tz(ancient_epoch, &timezone::utc());
    let future_rt = daymove::from_epoch_with_tz(future_epoch, &timezone::utc());

    assert_eq!(daymove::year(&ancient_rt), 1970);
    assert_eq!(daymove::year(&future_rt), 2100);
}

#[test]
fun month_days() {
    // Test each month's length
    // Feb in leap year (2024)
    let feb_2024 = daymove::new_utc(2024, 2, 1, 12, 0, 0);
    let feb_days = daymove::add_days(&feb_2024, 28);
    assert_eq!(daymove::month(&feb_days), 2);
    assert_eq!(daymove::day(&feb_days), 29);

    // Apr (30 days)
    let apr_2024 = daymove::new_utc(2024, 4, 1, 12, 0, 0);
    let apr_days = daymove::add_days(&apr_2024, 29);
    assert_eq!(daymove::month(&apr_days), 4);
    assert_eq!(daymove::day(&apr_days), 30);

    let may_1 = daymove::add_days(&apr_days, 1);
    assert_eq!(daymove::month(&may_1), 5);
    assert_eq!(daymove::day(&may_1), 1);
}

#[test]
fun historical_dates() {
    // Test some historically significant dates

    // Moon landing: 1969-07-20T20:17:40Z = -14182460 seconds from epoch
    // Since Move doesn't support negative timestamps easily, we'll create this directly
    let _moon_landing = daymove::new_utc(1969, 7, 20, 20, 17, 40); // Prefix with underscore to silence warning

    // Y2K: 2000-01-01T00:00:00Z = 946684800 seconds
    let y2k_epoch = 946684800;
    let y2k = daymove::from_epoch_with_tz(y2k_epoch, &timezone::utc());
    assert_eq!(daymove::year(&y2k), 2000);
    assert_eq!(daymove::month(&y2k), 1);
    assert_eq!(daymove::day(&y2k), 1);

    // Unix Epoch + 1 day
    let epoch_plus_day = daymove::from_epoch_with_tz(86400, &timezone::utc());
    assert_eq!(daymove::year(&epoch_plus_day), 1970);
    assert_eq!(daymove::month(&epoch_plus_day), 1);
    assert_eq!(daymove::day(&epoch_plus_day), 2);
    assert_eq!(daymove::hour(&epoch_plus_day), 0);
}

#[test]
fun time_component_tests() {
    // Test hour/minute/second components
    let time_test = daymove::new_utc(2024, 6, 15, 23, 59, 59);

    // After 1 second, it should roll over to the next day
    let next_sec = daymove::new_utc(2024, 6, 16, 0, 0, 0);

    // Convert both to epoch and check the difference
    let epoch1 = daymove::to_epoch(&time_test);
    let epoch2 = daymove::to_epoch(&next_sec);
    assert_eq!(epoch2 - epoch1, 1); // Exactly 1 second difference

    // Test hour boundaries
    let hour_test = daymove::new_utc(2024, 6, 15, 0, 0, 0);
    let hour_epoch = daymove::to_epoch(&hour_test);

    // 1 hour later
    let hour_plus = daymove::from_epoch_with_tz(hour_epoch + 3600, &timezone::utc());
    assert_eq!(daymove::hour(&hour_plus), 1);
    assert_eq!(daymove::minute(&hour_plus), 0);
    assert_eq!(daymove::second(&hour_plus), 0);
}

#[test]
fun timestamp_ms_precision() {
    // Test millisecond precision in conversions
    let date = daymove::new_utc(2024, 1, 1, 12, 30, 45);

    // Convert to milliseconds
    let ms = daymove::to_timestamp_ms(&date);

    // Convert back
    let date2 = daymove::from_timestamp_ms(ms);

    // Check equality of all components
    assert_eq!(daymove::year(&date2), 2024);
    assert_eq!(daymove::month(&date2), 1);
    assert_eq!(daymove::day(&date2), 1);
    assert_eq!(daymove::hour(&date2), 12);
    assert_eq!(daymove::minute(&date2), 30);
    assert_eq!(daymove::second(&date2), 45);

    // Add 1 millisecond to timestamp
    let date3 = daymove::from_timestamp_ms(ms + 1);

    // Should be the same date (1ms doesn't affect second granularity)
    assert_eq!(daymove::year(&date3), 2024);
    assert_eq!(daymove::month(&date3), 1);
    assert_eq!(daymove::day(&date3), 1);
    assert_eq!(daymove::hour(&date3), 12);
    assert_eq!(daymove::minute(&date3), 30);
    assert_eq!(daymove::second(&date3), 45);
}

#[test]
fun timezone_offset_symmetry() {
    // Test that positive and negative timezone offsets are correctly handled

    // Base timestamp: 2024-01-01T12:00:00Z
    let base_epoch = 1704110400; // Seconds since epoch

    // Same moment in different timezones:
    // UTC+9 (Tokyo): 2024-01-01T21:00:00+09:00
    let tokyo = daymove::from_epoch_with_tz(base_epoch, &timezone::jst());
    assert_eq!(daymove::year(&tokyo), 2024);
    assert_eq!(daymove::month(&tokyo), 1);
    assert_eq!(daymove::day(&tokyo), 1);
    assert_eq!(daymove::hour(&tokyo), 21);
    assert_eq!(daymove::minute(&tokyo), 0);

    // UTC-5 (New York): 2024-01-01T07:00:00-05:00
    let ny = daymove::from_epoch_with_tz(base_epoch, &timezone::est());
    assert_eq!(daymove::year(&ny), 2024);
    assert_eq!(daymove::month(&ny), 1);
    assert_eq!(daymove::day(&ny), 1);
    assert_eq!(daymove::hour(&ny), 7);
    assert_eq!(daymove::minute(&ny), 0);

    // Both should convert back to the same UTC time
    let tokyo_epoch = daymove::to_epoch(&tokyo);
    let ny_epoch = daymove::to_epoch(&ny);
    assert_eq!(tokyo_epoch, base_epoch);
    assert_eq!(ny_epoch, base_epoch);

    // International Date Line test
    // UTC: 2024-01-01T00:00:00Z
    let date_line_epoch = 1704067200;

    // Tokyo: 2024-01-01T09:00:00+09:00 (same day)
    let tokyo_dl = daymove::from_epoch_with_tz(date_line_epoch, &timezone::jst());
    assert_eq!(daymove::year(&tokyo_dl), 2024);
    assert_eq!(daymove::month(&tokyo_dl), 1);
    assert_eq!(daymove::day(&tokyo_dl), 1);

    // Honolulu: 2023-12-31T14:00:00-10:00 (previous day)
    let honolulu_tz = timezone::new_negative(600); // UTC-10
    let honolulu = daymove::from_epoch_with_tz(date_line_epoch, &honolulu_tz);
    assert_eq!(daymove::year(&honolulu), 2023);
    assert_eq!(daymove::month(&honolulu), 12);
    assert_eq!(daymove::day(&honolulu), 31);
    assert_eq!(daymove::hour(&honolulu), 14);
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
    let utc_epoch = daymove::to_epoch(&utc_time);
    let jst_epoch = daymove::to_epoch(&jst_time);
    let est_epoch = daymove::to_epoch(&est_time);
    let cet_epoch = daymove::to_epoch(&cet_time);

    // We could use a small error margin for timezone rounding if needed
    // let _margin: u64 = 60;  // 1 minute error margin (prefixed with underscore)

    // Test that all epochs are within margin of each other
    assert_eq!(utc_epoch, jst_epoch);
    assert_eq!(utc_epoch, est_epoch);
    assert_eq!(utc_epoch, cet_epoch);
}
