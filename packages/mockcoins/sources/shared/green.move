module mockcoins::green;

use sui::coin::{Self, TreasuryCap, Coin};

public struct GREEN has drop {}

fun init(witness: GREEN, ctx: &mut TxContext) {
    let (treasury_cap, metadata) = coin::create_currency<GREEN>(
        witness,
        6, // decimals
        b"GREEN", // symbol
        b"Green Coin", // name
        b"Green Coin for mock",
        option::none(),
        ctx,
    );

    transfer::public_share_object(treasury_cap);
    transfer::public_share_object(metadata);
}

public fun mint(cap: &mut TreasuryCap<GREEN>, amount: u64, ctx: &mut TxContext): Coin<GREEN> {
    cap.mint(amount, ctx)
}

#[test_only]
public fun init_for_testing(ctx: &mut TxContext) {
    init(GREEN {}, ctx);
}
