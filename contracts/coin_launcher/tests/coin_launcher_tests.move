#[test_only]
module coin_launcher::coin_launcher_tests;

use coin_launcher::launcher;

const ENotImplemented: u64 = 0;

#[test]
fun test_coin_launcher() {
    // pass
}

#[test, expected_failure(abort_code = ::coin_launcher::coin_launcher_tests::ENotImplemented)]
fun test_coin_launcher_fail() {
    abort ENotImplemented
}
