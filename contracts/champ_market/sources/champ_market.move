module champ_market::cpmm;

use sui::coin::{Self, Coin};
use sui::balance::{Self, Balance};
use sui::event;

public struct Pool<phantom X, phantom Y> has key, store {
    id: UID,
    reserve_x: Balance<X>,
    reserve_y: Balance<Y>,
}

public struct SwapEvent has copy, drop, store {
    sender: address,
    direction: bool,
    amount_in: u64,
    amount_out: u64,
}

public fun new_pool<X, Y>(
    init_x: Balance<X>,
    init_y: Balance<Y>,
    ctx: &mut TxContext
): Pool<X, Y> {
    Pool {
        id: object::new(ctx),
        reserve_x: init_x,
        reserve_y: init_y,
    }
}

public fun swap_x_to_y<X, Y>(
    pool: &mut Pool<X, Y>,
    coin_in: Coin<X>,
    ctx: &mut TxContext
): Coin<Y> {
    let sender = ctx.sender();
    let amount_in = coin_in.value();
    assert!(amount_in > 0, 0);

    pool.reserve_x.join(coin_in.into_balance());
    let k = balance::value(&pool.reserve_x) * balance::value(&pool.reserve_y);
    let new_reserve_x = balance::value(&pool.reserve_x);
    let new_reserve_y = k / new_reserve_x;
    let amount_out = balance::value(&pool.reserve_y) - new_reserve_y;
    assert!(amount_out > 0, 1);

    let coin_out = pool.reserve_y.split(amount_out).into_coin(ctx);

    event::emit(SwapEvent {
        sender,
        direction: true,
        amount_in,
        amount_out,
    });

    coin_out
}

public fun swap_y_to_x<X, Y>(
    pool: &mut Pool<X, Y>,
    coin_in: Coin<Y>,
    ctx: &mut TxContext
): Coin<X> {
    let sender = ctx.sender();
    let amount_in = coin_in.value();
    assert!(amount_in > 0, 0);

    pool.reserve_y.join(coin_in.into_balance());

    let k = pool.reserve_x.value() * pool.reserve_y.value();
    let new_reserve_y = pool.reserve_y.value();
    let new_reserve_x = k / new_reserve_y;
    let amount_out = pool.reserve_x.value() - new_reserve_x;
    assert!(amount_out > 0, 1);

    let coin_out = pool.reserve_x.split(amount_out).into_coin(ctx);

    event::emit(SwapEvent {
        sender,
        direction: false,
        amount_in,
        amount_out,
    });

    coin_out
}
