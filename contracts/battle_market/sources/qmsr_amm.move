module battle_market::qmsr_amm;

use std::u64;
use std::option::{Self, Option};
use sui::object::{Self, UID};
use sui::transfer;
use sui::tx_context::{Self, TxContext};
use sui::table::{Self, Table};
use sui::coin::{Self, Coin};
use sui::balance::{Self, Balance};
use sui::sui::SUI;
use sui::math;
use sui::object::ID;

/// Error codes for the QMSR AMM
const EInsufficientShares: u64 = 0; // User doesn't have enough shares
const EInvalidSwitch: u64 = 1;      // Invalid outcome switch operation

/// Bet coin type for each outcome
public struct BET_COIN has store { }

/// QMSR AMM state
public struct QMSR_AMM has key, store {
    id: UID,
    bet_reserves: Table<ID, Balance<BET_COIN>>,
    sum_square_bets: u64,
    vault: Balance<SUI>,
}

/// Creates a new QMSR AMM
public fun create(ctx: &mut TxContext): QMSR_AMM {
    QMSR_AMM {
        id: object::new(ctx),
        bet_reserves: table::new(ctx),
        sum_square_bets: 0,
        vault: balance::zero<SUI>(),
    }
}

/// Calculates the sum of squares of all outcomes' bet amounts
fun sum_squares(amm: &QMSR_AMM): u64 {
    amm.sum_square_bets
}

/// Updates the sum of squares after a bet
fun update_sum_squares(amm: &mut QMSR_AMM, outcome: ID, old_amount: u64, new_amount: u64) {
    let old_square = old_amount * old_amount;
    let new_square = new_amount * new_amount;
    amm.sum_square_bets = amm.sum_square_bets - old_square + new_square;
}

/// Calculates the current cost of the market
public fun cost(amm: &QMSR_AMM): u64 {
    amm.sum_square_bets / 2
}

/// Calculates the cost of a bet operation
fun calculate_bet_cost(
    amm: &QMSR_AMM,
    outcome: ID,
    amount: u64
): u64 {
    let cost_before = cost(amm);
    let q_i = if (table::contains(&amm.bet_reserves, outcome)) {
        balance::value(table::borrow(&amm.bet_reserves, outcome))
    } else {
        0
    };
    let new_q_i = q_i + amount;
    let cost_after = cost(amm) + (new_q_i * new_q_i - q_i * q_i) / 2;
    cost_after - cost_before
}

/// Calculates the refund for selling shares
fun calculate_refund(
    amm: &QMSR_AMM,
    outcome: ID,
    delta_q: u64
): u64 {
    let q_i = if (table::contains(&amm.bet_reserves, outcome)) {
        balance::value(table::borrow(&amm.bet_reserves, outcome))
    } else {
        0
    };
    assert!(q_i >= delta_q, EInsufficientShares);
    q_i * delta_q - delta_q * delta_q / 2
}

/// Gets the reserve value for an outcome
fun reserve_x(amm: &QMSR_AMM, outcome: ID): u64 {
    if (amm.bet_reserves.contains(outcome)) {
        amm.bet_reserves.borrow(outcome).value()
    } else {
        0
    }
}

/// Calculates the amount of shares to receive when buying with quote
/// coin_out = sqrt(reserves[X]^2 + 2*coin_in) - reserves[X]
fun swap_rate_quote_to_bet_share(
    amm: &QMSR_AMM,
    outcome: ID,
    amount_in: u64
): u64 {
    let reserve = amm.reserve_x(outcome);
    (reserve * reserve + 2 * amount_in).sqrt() - reserve
}

/// Calculates the amount of quote to receive when selling shares
/// coin_out = reserves[X]*coin_in - (1/2)*coin_in^2
fun swap_rate_bet_share_to_quote(
    amm: &QMSR_AMM,
    outcome: ID,
    amount_in: u64
): u64 {
    let reserve = amm.reserve_x(outcome);
    reserve * amount_in - (amount_in * amount_in) / 2
}

fun deposit_bet_share(amm: &mut QMSR_AMM, outcome: ID, balance_in: Balance<BET_COIN>): u64 {
    amm.bet_reserves.borrow_mut(outcome).join(balance_in)
}

fun withdraw_bet_share(amm: &mut QMSR_AMM, outcome: ID, amount_out: u64): Balance<BET_COIN> {
    amm.bet_reserves.borrow_mut(outcome).split(amount_out)
}

/// Swaps quote (SUI) for outcome shares
public fun swap_quote_to_bet_share(
    amm: &mut QMSR_AMM,
    outcome: ID,
    coin_in: Coin<SUI>,
    ctx: &mut TxContext
): Coin<BET_COIN> {
    let amount_out = amm.swap_rate_quote_to_bet_share(outcome, coin_in.value());

    amm.vault.join(coin_in.into_balance());
    amm.withdraw_bet_share(outcome, amount_out).into_coin(ctx)
}

public fun swap_bet_share_to_quote(
    amm: &mut QMSR_AMM,
    outcome: ID,
    coin_in: Coin<BET_COIN>,
    ctx: &mut TxContext
): Coin<SUI> {
    let amount_out = amm.swap_rate_bet_share_to_quote(outcome, coin_in.value());

    amm.deposit_bet_share(outcome, coin_in.into_balance());
    amm.vault.split(amount_out).into_coin(ctx)
}
