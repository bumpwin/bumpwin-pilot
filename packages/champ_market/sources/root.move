module champ_market::root;

use champ_market::cpmm::{Self, Pool};
use std::type_name::{Self, TypeName};
use sui::coin::Coin;
use sui::table::{Self, Table};

public struct Root has key, store {
    id: UID,
    table: Table<TypeName, ID>,
}

fun init(ctx: &mut TxContext) {
    let root = Root {
        id: object::new(ctx),
        table: table::new(ctx),
    };

    transfer::public_share_object(root);
}

public fun create_pool<X, Y>(
    self: &mut Root,
    coin_x: Coin<X>,
    coin_y: Coin<Y>,
    ctx: &mut TxContext,
) {
    let key = type_name::get<Pool<X, Y>>();
    let id = cpmm::share_pool(coin_x, coin_y, ctx);
    self.table.add(key, id);
}
