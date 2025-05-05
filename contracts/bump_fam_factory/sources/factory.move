module bump_fam_factory::bump_fam_factory;

use std::ascii;
use std::string;
use sui::balance::{Self, Balance};
use sui::coin::{TreasuryCap, CoinMetadata};
use sui::event;
use sui::url;

use bump_fam_factory::vault;

const AMOUNT: u64 = 1_000_000_000_000_000; // 1 billion coins (10^9), with 6 decimals → 10^(9+6) base units
const DECIMALS: u8 = 6; // Number of decimal places (1 coin = 10^6 base units)

const EInvalidSupply: u64 = 1;
const EInvalidDecimals: u64 = 2;

public struct CreateCoinEvent<phantom CoinT> has drop, copy {
    name: string::String,
    symbol: ascii::String,
    description: string::String,
    icon_url: url::Url,
}


public fun create_coin<CoinT>(
    treasury_cap: TreasuryCap<CoinT>,
    metadata: CoinMetadata<CoinT>,
    name: string::String,
    symbol: ascii::String,
    description: string::String,
    icon_url: url::Url,
    ctx: &mut TxContext,
) {
    assert!(treasury_cap.total_supply() == 0, EInvalidSupply);
    assert!(metadata.get_decimals() == DECIMALS, EInvalidDecimals);

    let mut treasury_cap = treasury_cap;
    let mut metadata = metadata;

    let (mut vault, admin_cap) = vault::new<CoinT>(ctx);
    let supply = treasury_cap.mint(AMOUNT, ctx).into_balance();
    vault.deposit(supply);

    update_metadata(&treasury_cap, &mut metadata, name, symbol, description, icon_url);

    event::emit(
        CreateCoinEvent<CoinT> {
            name,
            symbol,
            description,
            icon_url,
        }
    );

    transfer::public_share_object(vault);
    transfer::public_share_object(admin_cap);
    transfer::public_freeze_object(treasury_cap);
    transfer::public_freeze_object(metadata);
}

fun update_metadata<CoinT>(
    treasury_cap: &TreasuryCap<CoinT>,
    metadata: &mut CoinMetadata<CoinT>,
    name: string::String,
    symbol: ascii::String,
    description: string::String,
    icon_url: url::Url,
) {
    treasury_cap.update_name(metadata, name);
    treasury_cap.update_symbol(metadata, symbol);
    treasury_cap.update_description(metadata, description);
    treasury_cap.update_icon_url(metadata, icon_url.inner_url());
}

