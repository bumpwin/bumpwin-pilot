module bumpwin_pilot::battle_market;

use bumpwin_pilot::battle_market_math;
use bumpwin_pilot::outcome_share_bag::{Self, SupplyBag};
use bumpwin_pilot::outcome_share_coin::OutcomeShare;
use bumpwin_pilot::round_number::RoundNumber;
use bumpwin_pilot::wsui::WSUI;
use sui::balance::{Self, Balance, Supply};
use sui::coin::Coin;

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

public fun register_meme<Outcome>(self: &mut BattleMarket, ctx: &mut TxContext) {
    self.supply_bag.register_outcome<Outcome>();
}

fun deposit_numeraire(self: &mut BattleMarket, balance: Balance<WSUI>): u64 {
    self.reserve_wsui.join(balance)
}

fun withdraw_numeraire(self: &mut BattleMarket, amount: u64): Balance<WSUI> {
    self.reserve_wsui.split(amount)
}

fun mint_shares<Outcome>(self: &mut BattleMarket, amount: u64): Balance<OutcomeShare<Outcome>> {
    self.supply_bag.increase_supply<Outcome>(amount)
}

fun burn_shares<Outcome>(self: &mut BattleMarket, balance: Balance<OutcomeShare<Outcome>>): u64 {
    self.supply_bag.decrease_supply<Outcome>(balance)
}

public fun buy_shares<Outcome>(
    self: &mut BattleMarket,
    coin_in: Coin<WSUI>,
    ctx: &mut TxContext,
): Coin<OutcomeShare<Outcome>> {
    let amount_out = battle_market_math::swap_rate_z_to_xi(
        self.supply_bag.supply_value<Outcome>(),
        self.supply_bag.total_supply_value(),
        coin_in.value(),
        self.supply_bag.num_outcomes(),
    );

    self.deposit_numeraire(coin_in.into_balance());

    let coin_out = self.mint_shares<Outcome>(amount_out).into_coin(ctx);
    coin_out
}

public fun sell_shares<Outcome>(
    self: &mut BattleMarket,
    coin_in: Coin<OutcomeShare<Outcome>>,
    ctx: &mut TxContext,
): Coin<WSUI> {
    let amount_out = battle_market_math::swap_rate_xi_to_z(
        self.supply_bag.supply_value<Outcome>(),
        self.supply_bag.total_supply_value(),
        coin_in.value(),
        self.supply_bag.num_outcomes(),
    );

    self.burn_shares<Outcome>(coin_in.into_balance());
    self.withdraw_numeraire(amount_out).into_coin(ctx)
}
