module mockcoins::wsui;

use sui::coin::{Self, TreasuryCap, Coin};
use sui::tx_context::{Self, TxContext};

public struct WSUI has drop {}

fun init(witness: WSUI, ctx: &mut TxContext) {
    let (treasury_cap, metadata) = coin::create_currency<WSUI>(
        witness,
        6, // decimals
        b"WSUI", // symbol
        b"Winning Sui", // name
        b"Winning Sui for mock",
        option::none(),
        ctx,
    );

    transfer::public_transfer(treasury_cap, ctx.sender());
    transfer::public_transfer(metadata, ctx.sender());
}

public fun mint(cap: &mut TreasuryCap<WSUI>, amount: u64, ctx: &mut TxContext): Coin<WSUI> {
    cap.mint(amount, ctx)
}

#[test_only]
public fun init_for_testing(ctx: &mut TxContext) {
    init(WSUI {}, ctx);
}
