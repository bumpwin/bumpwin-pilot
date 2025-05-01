
module battle_market::meme_treasury;

use sui::balance::{Self, Balance};
use sui::coin::Coin;

public struct MemeTreasury<phantom CoinT> has key, store {
    id: UID,
    reserve: Balance<CoinT>,
}

public fun create<CoinT>(ctx: &mut TxContext) {
    let treasury = MemeTreasury<CoinT> {
        id: object::new(ctx),
        reserve: balance::zero(),
    };

    transfer::public_share_object(treasury);
}

public fun deposit<CoinT>(self: &mut MemeTreasury<CoinT>, coin: Coin<CoinT>) {
    self.reserve.join(coin.into_balance());
}



