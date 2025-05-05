module bump_fam_factory::vault;

use sui::balance::{Self, Balance};
use sui::coin::{Self, Coin};
use sui::coin::{TreasuryCap, CoinMetadata};

const AMOUNT: u64 = 1_000_000_000_000_000; // 1 billion coins (10^9), with 6 decimals → 10^(9+6) base units
const DECIMALS: u8 = 6; // Number of decimal places (1 coin = 10^6 base units)

const EInvalidSupply: u64 = 1;
const EInvalidDecimals: u64 = 2;
const EInvalidAdminCap: u64 = 3;

public struct BumpWinCoinVault<phantom CoinT> has key, store {
    id: UID,
    reserve: Balance<CoinT>,
}

public struct AdminCap<phantom CoinT> has key, store {
    id: UID,
}


public(package) fun new<CoinT>(ctx: &mut TxContext): (BumpWinCoinVault<CoinT>, AdminCap<CoinT>) {
    let admin_cap = AdminCap<CoinT> {
        id: object::new(ctx),
    };
    let vault = BumpWinCoinVault<CoinT> {
        id: object::new(ctx),
        reserve: balance::zero(),
    };
    (vault, admin_cap)
}

public(package) fun deposit<CoinT>(vault: &mut BumpWinCoinVault<CoinT>, balance: Balance<CoinT>) {
    vault.reserve.join(balance);
}

public fun withdraw<CoinT>(
    vault: &mut BumpWinCoinVault<CoinT>,
    amount: u64,
    _: &mut AdminCap<CoinT>,
    ctx: &mut TxContext,
): Coin<CoinT> {
    coin::from_balance(vault.reserve.split(amount), ctx)
}
