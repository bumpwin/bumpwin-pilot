module coin_launcher::launcher;

use std::string::String;
use sui::coin::{Self, TreasuryCap, CoinMetadata};
use sui::url;

public struct LAUNCHER has drop {}

fun init(witness: LAUNCHER, ctx: &mut TxContext) {
    let (cap, metadata) = coin::create_currency(
        witness,
        6,                  // decimals
        b"TBD_SYMBOL",      // symbol
        b"TBD_NAME",        // name
        b"TBD_DESCRIPTION", // description
        option::none(),     // icon_url
        ctx
    );

    transfer::public_transfer(metadata, ctx.sender());
    transfer::public_transfer(cap, ctx.sender())
}

public fun set_and_freeze_metadata(
    cap: &mut TreasuryCap<LAUNCHER>,
    metadata: CoinMetadata<LAUNCHER>,
    name: String,
    symbol: String,
    description: String,
    icon_url: url::Url,
) {
    let mut metadata = metadata;
    cap.update_name(&mut metadata, name);
    cap.update_symbol(&mut metadata, symbol.to_ascii());
    cap.update_description(&mut metadata, description);
    cap.update_icon_url(&mut metadata, icon_url.inner_url());

    transfer::public_freeze_object(metadata);
}

#[test_only]
public fun init_for_testing(ctx: &mut TxContext) {
    init(LAUNCHER {}, ctx);
}