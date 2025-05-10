/// Brier Score dual SCPM — Operational Definition (Structurally Concrete)
/// ----------------------------------------------------------------------
///
/// State Space:
/// - Let n be the number of mutually exclusive and exhaustive outcomes.
/// - Let x := (x₁, ..., xₙ) ∈ ℝⁿ denote the vector of outstanding shares.
///   Each xᵢ represents the number of shares for outcome i.
///
/// Share Definition:
/// - An outcome-i share is a contract that pays exactly 1 unit of numeraire if and only if outcome i occurs.
/// - Each unit of xᵢ corresponds to one such share.
///
/// Cost Function (denominated in numeraire):
/// - C(x) = (1/4) ∑ xⱼ² − (1/4n)(∑ xⱼ)² + (1/n) ∑ xⱼ
/// - This function gives the total numeraire z required to reach state x from the empty state.
///
/// Price Function (units: numeraire per share):
/// - pᵢ(x) = (1/8)(3xᵢ − ∑_{j≠i} xⱼ) + 1/4
/// - This is the marginal cost to increase xᵢ by an infinitesimal amount at state x.
///
/// Trading:
/// - To buy Δxᵢ shares of outcome i:
///     Pay Δz = C(x₁, ..., xᵢ + Δxᵢ, ..., xₙ) − C(x)
///
/// - To sell Δxᵢ shares of outcome i:
///     Receive Δz = C(x) − C(x₁, ..., xᵢ − Δxᵢ, ..., xₙ)
///
/// - After trading: update xᵢ ← xᵢ ± Δxᵢ
///
/// Payout:
/// - Once the true outcome i* is realized, each x_{i*} pays out 1 unit of numeraire.
/// - All other shares expire with 0 payout.
///
/// Guarantees:
/// - Price normalization:        ∑ pᵢ(x) = 1
/// - Price range:                0 ≤ pᵢ(x) ≤ 1
/// - Bounded loss:               supₓ C(x) − infᵢ xᵢ ≤ 1/2
/// - Convexity:                  C(x) is convex, ensuring consistent pricing and no arbitrage.
///
/// Units Summary:
/// - xᵢ:   number of shares for outcome i (dimensionless)
/// - pᵢ:   price in numeraire per share of outcome i
/// - C(x): total numeraire committed at state x


module msr_amm::msr_math;


use std::{u64, u128};

/// Scaling factor for fixed-point precision (6 decimals)
const PRECISION: u64 = 1_000_000;

/// Computes the cost function:
/// C(q) = (1/4) ∑ qᵢ² − (1/4n)(∑ qᵢ)² + (1/n) ∑ qᵢ
/// Inputs are scaled by PRECISION
public fun cost(
    sum_q: u64,
    sum_q_sq: u64,
    n: u64,
): u64 {
    if (n == 0) return 0;
    let term1 = (sum_q_sq * PRECISION) / 4;
    let term2 = ((sum_q * sum_q) * PRECISION) / (4 * n);
    let term3 = (sum_q * PRECISION) / n;
    (term1 - term2 + term3) / PRECISION
}

/// Computes the price function for a given outcome:
/// pᵢ(q) = (1/8)(3qᵢ − ∑_{j≠i} qⱼ) + 1/4
/// Returns value in [0, 1] scaled by PRECISION
public fun price(
    sum_q: u64,
    qi: u64,
): u64 {
    let sum_other = sum_q - qi;
    let term1 = ((3 * qi - sum_other) * PRECISION) / 8;
    let term2 = PRECISION / 4;
    term1 + term2
}


/// Converts amount_in (Δz) to amount_out (Δxᵢ)
/// Formula: Δxᵢ = [-b + sqrt(b² + 4aΔz)] / (2a)
/// where:
///     a = (n−1)/4n
///     b = (1/2)xi − (1/2n)∑x + 1/n
/// ---------------------------------------------
/// Δz = C(x₁, ..., xᵢ + Δxᵢ, ..., xₙ) - C(x)
public fun swap_rate_z_to_xi(
    xi: u64,
    sum_x: u64,
    n: u64,
    delta_z: u64,
): u64 {
    assert!(n > 0, 0);

    let a_scaled = (PRECISION * (n - 1)) / (4 * n);
    let b_scaled = (xi * PRECISION) / 2
        - (sum_x * PRECISION) / (2 * n)
        + PRECISION / n;

    let b_squared: u128 = u128::pow(b_scaled as u128, 2);
    let az_scaled: u128 = 4 * (a_scaled as u128) * (delta_z as u128) * (PRECISION as u128);

    let discriminant: u128 = b_squared + az_scaled;
    let sqrt_discriminant = u128::sqrt(discriminant);

    assert!(sqrt_discriminant >= (b_scaled as u128), 1);
    let numerator = sqrt_discriminant - (b_scaled as u128);
    let denominator = 2 * (a_scaled as u128);

    let result = numerator / denominator;
    u128::try_as_u64(result).extract()
}

/// Converts amount_out (Δxᵢ) to amount_in (Δz)
/// Formula: Δz = b Δxᵢ - a Δxᵢ²
/// where:
///     a = (n−1)/4n
///     b = (1/2)xi − (1/2n)∑x + 1/n
/// ---------------------------------------------
/// Δz = C(x) - C(x₁, ..., xᵢ - Δxᵢ, ..., xₙ)
///    = b Δxᵢ - a Δxᵢ²
public fun swap_rate_xi_to_z(
    xi: u64,
    sum_x: u64,
    n: u64,
    delta_xi: u64,
): u64 {
    assert!(n > 0, 0);

    let a_scaled = (PRECISION * (n - 1)) / (4 * n);
    let b_scaled = (xi * PRECISION) / 2
        - (sum_x * PRECISION) / (2 * n)
        + PRECISION / n;

    let term_bx: u128 = (b_scaled as u128) * (delta_xi as u128);
    let term_ax2: u128 = (a_scaled as u128) * (delta_xi as u128) * (delta_xi as u128);

    let z_scaled = term_bx - term_ax2;
    let result = z_scaled / (PRECISION as u128);

    u128::try_as_u64(result).extract()
}
