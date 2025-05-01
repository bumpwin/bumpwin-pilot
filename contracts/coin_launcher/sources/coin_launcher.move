module coin_launcher::launcher;

use std::string::String;

use sui::coin::{Self, TreasuryCap, CoinMetadata};
use sui::url;

use battle_market::meme_treasury::MemeTreasury;

const AMOUNT: u64 = 1_000_000_000_000_000; // 1 billion coins (10^9), with 6 decimals → 10^(9+6) base units
const DECIMALS: u8 = 6; // Number of decimal places (1 coin = 10^6 base units)



public struct LAUNCHER has drop {}

fun init(witness: LAUNCHER, ctx: &mut TxContext) {
    let (cap, metadata) = coin::create_currency(
        witness,
        DECIMALS,                  // decimals
        b"TBD_SYMBOL",      // symbol
        b"TBD_NAME",        // name
        b"TBD_DESCRIPTION", // description
        option::none(),     // icon_url
        ctx
    );

    transfer::public_transfer(metadata, ctx.sender());
    transfer::public_transfer(cap, ctx.sender())
}

public fun create_coin(
    cap: &mut TreasuryCap<LAUNCHER>,
    treasury: &mut MemeTreasury<LAUNCHER>,
    metadata: CoinMetadata<LAUNCHER>,
    name: String,
    symbol: String,
    description: String,
    icon_url: url::Url,
    ctx: &mut TxContext,
) {
    set_and_freeze_metadata(cap, metadata, name, symbol, description, icon_url);
    mint_to_treasury(cap, treasury, AMOUNT, ctx);
}

fun set_and_freeze_metadata(
    cap: &TreasuryCap<LAUNCHER>,
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


fun mint_to_treasury(
    cap: &mut TreasuryCap<LAUNCHER>,
    treasury: &mut MemeTreasury<LAUNCHER>,
    amount: u64,
    ctx: &mut TxContext,
) {
    let coins = cap.mint(amount, ctx);
    treasury.deposit(coins);
}


#[test_only]
public fun init_for_testing(ctx: &mut TxContext) {
    init(LAUNCHER {}, ctx);
}