module round_manager::battle_market;

use round_manager::outcome_share_coin::{Self, OutcomeShare};
use round_manager::wsui::WSUI;
use sui::balance::{Self, Balance, Supply};

public struct BattleMarket has key, store {
    id: UID,
    reserve_wsui: Balance<WSUI>,
}

public fun destroy<CoinT>(self: BattleMarket): (Balance<WSUI>, Supply<OutcomeShare<CoinT>>) {
    let BattleMarket {
        id,
        reserve_wsui,
    } = self;
    id.delete();

    let share_supply = outcome_share_coin::new_supply<CoinT>();

    (reserve_wsui, share_supply)
}
