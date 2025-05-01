module vault_center::meme_vault;

use sui::balance::{Self, Balance};
use sui::coin::Coin;

public struct MemeVault<phantom CoinT> has key, store {
    id: UID,
    reserve: Balance<CoinT>,
}

fun new<CoinT>(ctx: &mut TxContext): MemeVault<CoinT> {
    MemeVault<CoinT> {
        id: object::new(ctx),
        reserve: balance::zero(),
    }
}

fun deposit<CoinT>(self: &mut MemeVault<CoinT>, coin: Coin<CoinT>) {
    self.reserve.join(coin.into_balance());
}


public fun create<CoinT>(
    coin: Coin<CoinT>,
    ctx: &mut TxContext
) {
    let mut vault = new<CoinT>(ctx);
    vault.deposit(coin);
    transfer::public_share_object(vault);
}


