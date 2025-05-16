module mockcoins::yellow;

use sui::coin::{Self, TreasuryCap, Coin};
use sui::transfer;
use sui::tx_context::{Self, TxContext};
use std::option;

public struct YELLOW has drop {}

fun init(witness: YELLOW, ctx: &mut TxContext) {
    let (treasury_cap, metadata) = coin::create_currency<YELLOW>(
        witness,
        6, // decimals
        b"YELLOW", // symbol
        b"Yellow Coin", // name
        b"Yellow Coin for mock",
        option::none(),
        ctx,
    );

    transfer::public_transfer(treasury_cap, ctx.sender());
    transfer::public_transfer(metadata, ctx.sender());
}

public fun mint(cap: &mut TreasuryCap<YELLOW>, amount: u64, ctx: &mut TxContext): Coin<YELLOW> {
    cap.mint(amount, ctx)
}

#[test_only]
public fun init_for_testing(ctx: &mut TxContext) {
    init(YELLOW {}, ctx);
} 