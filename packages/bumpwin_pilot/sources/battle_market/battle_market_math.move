/// Brier Score dual SCPM — Operational Definition
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

module bumpwin_pilot::battle_market_math;

use std::uq64_64::{Self, UQ64_64};

const EInvalidMarket: u64 = 1; // n == 0

/// Computes total cost in numeraire to reach state x
/// C(q) = (1/4) ∑ qᵢ² − (1/4n)(∑ qᵢ)² + (1/n) ∑ qᵢ
public fun cost(sum_q: u64, sum_q_sq: u128, num_outcomes: u64): u64 {
    assert!(num_outcomes > 0, EInvalidMarket);

    let sum_q = uq64_64::from_int(sum_q);
    let n = uq64_64::from_int(num_outcomes);

    // Term1: (1/4) * sum_q_sq
    let term1 = uq64_64::from_quotient(sum_q_sq, 4);

    // Term2: (1/4n) * sum_q^2
    let term2 = sum_q.mul(sum_q).div(uq64_64::from_int(4)).div(n);

    // Term3: (1/n) * sum_q
    let term3 = sum_q.div(n);

    // C(q) = term1 - term2 + term3
    let cost = term1.sub(term2).add(term3);
    cost.to_int()
}

/// Computes the marginal price pᵢ(q) = ∂C/∂qᵢ
/// pᵢ(q) = (1/8)(3qᵢ − ∑_{j≠i} qⱼ) + 1/4
/// Output is unscaled numeraire units
public fun price(sum_q: u64, qi: u64): UQ64_64 {
    // Compute sum_other = sum_q - qi
    let sum_other = safemath::u64_safe::sub(sum_q, qi);

    // price = (1/8)(3qi - sum_other) + 1/4
    uq64_64::from_quotient(3 * (qi as u128), 8)
        .sub(uq64_64::from_quotient(sum_other as u128, 8))
        .add(uq64_64::from_quotient(1, 4))
}

/// Converts amount_in (Δz) to amount_out (Δxᵢ)
/// Formula: Δxᵢ = [-b + sqrt(b² + 4aΔz)] / (2a)
/// where:
///     a = (n−1)/4n
///     b = (1/2)xi − (1/2n)∑x + 1/n
/// ---------------------------------------------
/// Δz = C(x₁, ..., xᵢ + Δxᵢ, ..., xₙ) - C(x)
public fun swap_rate_z_to_xi(xi: u64, sum_x: u128, delta_z: u64, num_outcomes: u64): u64 {
    assert!(num_outcomes > 1, EInvalidMarket);

    let n = num_outcomes as u128;

    // a = (n − 1) / (4n)
    let a = uq64_64::from_quotient(n - 1, 4 * n);

    // b = (xi / 2) - (sum_x / 2n) + (1 / n)
    let b = uq64_64::from_quotient(xi as u128, 2)
        .sub(uq64_64::from_quotient(sum_x, 2 * (num_outcomes as u128)))
        .add(uq64_64::from_quotient(1, n));

    // sqrt_disc = sqrt(b^2 + 4aΔz)
    let disc = b.mul(b).add(a.mul(uq64_64::from_int(delta_z)));
    let sqrt_disc = safemath::uq64_safe::sqrt(disc);

    // (sqrt_disc - b) / 2a
    let delta_xi = sqrt_disc.sub(b).div(uq64_64::from_int(2)).div(a);

    delta_xi.to_int()
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
public fun swap_rate_xi_to_z(xi: u64, sum_x: u128, delta_xi: u64, num_outcomes: u64): u64 {
    assert!(num_outcomes > 1, EInvalidMarket);

    let n = num_outcomes as u128;

    // a = (n − 1) / (4n)
    let a = uq64_64::from_quotient(n - 1, 4 * n);

    // b = (xi / 2) - (sum_x / 2n) + (1 / n)
    let b = uq64_64::from_quotient(xi as u128, 2)
        .sub(uq64_64::from_quotient(sum_x, 2 * (num_outcomes as u128)))
        .add(uq64_64::from_quotient(1, n));

    // z = Δxi × (b − a × Δxi)
    let delta_xi = uq64_64::from_int(delta_xi);
    let delta_z = delta_xi.mul(b.sub(a.mul(delta_xi)));
    delta_z.to_int()
}
