module mockcoins::red;

use sui::coin::{Self, TreasuryCap, Coin};

public struct RED has drop {}

fun init(witness: RED, ctx: &mut TxContext) {
    let (treasury_cap, metadata) = coin::create_currency<RED>(
        witness,
        6, // decimals
        b"RED", // symbol
        b"Red Coin", // name
        b"Red Coin for mock",
        option::none(),
        ctx,
    );

    transfer::public_share_object(treasury_cap);
    transfer::public_share_object(metadata);
}

public fun mint(cap: &mut TreasuryCap<RED>, amount: u64, ctx: &mut TxContext): Coin<RED> {
    cap.mint(amount, ctx)
}

#[test_only]
public fun init_for_testing(ctx: &mut TxContext) {
    init(RED {}, ctx);
}
