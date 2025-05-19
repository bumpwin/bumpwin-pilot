module mockcoins::white;

use sui::coin::{Self, TreasuryCap, Coin};
use sui::transfer;
use sui::tx_context::TxContext;
use std::option;

public struct WHITE has drop {}

fun init(witness: WHITE, ctx: &mut TxContext) {
    let (treasury_cap, metadata) = coin::create_currency<WHITE>(
        witness,
        6, // decimals
        b"WHITE", // symbol
        b"White Coin", // name
        b"White Coin for mock",
        option::none(),
        ctx,
    );

    transfer::public_share_object(treasury_cap);
    transfer::public_share_object(metadata);
}

public fun mint(cap: &mut TreasuryCap<WHITE>, amount: u64, ctx: &mut TxContext): Coin<WHITE> {
    coin::mint(cap, amount, ctx)
}

#[test_only]
public fun init_for_testing(ctx: &mut TxContext) {
    init(WHITE {}, ctx);
} 