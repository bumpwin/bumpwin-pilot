module coin_launcher::launcher;

use sui::coin::{Self, TreasuryCap};
use sui::transfer::{public_transfer, public_freeze_object};

public struct LAUNCHER has drop {}

fun init(witness: LAUNCHER, ctx: &mut TxContext) {
    let (cap, metadata) = coin::create_currency(
        witness,
        6,               // decimals
        b"MY_COIN",      // name
        b"", b"",        // icon, description
        option::none(),  // optional metadata
        ctx
    );

    public_freeze_object(metadata);
    public_transfer(cap, ctx.sender())
}

public entry fun mint(
    cap: &mut TreasuryCap<LAUNCHER>,
    amount: u64,
    recipient: address,
    ctx: &mut TxContext
) {
    let coin = coin::mint(cap, amount, ctx);
    public_transfer(coin, recipient)
}
