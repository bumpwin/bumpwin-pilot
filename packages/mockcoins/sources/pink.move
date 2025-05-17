module mockcoins::pink;

use sui::coin::{Self, TreasuryCap, Coin};

public struct PINK has drop {}

fun init(witness: PINK, ctx: &mut TxContext) {
    let (treasury_cap, metadata) = coin::create_currency<PINK>(
        witness,
        6, // decimals
        b"PINK", // symbol
        b"Pink Coin", // name
        b"Pink Coin for mock",
        option::none(),
        ctx,
    );

    transfer::public_transfer(treasury_cap, ctx.sender());
    transfer::public_transfer(metadata, ctx.sender());
}

public fun mint(cap: &mut TreasuryCap<PINK>, amount: u64, ctx: &mut TxContext): Coin<PINK> {
    cap.mint(amount, ctx)
}

#[test_only]
public fun init_for_testing(ctx: &mut TxContext) {
    init(PINK {}, ctx);
}
