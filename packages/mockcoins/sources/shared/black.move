module mockcoins::black;

use sui::coin::{Self, TreasuryCap, Coin};
use sui::transfer;
use sui::tx_context::TxContext;
use std::option;

public struct BLACK has drop {}

fun init(witness: BLACK, ctx: &mut TxContext) {
    let (treasury_cap, metadata) = coin::create_currency<BLACK>(
        witness,
        6, // decimals
        b"BLACK", // symbol
        b"Black Coin", // name
        b"Black Coin for mock",
        option::none(),
        ctx,
    );

    transfer::public_share_object(treasury_cap);
    transfer::public_share_object(metadata);
}

public fun mint(cap: &mut TreasuryCap<BLACK>, amount: u64, ctx: &mut TxContext): Coin<BLACK> {
    coin::mint(cap, amount, ctx)
}

#[test_only]
public fun init_for_testing(ctx: &mut TxContext) {
    init(BLACK {}, ctx);
} 