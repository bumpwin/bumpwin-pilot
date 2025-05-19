module mockcoins::cyan;

use sui::coin::{Self, TreasuryCap, Coin};

public struct CYAN has drop {}

fun init(witness: CYAN, ctx: &mut TxContext) {
    let (treasury_cap, metadata) = coin::create_currency<CYAN>(
        witness,
        6, // decimals
        b"CYAN", // symbol
        b"Cyan Coin", // name
        b"Cyan Coin for mock",
        option::none(),
        ctx,
    );

    transfer::public_transfer(treasury_cap, ctx.sender());
    transfer::public_transfer(metadata, ctx.sender());
}

public fun mint(cap: &mut TreasuryCap<CYAN>, amount: u64, ctx: &mut TxContext): Coin<CYAN> {
    cap.mint(amount, ctx)
}

#[test_only]
public fun init_for_testing(ctx: &mut TxContext) {
    init(CYAN {}, ctx);
}
