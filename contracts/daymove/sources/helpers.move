module daymove::helpers;

use daymove::constants;

// Helper function to validate YMD
public fun is_valid_ymd(y: u16, m: u8, d: u8): bool {
    if (!(m >= 1 && m <= 12)) { return false };
    let dim = days_in_month(y, m);
    d >= 1 && d <= dim
}

public fun days_in_month(y: u16, m: u8): u8 {
    if (m == 1 || m == 3 || m == 5 || m == 7 || m == 8 || m == 10 || m == 12) 31
    else if (m == 2) { if (is_leap(y)) 29 else 28 } else 30
}

public fun is_leap(y: u16): bool {
    ((y % 4 == 0) && (y % 100 != 0)) || (y % 400 == 0)
}

// =======================================
// Julian day conversion (integer algorithm)
// =======================================
public fun ymd_to_jd(y: u16, m: u8, d: u8): u64 {
    // Special case for year 0 to avoid underflow
    if (y == 0) {
        return 1721060 + (m as u64) * 30 + (d as u64) // Approximate for year 0
    };

    let yy = y as u64;
    let mm = m as u64;
    let dd = d as u64;
    let a = (14 - mm) / 12;
    let y2 = yy + 4800 - a;
    let m2 = mm + 12 * a - 3;
    dd + (153 * m2 + 2) / 5 + 365 * y2 + y2 / 4 - y2 / 100 + y2 / 400 - 32045
}

public fun jd_to_ymd(jd: u64): (u16, u8, u8) {
    let b = jd + 32044;
    let c = (4 * b + 3) / 146097;
    let d = b - (146097 * c) / 4;
    let e = (4 * d + 3) / 1461;
    let f = d - (1461 * e) / 4;
    let g = (5 * f + 2) / 153;
    let day = (f - (153 * g + 2) / 5 + 1) as u8;
    let month = (g + 3 - 12 * (g / 10)) as u8;
    let year = (100 * c + e - 4800 + (g / 10)) as u16;
    (year, month, day)
}
