module safemath::uq64_safe;

use std::uq64_64;

/// Calculate the square root of a UQ64_64 fixed-point number.
/// For a UQ64_64 value x, the result is √x as a UQ64_64 value.
public fun sqrt(x: uq64_64::UQ64_64): uq64_64::UQ64_64 {
    // Get the raw value (x * 2^64)
    let x_raw = uq64_64::to_raw(x);

    // To calculate √(x * 2^64), we need to adjust the scaling:
    // √(x * 2^64) = √x * √(2^64) = √x * 2^32
    // But we need the result as √x * 2^64 for UQ64_64 format
    // So we need to multiply by an additional 2^32

    // First calculate √(x_raw)
    let sqrt_raw = x_raw.sqrt();

    // Then scale it up by 2^32 to get the correct UQ64_64 representation
    // This is equivalent to multiplying by 2^32
    let result_raw = sqrt_raw << 32;

    uq64_64::from_raw(result_raw)
}
