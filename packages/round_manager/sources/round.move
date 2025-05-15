module round_manager::round;

use round_manager::meme_registry::{Self, MemeRegistry};
use sui::event;

public struct Round has key, store {
    id: UID,
    round: u64,
    meme_registry: MemeRegistry,
}

public struct NewRoundEvent has copy, drop {
    id: ID,
    round: u64,
}

public(package) fun new(round: u64, ctx: &mut TxContext): Round {
    let round = Round {
        id: object::new(ctx),
        round,
        meme_registry: meme_registry::new(ctx),
    };

    event::emit(NewRoundEvent {
        id: round.id.to_inner(),
        round: round.round,
    });

    round
}
