module mockcoins::brown;

use sui::coin::{Self, TreasuryCap, Coin};
use sui::transfer;
use sui::tx_context::TxContext;
use std::option;

public struct BROWN has drop {}

fun init(witness: BROWN, ctx: &mut TxContext) {
    let (treasury_cap, metadata) = coin::create_currency<BROWN>(
        witness,
        6, // decimals
        b"BROWN", // symbol
        b"Brown Coin", // name
        b"Brown Coin for mock",
        option::none(),
        ctx,
    );

    transfer::public_share_object(treasury_cap);
    transfer::public_share_object(metadata);
}

public fun mint(cap: &mut TreasuryCap<BROWN>, amount: u64, ctx: &mut TxContext): Coin<BROWN> {
    coin::mint(cap, amount, ctx)
}

#[test_only]
public fun init_for_testing(ctx: &mut TxContext) {
    init(BROWN {}, ctx);
} 