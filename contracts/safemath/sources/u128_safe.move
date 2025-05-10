module safemath::u128_safe;

use std::{u128};

/// Error codes
const EOverflow: u64 = 0;
const EUnderflow: u64 = 1;
const EDivZero: u64 = 2;

/// Return result for a + b, aborts on overflow
public fun add(a: u128, b: u128): u128 {
    let c = a + b;
    assert!(c >= a, EOverflow);
    c
}

/// Return result for a - b, aborts on underflow
public fun sub(a: u128, b: u128): u128 {
    assert!(a >= b, EUnderflow);
    a - b
}

/// Return result for a * b, aborts on overflow
public fun mul(a: u128, b: u128): u128 {
    if (a == 0 || b == 0) {
        0
    } else {
        let c = a * b;
        assert!(c / a == b, EOverflow);
        c
    }
}

/// Return result for a / b, aborts on divide by zero
public fun div(a: u128, b: u128): u128 {
    assert!(b > 0, EDivZero);
    a / b
}

/// Return result for a % b, aborts on divide by zero
public fun mod(a: u128, b: u128): u128 {
    assert!(b > 0, EDivZero);
    a % b
}

/// Saturating addition: return min(a + b, u128::MAX)
public fun saturating_add(a: u128, b: u128): u128 {
    let c = a + b;
    if (c >= a) { c } else u128::max_value!()
}

/// Saturating subtraction: return max(a - b, 0)
public fun saturating_sub(a: u128, b: u128): u128 {
    if (a >= b) { a - b } else { 0 }
}

/// Saturating multiplication: return min(a * b, u128::MAX)
public fun saturating_mul(a: u128, b: u128): u128 {
    if (a == 0 || b == 0) {
        0
    } else {
        let c = a * b;
        if (c / a == b) { c } else u128::max_value!()
    }
}

/// CeilDiv: return ceil(a / b)
public fun ceil_div(a: u128, b: u128): u128 {
    assert!(b > 0, EDivZero);
    if (a == 0) { 0 } else { (a - 1) / b + 1 }
}

/// muldiv(a, b, c): floor((a * b) / c), with 256-bit intermediate
public fun muldiv(a: u128, b: u128, c: u128): u128 {
    assert!(c > 0, EDivZero);
    let result = (a as u256) * (b as u256) / (c as u256);
    result.try_as_u128().extract()
}

/// muldiv_up(a, b, c): ceil((a * b) / c)
public fun muldiv_up(a: u128, b: u128, c: u128): u128 {
    assert!(c > 0, EDivZero);
    let result = ((a as u256) * (b as u256)).divide_and_round_up(c as u256);
    result.try_as_u128().extract()
}

/// Return average(a, b), rounded toward zero
public fun average(a: u128, b: u128): u128 {
    (a & b) + ((a ^ b) / 2)
}

/// log2(x), returns floor(log2(x))
public fun log2(x: u128): u128 {
    assert!(x > 0, EOverflow); // log2(0) is undefined
    let mut r = 0;
    let mut v = x;
    while (v > 1) {
        v = v >> 1;
        r = r + 1;
    };
    r
}