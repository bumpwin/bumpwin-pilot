module round_manager::operations;

use round_manager::battle_round::BattleRound;
use round_manager::meme_registry::{Self, MemeRegistry};
use round_manager::round;
use sui::balance::Balance;
use sui::event;
use sui::sui::SUI;

public struct BalanceSheet<phantom CoinT> has key, store {
    id: UID,
    sui_reserve: Balance<SUI>,
    meme_reserve: Balance<CoinT>,
}

public struct ChampAMM<phantom CoinT> has key, store {
    id: UID,
    reserve_sui: Balance<SUI>,
    reserve_champ: Balance<CoinT>,
}

public struct ClaimeBox<CoinT> has key, store {
    id: UID,
    reserve: Balance<CoinT>,
    total_supply_claimed: u64,
}

public fun sunrise_settlement<CoinT>(
    balance_sheet: &mut BalanceSheet<CoinT>,
    battle_round: &mut BattleRound,
    ctx: &mut TxContext,
): (Balance<CoinT>, Balance<CoinT>) {
    let (balance1, balance2) = battle_round.withdraw_winner_balances<CoinT>();

    // TODO: Transfer balances to the winner
    // transfer to Champ AMM
    // transfer to Claimer

    (balance1, balance2)
}
