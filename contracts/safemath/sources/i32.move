module safemath::i32;

// Constants for bit manipulation
const MAX_I32_AS_U32: u32 = (1 << 31) - 1;
const U32_WITH_FIRST_BIT_SET: u32 = 1 << 31;

// Comparison result constants
const EQUAL: u8 = 0;
const LESS_THAN: u8 = 1;
const GREATER_THAN: u8 = 2;

// Error codes
const ECONVERSION_FROM_U32_OVERFLOW: u64 = 0;
const ECONVERSION_TO_U32_UNDERFLOW: u64 = 1;
const EDIVISION_BY_ZERO: u64 = 2;
const EOVERFLOW: u64 = 3;
const EUNDERFLOW: u64 = 4;

/// @notice Struct representing a signed 32-bit integer.
public struct I32 has copy, drop, store {
    bits: u32,
}

/// @notice Extract sign and magnitude from an I32
/// @return (is_positive, magnitude)
fun extract_sign_and_magnitude(x: &I32): (bool, u32) {
    let is_positive = x.bits < U32_WITH_FIRST_BIT_SET;
    let magnitude = if (is_positive) x.bits else x.bits - U32_WITH_FIRST_BIT_SET;
    (is_positive, magnitude)
}

/// @notice Create an I32 from sign and magnitude
fun create_from_sign_and_magnitude(is_positive: bool, magnitude: u32): I32 {
    if (is_positive) {
        assert!(magnitude <= MAX_I32_AS_U32, ECONVERSION_FROM_U32_OVERFLOW);
        I32 { bits: magnitude }
    } else {
        assert!(magnitude <= MAX_I32_AS_U32 + 1, ECONVERSION_FROM_U32_OVERFLOW);
        if (magnitude == 0) {
            I32 { bits: 0 }
        } else {
            I32 { bits: U32_WITH_FIRST_BIT_SET | magnitude }
        }
    }
}

/// @notice Creates a new `I32` with value 0.
public fun zero(): I32 {
    I32 { bits: 0 }
}

/// @notice Casts an `I32` to a `u32`.
public fun as_u32(x: &I32): u32 {
    assert!(x.bits < U32_WITH_FIRST_BIT_SET, ECONVERSION_TO_U32_UNDERFLOW);
    x.bits
}

/// @notice Casts a `u32` to an `I32`.
public fun from_u32(x: u32): I32 {
    assert!(x <= MAX_I32_AS_U32, ECONVERSION_FROM_U32_OVERFLOW);
    I32 { bits: x }
}

/// @notice Create I32 value from sign and magnitude.
/// @param positive Whether the value is positive
/// @param x The magnitude as a u32
public fun new(positive: bool, x: u32): I32 {
    create_from_sign_and_magnitude(positive, x)
}

/// @notice Creates a negative `I32` from a `u32` magnitude.
public fun neg_from_u32(x: u32): I32 {
    create_from_sign_and_magnitude(false, x)
}

/// @notice Whether or not `x` is equal to 0.
public fun is_zero(x: &I32): bool {
    x.bits == 0
}

/// @notice Whether or not `x` is negative.
public fun is_neg(x: &I32): bool {
    x.bits >= U32_WITH_FIRST_BIT_SET
}

/// @notice Whether or not `x` is positive.
public fun is_positive(x: &I32): bool {
    x.bits > 0 && x.bits < U32_WITH_FIRST_BIT_SET
}

/// @notice Absolute value of `x`.
public fun abs(x: &I32): u32 {
    let (_, magnitude) = extract_sign_and_magnitude(x);
    magnitude
}

/// @notice Compare `a` and `b`.
/// @return EQUAL if a == b, LESS_THAN if a < b, GREATER_THAN if a > b
public fun compare(a: &I32, b: &I32): u8 {
    if (a.bits == b.bits) {
        EQUAL
    } else {
        let (a_is_positive, _) = extract_sign_and_magnitude(a);
        let (b_is_positive, _) = extract_sign_and_magnitude(b);

        if (a_is_positive && !b_is_positive) {
            // Positive > Negative
            GREATER_THAN
        } else if (!a_is_positive && b_is_positive) {
            // Negative < Positive
            LESS_THAN
        } else if (a_is_positive) {
            // Both positive, compare directly
            if (a.bits > b.bits) GREATER_THAN else LESS_THAN
        } else {
            // Both negative, larger bit value means more negative
            if (a.bits > b.bits) LESS_THAN else GREATER_THAN
        }
    }
}

/// @notice Flips the sign of `x`.
public fun neg(x: &I32): I32 {
    if (x.bits == 0) {
        *x
    } else {
        let (is_positive, magnitude) = extract_sign_and_magnitude(x);
        create_from_sign_and_magnitude(!is_positive, magnitude)
    }
}

/// @notice Add `a + b`.
public fun add(a: &I32, b: &I32): I32 {
    // Handle special case where one operand is zero
    if (is_zero(a)) {
        *b
    } else if (is_zero(b)) {
        *a
    } else {
        let (a_is_positive, a_magnitude) = extract_sign_and_magnitude(a);
        let (b_is_positive, b_magnitude) = extract_sign_and_magnitude(b);

        // If signs are the same, result has the same sign
        if (a_is_positive == b_is_positive) {
            let result_magnitude = a_magnitude + b_magnitude;
            // Check for overflow when adding two positives
            if (a_is_positive) {
                assert!(result_magnitude >= a_magnitude, EOVERFLOW); // Check overflow
            };
            create_from_sign_and_magnitude(a_is_positive, result_magnitude)
        } else if (a_magnitude >= b_magnitude) {
            // Signs are different, subtract the smaller magnitude from the larger
            create_from_sign_and_magnitude(a_is_positive, a_magnitude - b_magnitude)
        } else {
            create_from_sign_and_magnitude(b_is_positive, b_magnitude - a_magnitude)
        }
    }
}

/// @notice Subtract `a - b`.
public fun sub(a: &I32, b: &I32): I32 {
    // a - b = a + (-b)
    add(a, &neg(b))
}

/// @notice Multiply `a * b`.
public fun mul(a: &I32, b: &I32): I32 {
    // Handle special cases for zero
    if (is_zero(a) || is_zero(b)) {
        zero()
    } else {
        let (a_is_positive, a_magnitude) = extract_sign_and_magnitude(a);
        let (b_is_positive, b_magnitude) = extract_sign_and_magnitude(b);

        // Result sign is positive if both signs are the same, negative otherwise
        let result_positive = a_is_positive == b_is_positive;

        // Calculate result magnitude, checking for overflow
        let result_magnitude = a_magnitude * b_magnitude;
        if (b_magnitude != 0) {
            assert!(result_magnitude / b_magnitude == a_magnitude, EOVERFLOW);
        };

        create_from_sign_and_magnitude(result_positive, result_magnitude)
    }
}

/// @notice Divide `a / b`.
public fun div(a: &I32, b: &I32): I32 {
    assert!(!is_zero(b), EDIVISION_BY_ZERO);

    // Handle special case for zero dividend
    if (is_zero(a)) {
        zero()
    } else {
        // Handle special case for INT_MIN / -1 which would overflow
        if (a.bits == U32_WITH_FIRST_BIT_SET && b.bits == (U32_WITH_FIRST_BIT_SET | 1)) {
            assert!(false, EOVERFLOW);
        };

        let (a_is_positive, a_magnitude) = extract_sign_and_magnitude(a);
        let (b_is_positive, b_magnitude) = extract_sign_and_magnitude(b);

        // Result sign is positive if both signs are the same, negative otherwise
        let result_positive = a_is_positive == b_is_positive;
        let result_magnitude = a_magnitude / b_magnitude;

        create_from_sign_and_magnitude(result_positive, result_magnitude)
    }
}

/// @notice Modulo `a % b`.
public fun modulo(a: &I32, b: &I32): I32 {
    assert!(!is_zero(b), EDIVISION_BY_ZERO);

    // Handle special case for zero dividend
    if (is_zero(a)) {
        zero()
    } else {
        let (a_is_positive, a_magnitude) = extract_sign_and_magnitude(a);
        let (_, b_magnitude) = extract_sign_and_magnitude(b);

        // Calculate result; sign follows dividend (a)
        let result_magnitude = a_magnitude % b_magnitude;

        create_from_sign_and_magnitude(a_is_positive, result_magnitude)
    }
}

/// @notice Returns the minimum of two I32 values
public fun min(a: &I32, b: &I32): I32 {
    if (compare(a, b) == LESS_THAN) { *a } else { *b }
}

/// @notice Returns the maximum of two I32 values
public fun max(a: &I32, b: &I32): I32 {
    if (compare(a, b) == GREATER_THAN) { *a } else { *b }
}

/// @notice Check if a is less than b
public fun lt(a: &I32, b: &I32): bool {
    compare(a, b) == LESS_THAN
}

/// @notice Check if a is less than or equal to b
public fun lte(a: &I32, b: &I32): bool {
    let cmp = compare(a, b);
    cmp == LESS_THAN || cmp == EQUAL
}

/// @notice Check if a is greater than b
public fun gt(a: &I32, b: &I32): bool {
    compare(a, b) == GREATER_THAN
}

/// @notice Check if a is greater than or equal to b
public fun gte(a: &I32, b: &I32): bool {
    let cmp = compare(a, b);
    cmp == GREATER_THAN || cmp == EQUAL
}
