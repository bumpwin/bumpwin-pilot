module battle_market::qmsr_amm;

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

/// Calculates the amount of shares to receive when switching outcomes
fun calculate_switch_shares(
    amm: &QMSR_AMM,
    from: ID,
    to: ID,
    delta_q: u64
): u64 {
    let q_from = if (table::contains(&amm.bet_reserves, from)) {
        balance::value(table::borrow(&amm.bet_reserves, from))
    } else {
        0
    };
    let q_to = if (table::contains(&amm.bet_reserves, to)) {
        balance::value(table::borrow(&amm.bet_reserves, to))
    } else {
        0
    };
    let refund = q_from * delta_q - delta_q * delta_q / 2;
    let x2 = q_to * q_to + 2 * refund;
    let sqrt = math::sqrt(x2);
    assert!(sqrt >= q_to, EInvalidSwitch);
    sqrt - q_to
}

/// Updates the AMM state after a bet
fun update_amm_state(
    amm: &mut QMSR_AMM,
    outcome: ID,
    amount: u64
) {
    // Update reserves
    if (!table::contains(&amm.bet_reserves, outcome)) {
        let balance = balance::zero<BET_COIN>();
        table::add(&mut amm.bet_reserves, outcome, balance);
    };
    let reserve = table::borrow_mut(&mut amm.bet_reserves, outcome);
    let old_amount = balance::value(reserve);
    balance::join(reserve, balance::zero<BET_COIN>());
    update_sum_squares(amm, outcome, old_amount, old_amount + amount);
}

/// Handles coin operations for a bet
fun handle_bet_payment(
    amm: &mut QMSR_AMM,
    coin_in: &mut Coin<SUI>,
    cost: u64,
    ctx: &mut TxContext
): Coin<SUI> {
    let (to_pay, change) = coin::split<SUI>(coin_in, cost, ctx);
    balance::join(&mut amm.vault, coin::into_balance(to_pay));
    change
}

/// Swaps quote (SUI) for outcome shares
public fun swap_quote_to_X(
    amm: &mut QMSR_AMM,
    outcome: ID,
    delta_q: u64,
    coin_in: &mut Coin<SUI>,
    user: address,
    ctx: &mut TxContext
): (Coin<SUI>, Balance<BET_COIN>) {
    let cost = calculate_bet_cost(amm, outcome, delta_q);
    let change = handle_bet_payment(amm, coin_in, cost, ctx);
    update_amm_state(amm, outcome, delta_q);

    // Create and send shares to user
    let share_balance = balance::zero<BET_COIN>();
    transfer::public_transfer(share_balance, user);

    (change, share_balance)
}

/// Swaps outcome shares for quote (SUI)
public fun swap_X_to_quote(
    amm: &mut QMSR_AMM,
    outcome: ID,
    delta_q: u64,
    share_balance: Balance<BET_COIN>,
    ctx: &mut TxContext
): Coin<SUI> {
    let refund = calculate_refund(amm, outcome, delta_q);
    update_amm_state(amm, outcome, delta_q);

    // Destroy the shares
    balance::destroy_zero(share_balance);

    // Handle refund
    let refund_balance = balance::split(&mut amm.vault, refund);
    coin::from_balance(refund_balance, ctx)
}

/// Swaps shares from one outcome to another
public fun swap_X_to_Y(
    amm: &mut QMSR_AMM,
    from: ID,
    to: ID,
    delta_q: u64,
    from_share_balance: Balance<BET_COIN>,
    user: address,
    ctx: &mut TxContext
): Balance<BET_COIN> {
    let delta_x = calculate_switch_shares(amm, from, to, delta_q);
    update_amm_state(amm, from, delta_q);
    update_amm_state(amm, to, delta_x);

    // Destroy old shares and create new ones
    balance::destroy_zero(from_share_balance);
    let to_share_balance = balance::zero<BET_COIN>();
    transfer::public_transfer(to_share_balance, user);

    to_share_balance
}

/// Gets the current price of an outcome
public fun price(amm: &QMSR_AMM, outcome: ID): u64 {
    if (table::contains(&amm.bet_reserves, outcome)) {
        balance::value(table::borrow(&amm.bet_reserves, outcome))
    } else {
        0
    }
}
