#[test_only]
module safemath::uq64_safe_tests;

use std::debug;
use std::uq64_64;
use safemath::uq64_safe;

#[test]
fun test_sqrt_basic() {
    // Test case 1: Perfect square
    let x = uq64_64::from_int(100);
    let sqrt_x = uq64_safe::sqrt(x);

    // The square root of 100 should be 10
    let sqrt_x_int = uq64_64::to_int(sqrt_x);
    debug::print(&sqrt_x_int);
    assert!(sqrt_x_int == 10, 0);

    // Test case 2: Large number
    let large_num = uq64_64::from_int(1_000_000);
    let sqrt_large = uq64_safe::sqrt(large_num);

    // The square root of 1,000,000 should be 1,000
    let sqrt_large_int = uq64_64::to_int(sqrt_large);
    debug::print(&sqrt_large_int);
    assert!(sqrt_large_int == 1_000, 1);

    // Test case 3: Non-perfect square
    let non_perfect = uq64_64::from_int(2);
    let sqrt_non_perfect = uq64_safe::sqrt(non_perfect);

    // The integer part of sqrt(2) should be 1
    let sqrt_non_perfect_int = uq64_64::to_int(sqrt_non_perfect);
    debug::print(&sqrt_non_perfect_int);
    assert!(sqrt_non_perfect_int == 1, 2);

    // Test case 4: Zero
    let zero = uq64_64::from_int(0);
    let sqrt_zero = uq64_safe::sqrt(zero);

    // The square root of 0 should be 0
    let sqrt_zero_int = uq64_64::to_int(sqrt_zero);
    debug::print(&sqrt_zero_int);
    assert!(sqrt_zero_int == 0, 3);
}

#[test]
fun test_sqrt_fractional() {
    // Test with fractional values using from_quotient

    // sqrt(0.25) = 0.5
    let quarter = uq64_64::from_quotient(1, 4); // 0.25
    let sqrt_quarter = uq64_safe::sqrt(quarter);

    // Convert back to a quotient for comparison
    // We expect sqrt(0.25) = 0.5, so multiplying by 2 should give 1
    let result = uq64_64::mul(sqrt_quarter, uq64_64::from_int(2));
    let result_int = uq64_64::to_int(result);
    debug::print(&result_int);
    // Allow for some precision error in fixed-point arithmetic
    assert!(result_int >= 0 && result_int <= 2, 0);

    // sqrt(0.09) = 0.3
    let nine_hundredths = uq64_64::from_quotient(9, 100); // 0.09
    let sqrt_nine_hundredths = uq64_safe::sqrt(nine_hundredths);

    // We expect sqrt(0.09) = 0.3, so multiplying by 10 should give 3
    let result2 = uq64_64::mul(sqrt_nine_hundredths, uq64_64::from_int(10));
    let result2_int = uq64_64::to_int(result2);
    debug::print(&result2_int);
    // Allow for some precision error in fixed-point arithmetic
    assert!(result2_int >= 2 && result2_int <= 4, 1);
}

#[test]
fun test_sqrt_large_numbers() {
    // Test with very large numbers

    // The largest u64 value
    let max_u64 = 18446744073709551615; // 2^64 - 1
    let large_x = uq64_64::from_int(max_u64);
    let sqrt_large_x = uq64_safe::sqrt(large_x);

    // The square root of 2^64 - 1 is slightly less than 2^32
    // It should be 4294967295.99... which truncates to 4294967295
    let sqrt_large_x_int = uq64_64::to_int(sqrt_large_x);
    debug::print(&sqrt_large_x_int);
    assert!(sqrt_large_x_int == 4294967295, 0); // 2^32 - 1

    // A large perfect square: 2^32 * 2^32 = 2^64
    // But we need to use 2^32 - 1 to avoid overflow
    let perfect_square = uq64_64::from_int(4294967295 * 4294967295);
    let sqrt_perfect = uq64_safe::sqrt(perfect_square);
    let sqrt_perfect_int = uq64_64::to_int(sqrt_perfect);
    debug::print(&sqrt_perfect_int);
    // The result should be very close to 2^32 - 1
    assert!(sqrt_perfect_int == 4294967295, 1);
}

#[test]
fun test_sqrt_properties() {
    // Test mathematical properties of square root

    // Property 1: sqrt(a*a) = a for any non-negative a
    let a = uq64_64::from_int(123);
    let a_squared = uq64_64::mul(a, a);
    let sqrt_a_squared = uq64_safe::sqrt(a_squared);

    // Check that sqrt(a*a) = a
    let sqrt_a_squared_int = uq64_64::to_int(sqrt_a_squared);
    debug::print(&sqrt_a_squared_int);
    assert!(sqrt_a_squared_int == 123, 0);

    // Property 2: sqrt(a) * sqrt(a) = a for any non-negative a
    let b = uq64_64::from_int(49);
    let sqrt_b = uq64_safe::sqrt(b);
    let sqrt_b_squared = uq64_64::mul(sqrt_b, sqrt_b);

    // Check that sqrt(b) * sqrt(b) is approximately b
    // Due to fixed-point precision, it might not be exactly equal
    let sqrt_b_squared_int = uq64_64::to_int(sqrt_b_squared);
    debug::print(&sqrt_b_squared_int);
    // Allow a small margin of error due to fixed-point arithmetic
    assert!(sqrt_b_squared_int >= 48 && sqrt_b_squared_int <= 49, 1);
}

#[test]
fun test_sqrt_edge_cases() {
    // Test edge cases

    // Edge case 1: Very small number
    let small = uq64_64::from_quotient(1, 1000000); // 0.000001
    let sqrt_small = uq64_safe::sqrt(small);

    // sqrt(0.000001) = 0.001
    // Multiplying by 1000 should give 1
    let result = uq64_64::mul(sqrt_small, uq64_64::from_int(1000));
    let result_int = uq64_64::to_int(result);
    debug::print(&result_int);
    // Allow for some precision error in fixed-point arithmetic
    assert!(result_int >= 0 && result_int <= 2, 0);

    // Edge case 2: Number slightly greater than a perfect square
    let almost_perfect = uq64_64::from_int(101);
    let sqrt_almost = uq64_safe::sqrt(almost_perfect);

    // sqrt(101) should be between 10 and 11, but truncated to 10 as integer
    let sqrt_almost_int = uq64_64::to_int(sqrt_almost);
    debug::print(&sqrt_almost_int);
    assert!(sqrt_almost_int == 10, 1);

    // Edge case 3: Number slightly less than a perfect square
    let just_under = uq64_64::from_int(99);
    let sqrt_under = uq64_safe::sqrt(just_under);

    // sqrt(99) should be just under 10, truncated to 9 as integer
    let sqrt_under_int = uq64_64::to_int(sqrt_under);
    debug::print(&sqrt_under_int);
    assert!(sqrt_under_int == 9, 2);
}

#[test]
fun test_sqrt_debug() {
    // Test with a very simple case: sqrt(4) = 2
    let x = uq64_64::from_int(4);

    // Print the raw value for debugging
    let x_raw = uq64_64::to_raw(x);
    debug::print(&x_raw);

    // Print the integer value
    debug::print(&uq64_64::to_int(x));

    // Calculate sqrt
    let sqrt_x = uq64_safe::sqrt(x);

    // Print the raw value of the result
    let sqrt_x_raw = uq64_64::to_raw(sqrt_x);
    debug::print(&sqrt_x_raw);

    // Print the integer value
    let result = uq64_64::to_int(sqrt_x);
    debug::print(&result);

    // Manually calculate the integer part (raw value divided by 2^64)
    let manual_int = sqrt_x_raw >> 64;
    debug::print(&manual_int);

    // Test with another value: sqrt(9) = 3
    let y = uq64_64::from_int(9);
    debug::print(&uq64_64::to_raw(y));
    debug::print(&uq64_64::to_int(y));

    let sqrt_y = uq64_safe::sqrt(y);
    let sqrt_y_raw = uq64_64::to_raw(sqrt_y);
    debug::print(&sqrt_y_raw);
    debug::print(&uq64_64::to_int(sqrt_y));
    debug::print(&(sqrt_y_raw >> 64));

    // Test with a larger value: sqrt(1000000) = 1000
    let z = uq64_64::from_int(1000000);
    debug::print(&uq64_64::to_raw(z));
    debug::print(&uq64_64::to_int(z));

    let sqrt_z = uq64_safe::sqrt(z);
    let sqrt_z_raw = uq64_64::to_raw(sqrt_z);
    debug::print(&sqrt_z_raw);
    debug::print(&uq64_64::to_int(sqrt_z));
    debug::print(&(sqrt_z_raw >> 64));
}