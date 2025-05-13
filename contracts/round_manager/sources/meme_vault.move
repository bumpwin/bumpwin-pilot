module round_manager::meme_vault;

use std::ascii;
use std::string;
use sui::balance::Balance;
use sui::coin::{TreasuryCap, CoinMetadata};
use sui::event;
use sui::url;

const TOTAL_SUPPLY: u64 = 1_000_000_000_000_000; // 1 billion coins (10^9), with 6 decimals → 10^(9+6) base units
const DECIMALS: u8 = 6; // Number of decimal places (1 coin = 10^6 base units)

const EInvalidSupply: u64 = 1;
const EInvalidDecimals: u64 = 2;


public struct NewMemeVaultEvent<phantom CoinT> has drop, copy {
    id: ID,
}

public struct MemeVault<phantom CoinT> has key, store {
    id: UID,
    metadata: CoinMetadata<CoinT>,
    treasury: TreasuryCap<CoinT>,
    links: vector<url::Url>,
    reserve: Balance<CoinT>,
}


public fun new<CoinT>(
    treasury_cap: TreasuryCap<CoinT>,
    metadata: CoinMetadata<CoinT>,
    ctx: &mut TxContext,
): MemeVault<CoinT> {
    assert!(treasury_cap.total_supply() == 0, EInvalidSupply);
    assert!(metadata.get_decimals() == DECIMALS, EInvalidDecimals);

    let mut treasury = treasury_cap;
    let total_balance = treasury.mint(TOTAL_SUPPLY, ctx).into_balance();

    // transfer::public_freeze_object(treasury);

    let vault = MemeVault<CoinT> {
        id: object::new(ctx),
        metadata,
        treasury,
        links: vector[],
        reserve: total_balance,
    };

    event::emit(NewMemeVaultEvent<CoinT> {
        id: vault.id.to_inner(),
    });

    vault
}


public(package) fun update_metadata<CoinT>(
    self: &mut MemeVault<CoinT>,
    name: string::String,
    symbol: ascii::String,
    description: string::String,
    icon_url: url::Url,
) {
    let cap = &self.treasury;
    let metadata = &mut self.metadata;
    cap.update_name(metadata, name);
    cap.update_symbol(metadata, symbol);
    cap.update_description(metadata, description);
    cap.update_icon_url(metadata, icon_url.inner_url());
}