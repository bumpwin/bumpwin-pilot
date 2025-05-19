module champ_market::cpmm;

use std::uq64_64;
use sui::balance::Balance;
use sui::coin::Coin;
use sui::event;

/// Error codes
const EZeroInput: u64 = 0;
const EZeroOutput: u64 = 1;

public struct Pool<phantom X, phantom Y> has key, store {
    id: UID,
    reserve_x: Balance<X>,
    reserve_y: Balance<Y>,
}

public struct SwapEvent has copy, drop, store {
    sender: address,
    is_x_to_y: bool,
    amount_in: u64,
    amount_out: u64,
}

public fun share_pool<X, Y>(coin_x: Coin<X>, coin_y: Coin<Y>, ctx: &mut TxContext): ID {
    let pool = Pool {
        id: object::new(ctx),
        reserve_x: coin_x.into_balance(),
        reserve_y: coin_y.into_balance(),
    };
    let id = pool.id.to_inner();

    transfer::public_share_object(pool);
    id
}

public fun reserve_amount_x<X, Y>(pool: &Pool<X, Y>): u64 {
    pool.reserve_x.value()
}

public fun reserve_amount_y<X, Y>(pool: &Pool<X, Y>): u64 {
    pool.reserve_y.value()
}

fun compute_swap_amount<In, Out>(
    reserve_in: &Balance<In>,
    reserve_out: &Balance<Out>,
    amount_in: u64,
): u64 {
    let new_reserve_in = reserve_in.value() + amount_in;
    let new_reserve_out = uq64_64::from_quotient(
        reserve_in.value() as u128,
        new_reserve_in as u128,
    ).mul(uq64_64::from_int(reserve_out.value()));
    let amount_out = uq64_64::from_int(reserve_out.value()).sub(new_reserve_out).to_int();
    assert!(amount_out > 0, EZeroOutput);
    amount_out
}

public fun swap_x_to_y<X, Y>(
    pool: &mut Pool<X, Y>,
    coin_in: Coin<X>,
    ctx: &mut TxContext,
): Coin<Y> {
    let amount_in = coin_in.value();
    assert!(amount_in > 0, EZeroInput);

    pool.reserve_x.join(coin_in.into_balance());
    let amount_out = compute_swap_amount(&pool.reserve_x, &pool.reserve_y, amount_in);
    let coin_out = pool.reserve_y.split(amount_out).into_coin(ctx);

    event::emit(SwapEvent {
        sender: ctx.sender(),
        is_x_to_y: true,
        amount_in,
        amount_out,
    });

    coin_out
}

public fun swap_y_to_x<X, Y>(
    pool: &mut Pool<X, Y>,
    coin_in: Coin<Y>,
    ctx: &mut TxContext,
): Coin<X> {
    let amount_in = coin_in.value();
    assert!(amount_in > 0, EZeroInput);

    pool.reserve_y.join(coin_in.into_balance());
    let amount_out = compute_swap_amount(&pool.reserve_y, &pool.reserve_x, amount_in);
    let coin_out = pool.reserve_x.split(amount_out).into_coin(ctx);

    event::emit(SwapEvent {
        sender: ctx.sender(),
        is_x_to_y: false,
        amount_in,
        amount_out,
    });

    coin_out
}
