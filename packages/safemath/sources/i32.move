module safemath::i32;

// Constants for bit manipulation
const MAX_I32_AS_U32: u32 = (1 << 31) - 1;
const U32_WITH_FIRST_BIT_SET: u32 = 1 << 31;

// Comparison result enum
public enum ComparisonResult has copy, drop, store {
    Equal,
    LessThan,
    GreaterThan,
}

/// @notice Returns the Equal comparison result
public fun equal(): ComparisonResult { ComparisonResult::Equal }

/// @notice Returns the LessThan comparison result
public fun less_than(): ComparisonResult { ComparisonResult::LessThan }

/// @notice Returns the GreaterThan comparison result
public fun greater_than(): ComparisonResult { ComparisonResult::GreaterThan }

// Sign enum to represent positive or negative
public enum Sign has copy, drop, store {
    Positive,
    Negative,
}

// Error codes
const EConversionFromU32Overflow: u64 = 0;
const EConversionToU32Underflow: u64 = 1;
const EDivisionByZero: u64 = 2;
const EOverflow: u64 = 3;
#[allow(unused_const)]
const EUnderflow: u64 = 4;

/// @notice Struct representing a signed 32-bit integer.
public struct I32 has copy, drop, store {
    bits: u32,
}

/// @notice Extract sign and magnitude from an I32
/// @return (sign, magnitude)
fun extract_sign_and_magnitude(value: &I32): (Sign, u32) {
    let is_positive = value.bits < U32_WITH_FIRST_BIT_SET;
    let magnitude = if (is_positive) {
        value.bits
    } else {
        value.bits - U32_WITH_FIRST_BIT_SET
    };

    let sign = if (is_positive) {
        Sign::Positive
    } else {
        Sign::Negative
    };

    (sign, magnitude)
}

/// @notice Creates an I32 from sign and magnitude
fun from_sign_and_magnitude(sign: Sign, magnitude: u32): I32 {
    match (sign) {
        Sign::Positive => {
            assert!(magnitude <= MAX_I32_AS_U32, EConversionFromU32Overflow);
            I32 { bits: magnitude }
        },
        Sign::Negative => {
            assert!(magnitude <= MAX_I32_AS_U32 + 1, EConversionFromU32Overflow);
            if (magnitude == 0) {
                I32 { bits: 0 }
            } else {
                I32 { bits: U32_WITH_FIRST_BIT_SET | magnitude }
            }
        },
    }
}

/// @notice Creates a new `I32` with value 0.
public fun zero(): I32 {
    I32 { bits: 0 }
}

/// @notice Converts a `u32` to an `I32`.
public fun from_u32(value: u32): I32 {
    assert!(value <= MAX_I32_AS_U32, EConversionFromU32Overflow);
    I32 { bits: value }
}

/// @notice Creates an I32 value from sign and magnitude.
/// @param is_positive Whether the value is positive
/// @param magnitude The magnitude as a u32
public fun new(is_positive: bool, magnitude: u32): I32 {
    let sign = if (is_positive) { Sign::Positive } else { Sign::Negative };
    from_sign_and_magnitude(sign, magnitude)
}

/// @notice Creates a negative `I32` from a `u32` magnitude.
public fun neg_from_u32(magnitude: u32): I32 {
    from_sign_and_magnitude(Sign::Negative, magnitude)
}

/// @notice Whether the value is equal to 0.
public fun is_zero(value: &I32): bool {
    value.bits == 0
}

/// @notice Whether the value is negative.
public fun is_neg(value: &I32): bool {
    value.bits >= U32_WITH_FIRST_BIT_SET
}

/// @notice Whether the value is positive.
public fun is_positive(value: &I32): bool {
    value.bits > 0 && value.bits < U32_WITH_FIRST_BIT_SET
}

/// @notice Returns the absolute value of the value.
public fun abs(value: &I32): u32 {
    let (_, magnitude) = extract_sign_and_magnitude(value);
    magnitude
}

/// @notice Converts to a u32 value.
public fun as_u32(value: &I32): u32 {
    assert!(value.bits < U32_WITH_FIRST_BIT_SET, EConversionToU32Underflow);
    value.bits
}

/// @notice Compares `lhs` and `rhs`.
/// @return Equal if lhs == rhs, LessThan if lhs < rhs, GreaterThan if lhs > rhs
public fun b_compare(lhs: &I32, rhs: &I32): ComparisonResult {
    if (lhs.bits == rhs.bits) {
        equal()
    } else {
        let (lhs_sign, _) = extract_sign_and_magnitude(lhs);
        let (rhs_sign, _) = extract_sign_and_magnitude(rhs);

        if (lhs_sign == Sign::Positive && rhs_sign == Sign::Positive) {
            if (lhs.bits > rhs.bits) {
                greater_than()
            } else {
                less_than()
            }
        } else if (lhs_sign == Sign::Negative && rhs_sign == Sign::Negative) {
            if (lhs.bits > rhs.bits) {
                less_than()
            } else {
                greater_than()
            }
        } else if (lhs_sign == Sign::Positive && rhs_sign == Sign::Negative) {
            greater_than()
        } else { // lhs_sign == Sign::Negative && rhs_sign == Sign::Positive
            less_than()
        }
    }
}
public fun compare(lhs: &I32, rhs: &I32): ComparisonResult {
    if (lhs.bits == rhs.bits) {
        return equal();
    };

    let (lhs_sign, _) = extract_sign_and_magnitude(lhs);
    let (rhs_sign, _) = extract_sign_and_magnitude(rhs);

    // let pair = (lhs_sign, rhs_sign);
    match (lhs_sign, rhs_sign) {
        (Sign::Positive, Sign::Positive) => {
            if (lhs.bits > rhs.bits) {
                greater_than()
            } else {
                less_than()
            }
        },
        (Sign::Negative, Sign::Negative) => {
            if (lhs.bits > rhs.bits) {
                less_than()
            } else {
                greater_than()
            }
        },
        (Sign::Positive, Sign::Negative) => greater_than(),
        (Sign::Negative, Sign::Positive) => less_than(),
        _ => equal() // fallback: 理論的には不要だが exhaustiveness 満たすため
    }
}

/// @notice Returns the negation of the value.
public fun neg(value: &I32): I32 {
    if (value.bits == 0) {
        *value
    } else {
        let (sign, magnitude) = extract_sign_and_magnitude(value);
        match (sign) {
            Sign::Positive => from_sign_and_magnitude(Sign::Negative, magnitude),
            Sign::Negative => from_sign_and_magnitude(Sign::Positive, magnitude),
        }
    }
}

/// @notice Adds `rhs` to `lhs`.
public fun add(lhs: &I32, rhs: &I32): I32 {
    // Handle special case where one operand is zero
    if (is_zero(lhs)) {
        return *rhs
    } else if (is_zero(rhs)) {
        return *lhs
    } else {
        let (lhs_sign, lhs_magnitude) = extract_sign_and_magnitude(lhs);
        let (rhs_sign, rhs_magnitude) = extract_sign_and_magnitude(rhs);

        if (lhs_sign == Sign::Positive && rhs_sign == Sign::Positive) {
            // Both positive, add magnitudes
            let result_magnitude = lhs_magnitude + rhs_magnitude;
            // Check for overflow
            assert!(result_magnitude >= lhs_magnitude, EOverflow);
            return from_sign_and_magnitude(Sign::Positive, result_magnitude)
        } else if (lhs_sign == Sign::Negative && rhs_sign == Sign::Negative) {
            // Both negative, add magnitudes
            let result_magnitude = lhs_magnitude + rhs_magnitude;
            return from_sign_and_magnitude(Sign::Negative, result_magnitude)
        } else {
            // Signs are different
            if (lhs_magnitude >= rhs_magnitude) {
                return from_sign_and_magnitude(lhs_sign, lhs_magnitude - rhs_magnitude)
            } else {
                return from_sign_and_magnitude(rhs_sign, rhs_magnitude - lhs_magnitude)
            }
        }
    }
}

/// @notice Subtracts `rhs` from `lhs`.
public fun sub(lhs: &I32, rhs: &I32): I32 {
    // lhs - rhs = lhs + (-rhs)
    add(lhs, &neg(rhs))
}

/// @notice Multiplies `lhs` by `rhs`.
public fun mul(lhs: &I32, rhs: &I32): I32 {
    // Handle special cases for zero
    if (is_zero(lhs) || is_zero(rhs)) {
        return zero()
    } else {
        let (lhs_sign, lhs_magnitude) = extract_sign_and_magnitude(lhs);
        let (rhs_sign, rhs_magnitude) = extract_sign_and_magnitude(rhs);

        // Result sign is positive if both signs are the same, negative otherwise
        let result_sign = if (
            (lhs_sign == Sign::Positive && rhs_sign == Sign::Positive) ||
            (lhs_sign == Sign::Negative && rhs_sign == Sign::Negative)
        ) {
            Sign::Positive
        } else {
            Sign::Negative
        };

        // Calculate result magnitude, checking for overflow
        let result_magnitude = lhs_magnitude * rhs_magnitude;
        if (rhs_magnitude != 0) {
            assert!(result_magnitude / rhs_magnitude == lhs_magnitude, EOverflow);
        };

        return from_sign_and_magnitude(result_sign, result_magnitude)
    }
}

/// @notice Divides `lhs` by `rhs`.
public fun div(lhs: &I32, rhs: &I32): I32 {
    assert!(!is_zero(rhs), EDivisionByZero);

    // Handle special case for zero dividend
    if (is_zero(lhs)) {
        return zero()
    } else {
        // Handle special case for INT_MIN / -1 which would overflow
        if (lhs.bits == U32_WITH_FIRST_BIT_SET && rhs.bits == (U32_WITH_FIRST_BIT_SET | 1)) {
            abort EOverflow
        };

        let (lhs_sign, lhs_magnitude) = extract_sign_and_magnitude(lhs);
        let (rhs_sign, rhs_magnitude) = extract_sign_and_magnitude(rhs);

        // Result sign is positive if both signs are the same, negative otherwise
        let result_sign = if (
            (lhs_sign == Sign::Positive && rhs_sign == Sign::Positive) ||
                             (lhs_sign == Sign::Negative && rhs_sign == Sign::Negative)
        ) {
            Sign::Positive
        } else {
            Sign::Negative
        };

        let result_magnitude = lhs_magnitude / rhs_magnitude;

        return from_sign_and_magnitude(result_sign, result_magnitude)
    }
}

/// @notice Calculates modulo `lhs % rhs`.
public fun modulo(lhs: &I32, rhs: &I32): I32 {
    assert!(!is_zero(rhs), EDivisionByZero);

    // Handle special case for zero dividend
    if (is_zero(lhs)) {
        return zero()
    } else {
        let (lhs_sign, lhs_magnitude) = extract_sign_and_magnitude(lhs);
        let (_, rhs_magnitude) = extract_sign_and_magnitude(rhs);

        // Calculate result; sign follows dividend (lhs)
        let result_magnitude = lhs_magnitude % rhs_magnitude;

        return from_sign_and_magnitude(lhs_sign, result_magnitude)
    }
}

/// @notice Returns the minimum of two I32 values
public fun min(lhs: &I32, rhs: &I32): I32 {
    match (compare(lhs, rhs)) {
        x if (x == less_than()) => *lhs,
        _ => *rhs,
    }
}

/// @notice Returns the maximum of two I32 values
public fun max(lhs: &I32, rhs: &I32): I32 {
    match (compare(lhs, rhs)) {
        x if (x == greater_than()) => *lhs,
        _ => *rhs,
    }
}

/// @notice Check if lhs is less than rhs
public fun lt(lhs: &I32, rhs: &I32): bool {
    compare(lhs, rhs) == less_than()
}

/// @notice Check if lhs is less than or equal to rhs
public fun lte(lhs: &I32, rhs: &I32): bool {
    let cmp = compare(lhs, rhs);
    cmp == less_than() || cmp == equal()
}

/// @notice Check if lhs is greater than rhs
public fun gt(lhs: &I32, rhs: &I32): bool {
    compare(lhs, rhs) == greater_than()
}

/// @notice Check if lhs is greater than or equal to rhs
public fun gte(lhs: &I32, rhs: &I32): bool {
    let cmp = compare(lhs, rhs);
    cmp == greater_than() || cmp == equal()
}
