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
    let y = dt.year();
    let mo = dt.month();
    let d = dt.day();
    let h = dt.hour();
    let mi = dt.minute();
    let s = dt.second();

    assert_eq!(y, 2023);
    assert_eq!(mo, 1);
    assert_eq!(d, 1);
    assert_eq!(h, 12);
    assert_eq!(mi, 0);
    assert_eq!(s, 0);

    // Convert to JST (+09:00)
    let jst_dt = dt.to_offset(&utc_offset::jst());

    // JST is 9 hours ahead of UTC
    let jst_h = jst_dt.hour();
    assert_eq!(jst_h, 21);

    // Convert to EST (-05:00)
    let est_dt = dt.to_offset(&utc_offset::est());

    // EST is 5 hours behind UTC
    let est_h = est_dt.hour();
    assert_eq!(est_h, 7);

    // Convert to CET (+01:00)
    let cet_dt = dt.to_offset(&utc_offset::cet());

    // CET is 1 hour ahead of UTC
    let cet_h = cet_dt.hour();
    assert_eq!(cet_h, 13);
}

#[test]
fun test_subtraction_normal() {
    // Create a time (2023-01-02 12:00:00)
    let dt = daymove::new_utc(2023, 1, 2, 12, 0, 0);

    // Subtract 1 day - should work normally
    let dt1 = dt.sub_days(1);
    let d1 = dt1.day();
    assert_eq!(d1, 1);
}

#[test]
#[expected_failure(abort_code = 0x40001, location = std::option)]
fun test_underflow_aborts() {
    // Test timestamp_ms directly for underflow behavior
    let dt2 = daymove::new_utc(1971, 1, 1, 0, 0, 0);

    // Try to subtract more days than available
    let huge_days = 1000;
    let _dt3 = dt2.sub_days(huge_days);
    // This should abort with option::EOPTION_NOT_SET (0x40001)
}

#[test]
#[expected_failure(abort_code = 3)]
fun test_pre_epoch_date() {
    // This should fail because it's before Unix epoch
    let _pre_epoch = daymove::new_utc(1969, 7, 20, 20, 17, 40);
}
