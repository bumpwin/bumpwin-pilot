module round_manager::meme_registry;

use sui::object_bag::{Self, ObjectBag};
use sui::coin::{TreasuryCap, CoinMetadata};

use round_manager::meme_vault;

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
