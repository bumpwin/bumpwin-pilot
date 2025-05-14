module round_manager::meme_registry;

use round_manager::meme_vault;
use sui::coin::{TreasuryCap, CoinMetadata};
use sui::object_bag::{Self, ObjectBag};

public struct MemeRegistry has key, store {
    id: UID,
    table: ObjectBag,
    num_memes: u64,
    round: u64,
}

public(package) fun new(ctx: &mut TxContext): MemeRegistry {
    MemeRegistry {
        id: object::new(ctx),
        table: object_bag::new(ctx),
        num_memes: 0,
        round: 0,
    }
}

public fun register_meme<CoinT>(
    registry: &mut MemeRegistry,
    treasury: TreasuryCap<CoinT>,
    metadata: CoinMetadata<CoinT>,
    ctx: &mut TxContext,
) {
    let coin_type_name = std::type_name::get<CoinT>();
    let vault = meme_vault::new<CoinT>(treasury, metadata, ctx);
    registry.table.add(coin_type_name, vault);
    registry.num_memes = registry.num_memes + 1;
}

public fun borrow_mut_vault<CoinT>(registry: &mut MemeRegistry): &mut meme_vault::MemeVault<CoinT> {
    let coin_type_name = std::type_name::get<CoinT>();
    registry.table.borrow_mut(coin_type_name)
}

#[allow(unused_type_parameter)]
public fun withdraw_funds<CoinT>(
    _registry: &mut MemeRegistry,
    _amount: u64,
    _ctx: &mut TxContext,
) {}
