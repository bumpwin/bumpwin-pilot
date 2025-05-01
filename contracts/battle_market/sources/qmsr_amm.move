module battle_market::qmsr_amm;

use sui::object::{Self, UID};
use sui::transfer;
use sui::tx_context::{Self, TxContext};
use sui::table::{Self, Table};
use sui::bag;
use sui::clock::{Self, Clock};
use sui::dynamic_field as field;

const EOutcomeNotFound: u64 = 0;
const EAlreadySettled: u64 = 1;

public struct Market has key {
    id: UID,
    total_bets: Table<u64, u64>,                  // outcome_id → total q_i
    user_shares: Table<address, Table<u64, u64>>, // user → (outcome_id → share)
    is_settled: bool,
    winning_outcome: u64,
}

public fun create(ctx: &mut TxContext): Market {
    let total_bets = table::new(ctx);
    let user_shares = table::new(ctx);
    let id = object::new(ctx);
    Market {
        id,
        total_bets,
        user_shares,
        is_settled: false,
        winning_outcome: 0,
    }
}

fun sum_squares(table: &Table<u64, u64>, i: u64, len: u64): u64 {
    if (i >= len) {
        0
    } else {
        let q_i = table::borrow(table, i);
        (*q_i) * (*q_i) + sum_squares(table, i + 1, len)
    }
}

public fun cost(market: &Market): u64 {
    let total_bets = &market.total_bets;
    let len = table::length(total_bets);
    sum_squares(total_bets, 0, len) / 2
}

public fun bet(
    market: &mut Market,
    outcome: u64,
    amount: u64,
    user: address,
    ctx: &mut TxContext
): u64 {
    let cost_before = cost(market);

    // 更新: outcome への累積ベット量
    let q_i = if (table::contains(&market.total_bets, outcome)) {
        *table::borrow(&market.total_bets, outcome)
    } else {
        0
    };
    table::add(&mut market.total_bets, outcome, q_i + amount);

    // 更新: user の share 持分
    if (!table::contains(&market.user_shares, user)) {
        table::add(&mut market.user_shares, user, table::new(ctx));
    };
    let user_table = table::borrow_mut(&mut market.user_shares, user);
    let prev = if (table::contains(user_table, outcome)) {
        *table::borrow(user_table, outcome)
    } else {
        0
    };
    table::add(user_table, outcome, prev + amount);

    let cost_after = cost(market);
    cost_after - cost_before
}

public fun price(market: &Market, outcome: u64): u64 {
    if (table::contains(&market.total_bets, outcome)) {
        *table::borrow(&market.total_bets, outcome)
    } else {
        0
    }
}

public fun settle(market: &mut Market, outcome: u64) {
    assert!(!market.is_settled, EAlreadySettled);
    market.is_settled = true;
    market.winning_outcome = outcome;
}

public fun claim(
    market: &mut Market,
    user: address
): u64 {
    assert!(market.is_settled, EOutcomeNotFound);
    if (!table::contains(&market.user_shares, user)) {
        return 0
    };
    let user_table = table::borrow(&market.user_shares, user);
    if (!table::contains(user_table, market.winning_outcome)) {
        return 0
    };
    let shares = *table::borrow(user_table, market.winning_outcome);
    let user_table = table::remove(&mut market.user_shares, user);
    table::drop(user_table);
    shares
}
