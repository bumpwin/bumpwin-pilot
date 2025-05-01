module battle_market::qmsr_amm;

use std::option::{Self, Option};
use sui::object::{Self, UID};
use sui::tx_context::{Self, TxContext};
use sui::table::{Self, Table};
use sui::coin::{Self, Coin};
use sui::balance::{Self, Balance};
use sui::sui::SUI;

/// Error codes for the QMSR AMM
const EInvalidOutcome: u64 = 0;    // Invalid outcome ID
const EInsufficientShares: u64 = 1; // User doesn't have enough shares

/// Share token type for a specific outcome
/// Represents a claim token that can be redeemed for 1 SUI if the outcome is correct
public struct SHARE_COIN<phantom Outcome> has store { }

/// QMSR AMM state
public struct QMSR_AMM has key, store {
    id: UID,
    share_vector: Table<ID, u64>,
    quote_reserve: Balance<SUI>,
}



// /// Deposits quote (SUI) into the quote reserve
// fun deposit_quote(self: &mut QMSR_AMM, balance_in: Balance<SUI>): u64 {
//     self.quote_reserve.join(balance_in)
// }

// /// Withdraws quote (SUI) from the quote reserve
// fun withdraw_quote(self: &mut QMSR_AMM, amount_out: u64): Balance<SUI> {
//     self.quote_reserve.split(amount_out)
// }

// /// Deposits share tokens into the vector
// fun deposit_share(self: &mut QMSR_AMM, outcome: ID, amount: u64) {
//     let current = self.share_vector.borrow_mut(outcome);
//     *current = *current + amount;
// }

// /// Withdraws share tokens from the vector
// fun withdraw_share(self: &mut QMSR_AMM, outcome: ID, amount: u64) {
//     assert!(self.share_vector.contains(outcome), EInvalidOutcome);
//     let current = self.share_vector.borrow_mut(outcome);
//     assert!(*current >= amount, EInsufficientShares);
//     *current = *current - amount;
//     let squared = self.squared_share_vector.borrow_mut(outcome);
//     *squared = *squared - amount * amount;
//     self.sum_squared_shares = self.sum_squared_shares - amount * amount;
// }

// /// Creates a new QMSR AMM
// public fun new(ctx: &mut TxContext): QMSR_AMM {
//     QMSR_AMM {
//         id: object::new(ctx),
//         share_vector: table::new(ctx),
//         squared_share_vector: table::new(ctx),
//         sum_squared_shares: 0,
//         quote_reserve: balance::zero<SUI>(),
//     }
// }

// /// Gets the share amount for the outcome
// public fun share_ith(self: &QMSR_AMM, outcome: ID): u64 {
//     assert!(self.share_vector.contains(outcome), EInvalidOutcome);
//     *self.share_vector.borrow(outcome)
// }

// /// Calculates the amount of shares to receive when buying with quote
// /// Formula: (shares[i]^2 + 2*amount_in)^(1/2) - shares[i]
// public fun swap_rate_quote_to_share(self: &QMSR_AMM, outcome: ID, quote_in: u64): u64 {
//     let shares_i = self.share_ith(outcome);
//     (shares_i * shares_i + 2 * quote_in).sqrt() - shares_i
// }

// /// Calculates the amount of quote to receive when selling shares
// /// Formula: shares[i]*amount_in - (1/2)*amount_in^2
// public fun swap_rate_share_to_quote(self: &QMSR_AMM, outcome: ID, share_in: u64): u64 {
//     let shares_i = self.share_ith(outcome);
//     shares_i * share_in - (share_in * share_in) / 2
// }

// // /// Swaps quote (SUI) for share tokens of the outcome
// // public fun swap_quote_to_share<Outcome>(
// //     self: &mut QMSR_AMM,
// //     outcome: ID,
// //     coin_in: Coin<SUI>,
// //     ctx: &mut TxContext
// // ): Coin<SHARE_COIN<Outcome>> {
// //     let amount_out = self.swap_rate_quote_to_share(outcome, coin_in.value());
// //     self.deposit_quote(coin_in.into_balance());
// //     self.deposit_share(outcome, amount_out);
// //     coin::mint(amount_out, ctx)
// // }

// // /// Swaps share tokens of the outcome for quote (SUI)
// // public fun swap_share_to_quote<Outcome>(
// //     self: &mut QMSR_AMM,
// //     outcome: ID,
// //     coin_in: Coin<SHARE_COIN<Outcome>>,
// //     ctx: &mut TxContext
// // ): Coin<SUI> {
// //     let amount_out = self.swap_rate_share_to_quote(outcome, coin_in.value());
// //     self.withdraw_share(outcome, coin_in.value());
// //     coin::destroy_zero(coin_in);
// //     self.withdraw_quote(amount_out).into_coin(ctx)
// // }
