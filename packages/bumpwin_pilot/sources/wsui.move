module bumpwin_pilot::wsui;

use sui::coin::{Self, TreasuryCap, Coin};

public struct WSUI has drop {}

fun init(witness: WSUI, ctx: &mut TxContext) {
    let (treasury_cap, metadata) = coin::create_currency<WSUI>(
        witness,
        9, // decimals (same as SUI)
        b"WSUI", // symbol
        b"Winning SUI", // name
        b"Winning SUI token for the game",
        option::none(),
        ctx,
    );

    transfer::public_share_object(treasury_cap);
    transfer::public_share_object(metadata);
}

public fun mint(cap: &mut TreasuryCap<WSUI>, amount: u64, ctx: &mut TxContext): Coin<WSUI> {
    cap.mint(amount, ctx)
}


#[test_only]
public fun init_for_testing(ctx: &mut TxContext) {
    init(WSUI {}, ctx);
}
