module bumpwin_pilot::champ_amm;

use sui::balance::Balance;

public struct ChampAMM<phantom X, phantom Y> has key, store {
    id: UID,
    reserve_x: Balance<X>,
    reserve_y: Balance<Y>,
}

public fun new<X, Y>(
    reserve_x: Balance<X>,
    reserve_y: Balance<Y>,
    ctx: &mut TxContext,
): ChampAMM<X, Y> {
    ChampAMM<X, Y> {
        id: object::new(ctx),
        reserve_x,
        reserve_y,
    }
}
