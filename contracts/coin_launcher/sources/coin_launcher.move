module coin_launcher::launcher;

use std::string::String;

use sui::coin::{Self, TreasuryCap, CoinMetadata};
use sui::url;

use vault_center::meme_vault::MemeVault;

const AMOUNT: u64 = 1_000_000_000_000_000; // 1 billion coins (10^9), with 6 decimals → 10^(9+6) base units
const DECIMALS: u8 = 6; // Number of decimal places (1 coin = 10^6 base units)


public struct LAUNCHER has drop {}

public struct LaunchCap<phantom LAUNCHER> has key, store {
    id: UID,
    treasury_cap: TreasuryCap<LAUNCHER>,
    metadata: CoinMetadata<LAUNCHER>,
    creator: address,
}

fun init(witness: LAUNCHER, ctx: &mut TxContext) {
    let (treasury_cap, metadata) = coin::create_currency<LAUNCHER>(
        witness,
        DECIMALS,           // decimals
        b"TBD_SYMBOL",      // symbol
        b"TBD_NAME",        // name
        b"TBD_DESCRIPTION", // description
        option::none(),     // icon_url
        ctx
    );

    let launch_cap = LaunchCap<LAUNCHER> {
        id: object::new(ctx),
        treasury_cap,
        metadata,
        creator: ctx.sender(),
    };

    transfer::public_share_object(launch_cap);
}


public fun create_coin(
    launch_cap: LaunchCap<LAUNCHER>,
    vault: &mut MemeVault<LAUNCHER>,
    name: String,
    symbol: String,
    description: String,
    icon_url: url::Url,
    ctx: &mut TxContext,
) {
    let mut launch_cap = launch_cap;
    launch_cap.set_and_freeze_metadata(name, symbol, description, icon_url);
    let coins = launch_cap.treasury_cap.mint(AMOUNT, ctx);
    vault.deposit(coins);

    let LaunchCap { id, treasury_cap, metadata, creator: _ } = launch_cap;
    transfer::public_freeze_object(metadata);
    transfer::public_freeze_object(treasury_cap);
    object::delete(id);
}

fun set_and_freeze_metadata(
    launch_cap: &mut LaunchCap<LAUNCHER>,
    name: String,
    symbol: String,
    description: String,
    icon_url: url::Url,
) {
    let metadata = &mut launch_cap.metadata;
    launch_cap.treasury_cap.update_name(metadata, name);
    launch_cap.treasury_cap.update_symbol(metadata, symbol.to_ascii());
    launch_cap.treasury_cap.update_description(metadata, description);
    launch_cap.treasury_cap.update_icon_url(metadata, icon_url.inner_url());
}


#[test_only]
public fun init_for_testing(ctx: &mut TxContext) {
    init(LAUNCHER {}, ctx);
}