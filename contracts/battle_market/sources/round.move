module battle_market::round;

use std::string;
use std::ascii;

use sui::clock::Clock;
use sui::table::{Self, Table};
use sui::url;

use battle_market::root;

public struct Round has key, store {
    id: UID,
    round_number: u64,
    start_timestamp_ms: u64,
    end_timestamp_ms: u64,
    memes_table: Table<ID, CoinMetadata>,
}

public struct CoinMetadata has key, store {
    id: UID,
    decimals: u8,
    name: string::String,
    symbol: ascii::String,
    description: string::String,
    icon_url: Option<url::Url>,
}

public fun new(
    root: &mut root::Root,
    clock: &Clock,
    ctx: &mut TxContext,
) {
    let round_number = root.current_round_number() + 1;
    let round = Round {
        id: object::new(ctx),
        round_number,
        start_timestamp_ms: root.nth_round_start_timestamp_ms(round_number),
        end_timestamp_ms: root.nth_round_end_timestamp_ms(round_number),
        memes_table: table::new(ctx),
    };

    root.start_new_round(round.id.uid_to_inner(), clock);
    transfer::public_share_object(round);
}

public fun register_meme(
    round: &mut Round,
    name: string::String,
    symbol: ascii::String,
    description:  string::String,
    icon_url: url::Url,
    ctx: &mut TxContext,
) {
    let metadata = CoinMetadata {
        id: object::new(ctx),
        decimals: 6,
        name,
        symbol,
        description,
        icon_url: option::some(icon_url),
    };

    round.memes_table.add(metadata.id.uid_to_inner(), metadata);
}

#[test_only]
public fun init_for_testing(ctx: &mut TxContext): Round {
    Round {
        id: object::new(ctx),
        round_number: 1,
        start_timestamp_ms: 1748736000000,
        end_timestamp_ms: 1748736000000 + 25 * 60 * 60 * 1000,
        memes_table: table::new(ctx),
    }
}
