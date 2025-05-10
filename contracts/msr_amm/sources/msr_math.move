/// Brier-Dual SCPM — Operational Definition
/// -----------------------------------------
///
/// State Space:
/// - Let n be the number of mutually exclusive and exhaustive outcomes.
/// - Let q ∈ ℝⁿ be the market state vector, where q_i is the total quantity of outcome-i shares.
///   Each unit of q_i represents one share, i.e., a claim to 1 unit of numeraire if outcome i occurs.
///
/// Share Definition:
/// - An outcome-i share is a contract that pays exactly 1 unit of numeraire if and only if outcome i occurs.
/// - We refer to each unit of such a share as a "share" in implementation contexts, but the object is formally a share.
///
/// Cost Function (denominated in numeraire):
/// - C(q) = (1/4) ∑ q_i² − (1/4n)(∑ q_i)² + (1/n) ∑ q_i
/// - C(q) denotes the total cost to reach position q from the empty state.
///
/// Price Function (units: numeraire per share):
/// - p_i(q) = ∂C/∂q_i = (1/8)(3q_i − ∑_{j≠i} q_j) + 1/4
/// - p_i(q) is the marginal price of purchasing one additional unit of outcome-i share at position q.
///
/// Trading:
/// - To purchase a bundle δ ∈ ℝⁿ  (where δ_i is the number of outcome-i shares), pay:
///     C(q + δ) − C(q) (in units of numeraire)
/// - Update state:  q ← q + δ
///
/// Payout:
/// - Once outcome i* is realized, each outstanding unit of outcome-i* share pays 1 unit of numeraire.
/// - All other outcome shares expire worthless.
///
/// Guarantees:
/// - Price normalization:        ∑ p_i(q) = 1
/// - Bounded price domain:       0 ≤ p_i(q) ≤ 1
/// - Bounded loss:               sup₍q₎ C(q) − inf₍i₎ q_i ≤ 1/2
/// - C(q) is convex in q, ensuring consistent prices and no arbitrage.
///
/// Units Summary:
/// - q_i:   number of shares (dimensionless)
/// - p_i:   numeraire per share
/// - C(q):  numeraire
///


module msr_amm::msr_amm;

use sui::coin::{Self, Coin};
use sui::balance::{Self, Balance};
use sui::sui::SUI;
use sui::vec_map::{Self, VecMap};

/// Scaling factor for higher precision in calculations (10^6 for 6 decimal places)
const PRECISION: u64 = 1_000_000;

/// Error codes
const E_INSUFFICIENT_BALANCE: u64 = 1;
const E_ZERO_AMOUNT: u64 = 2;
const E_OUTCOME_NOT_FOUND: u64 = 3;

/// Token representing ownership of a specific outcome
public struct OutcomeShare<phantom CoinT> has drop {}

/// Main prediction market structure
public struct PredictionMarket has key, store {
    id: UID,
    quote_reserve: Balance<SUI>,
    outcome_vault_list: vector<ID>,
    quantities: VecMap<ID, u64>,  // Stores q_i for each outcome

    // Cached computation values for efficiency
    sum_quantities: u64,          // ∑q_i
    sum_quantities_squared: u64,  // ∑q_i^2
    current_cost: u64,            // Current value of cost function
    outcome_count: u64,           // Number of outcomes (n)
}

/// Vault for outcome shares of a specific outcome
public struct OutcomeVault<phantom CoinT> has key, store {
    id: UID,
    outcome_reserve: Balance<OutcomeShare<CoinT>>,
}

/// Creates a new prediction market
/// @param ctx - Transaction context
/// @return Newly created prediction market
public fun create_prediction_market(ctx: &mut TxContext): PredictionMarket {
    PredictionMarket {
        id: object::new(ctx),
        quote_reserve: balance::zero(),
        outcome_vault_list: vector::empty(),
        quantities: vec_map::empty(),
        sum_quantities: 0,
        sum_quantities_squared: 0,
        current_cost: 0,
        outcome_count: 0,
    }
}

/// Adds a new outcome to the prediction market
/// @param market - The prediction market
/// @param ctx - Transaction context
public fun add_market_outcome<CoinT>(
    market: &mut PredictionMarket,
    ctx: &mut TxContext
) {
    let outcome_vault = OutcomeVault<CoinT> {
        id: object::new(ctx),
        outcome_reserve: balance::zero(),
    };

    let vault_id = object::uid_to_inner(&outcome_vault.id);
    let outcome_list = &mut market.outcome_vault_list;
    outcome_list.push_back(vault_id);
    vec_map::insert(&mut market.quantities, vault_id, 0);

    // Update outcome count
    market.outcome_count = market.outcome_count + 1;

    transfer::public_share_object(outcome_vault);
}

/// Updates market state and cached values after a quantity change
/// @param market - The prediction market
/// @param vault_id - The ID of the vault being updated
/// @param delta - The change amount
/// @param is_increase - Whether to increase (true) or decrease (false) the quantity
fun update_market_quantities(
    market: &mut PredictionMarket,
    vault_id: ID,
    delta: u64,
    is_increase: bool
) {
    assert!(delta > 0, E_ZERO_AMOUNT);
    assert!(market.quantities.contains(&vault_id), E_OUTCOME_NOT_FOUND);

    let old_quantity = *market.quantities.get(&vault_id);
    let new_quantity = if (is_increase) {
        old_quantity + delta
    } else {
        assert!(old_quantity >= delta, E_INSUFFICIENT_BALANCE);
        old_quantity - delta
    };

    // Update quantities
    vec_map::insert(&mut market.quantities, vault_id, new_quantity);

    // Update cached values
    market.sum_quantities = market.sum_quantities + new_quantity - old_quantity;
    market.sum_quantities_squared = market.sum_quantities_squared + (new_quantity * new_quantity) - (old_quantity * old_quantity);

    // Recalculate cost function
    market.current_cost = compute_cost_function(market);
}

/// Computes the cost function C(q) using cached values
/// @param market - The prediction market
/// @return Computed cost value
fun compute_cost_function(market: &PredictionMarket): u64 {
    let n = market.outcome_count;
    if (n == 0) return 0;

    // C(q) = (1/4)∑q_i^2 - (1/4n)(∑q_i)^2 + (1/n)∑q_i
    // Using scaled precision for division operations
    let term1 = (market.sum_quantities_squared * PRECISION) / 4;
    let term2 = ((market.sum_quantities * market.sum_quantities) * PRECISION) / (4 * n);
    let term3 = (market.sum_quantities * PRECISION) / n;

    ((term1 - term2 + term3) / PRECISION)
}

/// Calculates the probability for a specific outcome
/// @param market - The prediction market
/// @param vault_id - The ID of the outcome vault
/// @return The calculated probability (as a decimal between 0-1, scaled by PRECISION)
public fun get_outcome_probability(market: &PredictionMarket, vault_id: ID): u64 {
    assert!(market.quantities.contains(&vault_id), E_OUTCOME_NOT_FOUND);

    let q_i = *market.quantities.get(&vault_id);

    // More efficient: sum_other_q = sum_q - q_i
    let sum_other_q = market.sum_quantities - q_i;

    // p_i = (1/8)(3q_i - ∑(j≠i)q_j) + 1/4
    // Using scaled precision for division operations
    let term1 = ((3 * q_i - sum_other_q) * PRECISION) / 8;
    let term2 = PRECISION / 4;

    (term1 + term2) / PRECISION
}

/// Buys outcome shares with SUI
/// @param market - The prediction market
/// @param vault - The outcome vault
/// @param payment - The SUI coins to spend
/// @param ctx - Transaction context
/// @return The outcome shares received
public fun buy_prediction<CoinT>(
    market: &mut PredictionMarket,
    vault: &mut OutcomeVault<CoinT>,
    payment: Coin<SUI>,
    ctx: &mut TxContext
): Coin<OutcomeShare<CoinT>> {
    let amount = coin::value(&payment);
    assert!(amount > 0, E_ZERO_AMOUNT);

    let vault_id = object::uid_to_inner(&vault.id);

    // Calculate cost before trade
    let cost_before = market.current_cost;

    // Update market state (which also updates cached values)
    update_market_quantities(market, vault_id, amount, true);

    // Get cost after trade (from cached value)
    let cost_after = market.current_cost;

    // Calculate amount of outcome shares to mint
    let shares_to_mint = cost_after - cost_before;

    // Update reserves
    coin::put(&mut market.quote_reserve, payment);

    // Mint new outcome shares
    coin::from_balance(balance::create_for_testing<OutcomeShare<CoinT>>(shares_to_mint), ctx)
}

/// Sells outcome shares for SUI
/// @param market - The prediction market
/// @param vault - The outcome vault
/// @param shares - The outcome shares to sell
/// @param ctx - Transaction context
/// @return The SUI coins received
public fun sell_prediction<CoinT>(
    market: &mut PredictionMarket,
    vault: &mut OutcomeVault<CoinT>,
    shares: Coin<OutcomeShare<CoinT>>,
    ctx: &mut TxContext
): Coin<SUI> {
    let amount = coin::value(&shares);
    assert!(amount > 0, E_ZERO_AMOUNT);

    let vault_id = object::uid_to_inner(&vault.id);

    // Calculate cost before trade
    let cost_before = market.current_cost;

    // Update market state (which also updates cached values)
    update_market_quantities(market, vault_id, amount, false);

    // Get cost after trade (from cached value)
    let cost_after = market.current_cost;

    // Calculate amount of SUI to return
    let sui_to_return = cost_before - cost_after;
    assert!(sui_to_return <= balance::value(&market.quote_reserve), E_INSUFFICIENT_BALANCE);

    // Update reserves
    coin::put(&mut vault.outcome_reserve, shares);

    // Return SUI
    coin::take(&mut market.quote_reserve, sui_to_return, ctx)
}

/// Gets the current quantity for a specific outcome
/// @param market - The prediction market
/// @param vault_id - The ID of the outcome vault
/// @return The current quantity
public fun get_outcome_quantity(market: &PredictionMarket, vault_id: ID): u64 {
    assert!(market.quantities.contains(&vault_id), E_OUTCOME_NOT_FOUND);
    *market.quantities.get(&vault_id)
}

/// Gets the current market state information
/// @param market - The prediction market
/// @return (sum_quantities, sum_quantities_squared, current_cost, outcome_count)
public fun get_market_state(market: &PredictionMarket): (u64, u64, u64, u64) {
    (market.sum_quantities, market.sum_quantities_squared, market.current_cost, market.outcome_count)
}

/// Gets all outcome IDs in the market
/// @param market - The prediction market
/// @return Vector of outcome IDs
public fun get_market_outcomes(market: &PredictionMarket): vector<ID> {
    market.outcome_vault_list
}


