#[test_only]
module daymove::timezone_tests;

use daymove::daymove;
use daymove::utc_offset;
use std::unit_test::assert_eq;

#[test]
fun test_timezone_conversion() {
    // Create a UTC time (2023-01-01 12:00:00)
    let dt = daymove::new_utc(2023, 1, 1, 12, 0, 0);

    // The original time in UTC
    let y = daymove::year(&dt);
    let mo = daymove::month(&dt);
    let d = daymove::day(&dt);
    let h = daymove::hour(&dt);
    let mi = daymove::minute(&dt);
    let s = daymove::second(&dt);

    assert_eq!(y, 2023);
    assert_eq!(mo, 1);
    assert_eq!(d, 1);
    assert_eq!(h, 12);
    assert_eq!(mi, 0);
    assert_eq!(s, 0);

    // Convert to JST (+09:00)
    let jst_dt = daymove::with_timezone(&dt, &utc_offset::jst());

    // JST is 9 hours ahead of UTC
    let jst_h = daymove::hour(&jst_dt);
    assert_eq!(jst_h, 21);

    // Convert to EST (-05:00)
    let est_dt = daymove::with_timezone(&dt, &utc_offset::est());

    // EST is 5 hours behind UTC
    let est_h = daymove::hour(&est_dt);
    assert_eq!(est_h, 7);

    // Convert to CET (+01:00)
    let cet_dt = daymove::with_timezone(&dt, &utc_offset::cet());

    // CET is 1 hour ahead of UTC
    let cet_h = daymove::hour(&cet_dt);
    assert_eq!(cet_h, 13);
}

#[test]
fun test_saturating_subtraction() {
    // Create a time (2023-01-02 12:00:00)
    let dt = daymove::new_utc(2023, 1, 2, 12, 0, 0);

    // Subtract 1 day - should work normally
    let dt1 = daymove::sub_days(&dt, 1);
    let d1 = daymove::day(&dt1);
    assert_eq!(d1, 1);

    // Test timestamp_ms directly for saturating behavior
    let dt2 = daymove::new_utc(1971, 1, 1, 0, 0, 0);
    let _orig_ms = daymove::to_timestamp_ms(&dt2);

    // Try to subtract more days than available
    let huge_days = 1000;
    let dt3 = daymove::sub_days(&dt2, huge_days);
    let saturated_ms = daymove::to_timestamp_ms(&dt3);

    // Verify saturating behavior (should be 0 or very close to 0)
    assert_eq!(saturated_ms, 0);
}
