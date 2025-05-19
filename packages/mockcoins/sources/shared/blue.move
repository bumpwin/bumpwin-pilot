module mockcoins::blue;

use sui::coin::{Self, TreasuryCap, Coin};

public struct BLUE has drop {}

fun init(witness: BLUE, ctx: &mut TxContext) {
    let (treasury_cap, metadata) = coin::create_currency<BLUE>(
        witness,
        6, // decimals
        b"BLUE", // symbol
        b"Blue Coin", // name
        b"Blue Coin for mock",
        option::none(),
        ctx,
    );

    transfer::public_share_object(treasury_cap);
    transfer::public_share_object(metadata);
}

public fun mint(cap: &mut TreasuryCap<BLUE>, amount: u64, ctx: &mut TxContext): Coin<BLUE> {
    cap.mint(amount, ctx)
}

#[test_only]
public fun init_for_testing(ctx: &mut TxContext) {
    init(BLUE {}, ctx);
}
