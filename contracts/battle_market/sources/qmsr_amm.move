module battle_market::qmsr_amm;

use std::option::{Self, Option};
use sui::object::{Self, UID};
use sui::tx_context::{Self, TxContext};
use sui::table::{Self, Table};
use sui::coin::{Self, Coin};
use sui::balance::{Self, Balance};
use sui::sui::SUI;


/// Bet coin type for each outcome
public struct BETTED_SUI has store { }

/// QMSR AMM state
public struct QMSR_AMM has key, store {
    id: UID,
    bet_reserves: Table<ID, Balance<BETTED_SUI>>,
    sum_square_bets: u64,
    quote_reserve: Balance<SUI>,
}

/// Deposits quote (SUI) into the quote reserve
fun deposit_quote(self: &mut QMSR_AMM, balance_in: Balance<SUI>): u64 {
    self.quote_reserve.join(balance_in)
}

/// Withdraws quote (SUI) from the quote reserve
fun withdraw_quote(self: &mut QMSR_AMM, amount_out: u64): Balance<SUI> {
    self.quote_reserve.split(amount_out)
}

/// Deposits bet shares into the reserve for an outcome
fun deposit_bet_share(self: &mut QMSR_AMM, outcome: ID, balance_in: Balance<BETTED_SUI>): u64 {
    self.bet_reserves.borrow_mut(outcome).join(balance_in)
}

/// Withdraws bet shares from the reserve for an outcome
fun withdraw_bet_share(self: &mut QMSR_AMM, outcome: ID, amount_out: u64): Balance<BETTED_SUI> {
    self.bet_reserves.borrow_mut(outcome).split(amount_out)
}

/// Creates a new QMSR AMM
public fun new(ctx: &mut TxContext): QMSR_AMM {
    QMSR_AMM {
        id: object::new(ctx),
        bet_reserves: table::new(ctx),
        sum_square_bets: 0,
        quote_reserve: balance::zero<SUI>(),
    }
}

/// Gets the bet amount for an outcome
/// Returns 0 if the outcome has no bets
fun bet_reserve_amount(self: &QMSR_AMM, outcome: ID): u64 {
    if (self.bet_reserves.contains(outcome)) {
        self.bet_reserves.borrow(outcome).value()
    } else {
        0
    }
}

/// Calculates the amount of bet shares to receive when buying with quote
/// Formula: (reserves[X]^2 + 2*amount_in)^(1/2) - reserves[X]
public fun swap_rate_quote_to_bet_share(
    self: &QMSR_AMM,
    outcome: ID,
    amount_in: u64
): u64 {
    let reserve = self.bet_reserve_amount(outcome);
    (reserve * reserve + 2 * amount_in).sqrt() - reserve
}

/// Calculates the amount of quote to receive when selling bet shares
/// Formula: reserves[X]*amount_in - (1/2)*amount_in^2
public fun swap_rate_bet_share_to_quote(
    self: &QMSR_AMM,
    outcome: ID,
    amount_in: u64
): u64 {
    let reserve = self.bet_reserve_amount(outcome);
    reserve * amount_in - (amount_in * amount_in) / 2
}

/// Swaps quote (SUI) for bet shares of an outcome
public fun swap_quote_to_bet_share(
    self: &mut QMSR_AMM,
    outcome: ID,
    coin_in: Coin<SUI>,
    ctx: &mut TxContext
): Coin<BETTED_SUI> {
    let amount_out = self.swap_rate_quote_to_bet_share(outcome, coin_in.value());
    self.deposit_quote(coin_in.into_balance());
    self.withdraw_bet_share(outcome, amount_out).into_coin(ctx)
}

/// Swaps bet shares of an outcome for quote (SUI)
public fun swap_bet_share_to_quote(
    self: &mut QMSR_AMM,
    outcome: ID,
    coin_in: Coin<BETTED_SUI>,
    ctx: &mut TxContext
): Coin<SUI> {
    let amount_out = self.swap_rate_bet_share_to_quote(outcome, coin_in.value());
    self.deposit_bet_share(outcome, coin_in.into_balance());
    self.withdraw_quote(amount_out).into_coin(ctx)
}
