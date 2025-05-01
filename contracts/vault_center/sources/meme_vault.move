module vault_center::meme_vault;

use sui::balance::{Self, Balance};
use sui::coin::Coin;

use vault_center::root::Root;

public struct MemeVault<phantom CoinT> has key, store {
    id: UID,
    reserve: Balance<CoinT>,
}

public fun create<CoinT>(
    root: &mut Root,
    ctx: &mut TxContext) {
    let vault = MemeVault<CoinT> {
        id: object::new(ctx),
        reserve: balance::zero(),
    };

    root.add_vault_id(vault.id.to_inner());
    transfer::public_share_object(vault);
}

public fun deposit<CoinT>(self: &mut MemeVault<CoinT>, coin: Coin<CoinT>) {
    self.reserve.join(coin.into_balance());
}



