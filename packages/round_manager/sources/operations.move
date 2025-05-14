module round_manager::operations;

use round_manager::battle_round::BattleRound;
use sui::balance::Balance;
use sui::sui::SUI;

#[allow(unused_field)]
public struct BalanceSheet<phantom CoinT> has key, store {
    id: UID,
    sui_reserve: Balance<SUI>,
    meme_reserve: Balance<CoinT>,
}

#[allow(unused_field)]
public struct ChampAMM<phantom CoinT> has key, store {
    id: UID,
    reserve_sui: Balance<SUI>,
    reserve_champ: Balance<CoinT>,
}

#[allow(missing_phantom, unused_field)]
public struct ClaimeBox<CoinT> has key, store {
    id: UID,
    reserve: Balance<CoinT>,
    total_supply_claimed: u64,
}

public fun sunrise_settlement<CoinT>(
    _balance_sheet: &mut BalanceSheet<CoinT>,
    battle_round: &mut BattleRound,
    _ctx: &mut TxContext,
): (Balance<CoinT>, Balance<CoinT>) {
    let (balance1, balance2) = battle_round.withdraw_winner_balances<CoinT>();

    // TODO: Transfer balances to the winner
    // transfer to Champ AMM
    // transfer to Claimer

    (balance1, balance2)
}
