module battle_market::market;

use std::option::{Self, Option};
use std::vector;
use sui::object::{Self, UID, ID};
use sui::tx_context::{Self, TxContext};
use battle_market::qmsr_amm::{Self, QMSR_AMM};

/// Error codes for the market
const EOutcomeNotFound: u64 = 0;    // Outcome not found in the market
const EAlreadySettled: u64 = 1;     // Market is already settled

/// Market state
public struct Market has key {
    id: UID,
    outcome_numbers: u64,
    outcome_ids: vector<ID>,
    amm: QMSR_AMM,
    is_settled: bool,
    winning_outcome: Option<ID>,
}

// /// Creates a new market
// public fun create(outcome_numbers: u64, ctx: &mut TxContext): Market {
//     let mut outcome_ids = vector[];
//     let mut i = 0;
//     while (i < outcome_numbers) {
//         let obj = object::new(ctx);
//         vector::push_back(&mut outcome_ids, object::uid_to_inner(&obj));
//         i = i + 1;
//     };
//     let id = object::new(ctx);
//     Market {
//         id,
//         outcome_numbers,
//         outcome_ids,
//         amm: qmsr_amm::create(ctx),
//         is_settled: false,
//         winning_outcome: option::none(),
//     }
// }

/// Gets the current price of an outcome
public fun price(market: &Market, outcome: ID): u64 {
    qmsr_amm::price(&market.amm, outcome)
}

/// Settles the market with a winning outcome
public fun settle(market: &mut Market, outcome: ID) {
    assert!(!market.is_settled, EAlreadySettled);
    market.is_settled = true;
    market.winning_outcome = option::some(outcome);
}