module loser_stakes::revenue_sharing;

use sui::clock::Clock;
use sui::coin;
use sui::object::{Self, UID};
use sui::table::{Self, Table};
use sui::tx_context::TxContext;
use sui::balance;
use sui::transfer;

const FIXED_1: u128 = 1_000_000_000_000_000_000;

public struct UserState has store {
    stake: u64,
    reward: u128,
    paid_rpt: u128,
}

public struct RevenueSharingPool<phantom Reward> has key {
    id: UID,
    total_staked: u64,
    reward_per_token_stored: u128,
    last_update_time: u64,
    reward_rate_per_sec: u64,
    user_states: Table<address, UserState>,
    reward_treasury: coin::TreasuryCap<Reward>,
}

public fun update_global<Reward>(
    pool: &mut RevenueSharingPool<Reward>,
    clock: &Clock,
) {
    let now = clock.timestamp_ms();
    let elapsed = now - pool.last_update_time;

    if (pool.total_staked > 0) {
        let reward = (elapsed as u128) * (pool.reward_rate_per_sec as u128);
        let rpt_delta = reward * FIXED_1 / (pool.total_staked as u128);
        pool.reward_per_token_stored = pool.reward_per_token_stored + rpt_delta;
    };

    pool.last_update_time = now;
}

public fun update_user<Reward>(
    pool: &mut RevenueSharingPool<Reward>,
    user: address,
) {
    let user_state = sui::table::borrow_mut(&mut pool.user_states, user);
    let rpt_diff = pool.reward_per_token_stored - user_state.paid_rpt;
    let earned = (user_state.stake as u128) * rpt_diff / FIXED_1;
    user_state.reward = user_state.reward + earned;
    user_state.paid_rpt = pool.reward_per_token_stored;
}

public fun stake_tokens<Reward>(
    pool: &mut RevenueSharingPool<Reward>,
    user: address,
    amount: u64,
    clock: &Clock,
) {
    update_global(pool, clock);
    update_user(pool, user);

    let user_state = sui::table::borrow_mut(&mut pool.user_states, user);
    user_state.stake = user_state.stake + amount;
    pool.total_staked = pool.total_staked + amount;
}

public fun withdraw_tokens<Reward>(
    pool: &mut RevenueSharingPool<Reward>,
    user: address,
    amount: u64,
    clock: &Clock,
) {
    update_global(pool, clock);
    update_user(pool, user);

    let user_state = sui::table::borrow_mut(&mut pool.user_states, user);
    assert!(user_state.stake >= amount, 0);
    user_state.stake = user_state.stake - amount;
    pool.total_staked = pool.total_staked - amount;
}

public fun claim<Reward>(
    pool: &mut RevenueSharingPool<Reward>,
    user: address,
    clock: &Clock,
): u128 {
    update_global(pool, clock);
    update_user(pool, user);

    let user_state = sui::table::borrow_mut(&mut pool.user_states, user);
    let amount = user_state.reward;
    user_state.reward = 0;
    amount
}

public fun notify_reward<Reward>(
    pool: &mut RevenueSharingPool<Reward>,
    amount: u64,
    duration: u64,
    clock: &Clock,
) {
    update_global(pool, clock);
    pool.reward_rate_per_sec = amount / duration;
    pool.last_update_time = clock.timestamp_ms();
}
