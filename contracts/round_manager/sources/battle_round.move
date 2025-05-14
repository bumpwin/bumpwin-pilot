module round_manager::battle_round;

use round_manager::meme_registry::{Self, MemeRegistry};
use round_manager::round;
use sui::balance::Balance;
use sui::event;

public struct BattleRound has key, store {
    id: UID,
    round: u64,
    meme_registry: MemeRegistry,
}

public struct NewRoundEvent has copy, drop {
    id: ID,
    round: u64,
}

public(package) fun new(round: u64, ctx: &mut TxContext): BattleRound {
    let battle_round = BattleRound {
        id: object::new(ctx),
        round,
        meme_registry: meme_registry::new(ctx),
    };

    event::emit(NewRoundEvent {
        id: battle_round.id.to_inner(),
        round: battle_round.round,
    });

    battle_round
}

public fun withdraw_winner_balances<CoinT>(
    self: &mut BattleRound,
): (Balance<CoinT>, Balance<CoinT>) {
    self.meme_registry.borrow_mut_vault<CoinT>().withdraw_two_half_supply()
}
