module round_manager::battle_market;

use round_manager::outcome_share_bag::{Self, SupplyBag};
use round_manager::outcome_share_coin::OutcomeShare;
use round_manager::round_number::RoundNumber;
use round_manager::wsui::WSUI;
use sui::balance::{Self, Balance, Supply};

public struct BattleMarket has key, store {
    id: UID,
    round_number: RoundNumber,
    reserve_wsui: Balance<WSUI>,
    supply_bag: SupplyBag,
}

public fun new(round_number: RoundNumber, ctx: &mut TxContext): BattleMarket {
    BattleMarket {
        id: object::new(ctx),
        round_number,
        reserve_wsui: balance::zero(),
        supply_bag: outcome_share_bag::new(ctx),
    }
}

public fun destroy<Outcome>(self: BattleMarket): (Balance<WSUI>, Supply<OutcomeShare<Outcome>>) {
    let BattleMarket {
        id,
        round_number: _,
        reserve_wsui,
        supply_bag,
    } = self;
    id.delete();

    let winner_supply = supply_bag.destroy<Outcome>();

    (reserve_wsui, winner_supply)
}
