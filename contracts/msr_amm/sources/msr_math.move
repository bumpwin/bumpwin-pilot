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
///
/// Inversion Formulas:
/// - Given Δz (budget), compute Δxᵢ to buy:
///     Δxᵢ = [-b + sqrt(b² + 4aΔz)] / (2a)
/// - Given Δxᵢ (share quantity), compute Δz to sell:
///     Δz = b·Δxᵢ − a·Δxᵢ²
///   where:
///     - a = (n−1)/(4n)
///     - b = (1/2)xᵢ − (1/2n)∑xⱼ + 1/n

module msr_amm::msr_math;

use std::u128;
use safemath::{u64_safe, u128_safe};

const EInvalidMarket: u64 = 1;   // n == 0

/// Computes total cost in numeraire to reach state x
/// C(q) = (1/4) ∑ qᵢ² − (1/4n)(∑ qᵢ)² + (1/n) ∑ qᵢ
public fun cost(
    sum_q: u64,
    sum_q_sq: u64,
    n: u64,
): u64 {
    assert!(n > 0, EInvalidMarket);

    // Term1: (1/4) * sum_q_sq
    let term1 = u64_safe::div(sum_q_sq, 4);

    // Term2: (1/4n) * sum_q^2
    let term2 = u64_safe::muldiv(sum_q, sum_q, 4 * n);

    // Term3: (1/n) * sum_q
    let term3 = u64_safe::div(sum_q, n);

    // C(q) = term1 - term2 + term3
    let result = u64_safe::sub(term1, term2);
    u64_safe::add(result, term3)
}

/// Computes the marginal price pᵢ(q) = ∂C/∂qᵢ
/// pᵢ(q) = (1/8)(3qᵢ − ∑_{j≠i} qⱼ) + 1/4
/// Output is unscaled numeraire units
public fun price(
    sum_q: u64,
    qi: u64,
): u64 {
    // Compute sum_other = sum_q - qi
    let sum_other = u64_safe::sub(sum_q, qi);

    u128::try_as_u64(
        ((3 * qi as u128) - (sum_other as u128) + 2) / 8
    ).extract()
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
    sum_x: u128,
    delta_z: u64,
    num_outcomes: u64,
): u64 {
    assert!(num_outcomes > 1, EInvalidMarket);

    let n_u128 = num_outcomes as u128;
    let xi_u128 = xi as u128;

    // a = (n−1)/(4n)
    let a = ((n_u128 - 1) / 4 / n_u128);

    // b = (xi/2) - (sum_x/2n) + (1/n)
    let b = ((xi_u128 / 2) - (sum_x / 2 / n_u128) + (1 / n_u128));

    // sqrt_disc = sqrt(b^2 + 4aΔz)
    let sqrt_disc = u128::sqrt(b * b + 4 * a * (delta_z as u128));

    // (sqrt_disc - b) / 2a
    (u128_safe::sub(sqrt_disc, b) / 2 / a).try_as_u64().extract()
}


/// Computes Δz required to sell Δxᵢ shares
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
    sum_x: u128,
    delta_xi: u64,
    num_outcomes: u64,
): u64 {
    assert!(num_outcomes > 1, EInvalidMarket);

    let n_u128 = num_outcomes as u128;
    let xi_u128 = xi as u128;
    let delta_xi_u128 = delta_xi as u128;

    // a = (n−1)/(4n)
    let a = ((n_u128 - 1) / 4 / n_u128);

    // b = (xi/2) - (sum_x/2n) + (1/n)
    let b = ((xi_u128 / 2) - (sum_x / 2 / n_u128) + (1 / n_u128));

    u128_safe::mul(
        delta_xi_u128,
        u128_safe::sub(
            b,
            u128_safe::mul(
                a,
                delta_xi_u128
            ),
        )
    ).try_as_u64().extract()
}
