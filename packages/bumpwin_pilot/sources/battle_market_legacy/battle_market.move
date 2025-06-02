module bumpwin_pilot::battle_market;

use bumpwin_pilot::battle_market_math;
use bumpwin_pilot::outcome_share::OutcomeShare;
use bumpwin_pilot::round_number::RoundNumber;
use bumpwin_pilot::share_supply_bag::{Self, ShareSupplyBag};
use bumpwin_pilot::wsui::WSUI;
use std::debug::{Self, print};
use std::string::{Self, utf8};
use std::uq64_64::UQ64_64;
use sui::balance::{Self, Balance, Supply};
use sui::coin::Coin;

const EInvalidAmountOut: u64 = 1;

public struct BattleMarket has key, store {
    id: UID,
    round_number: RoundNumber,
    reserve_wsui: Balance<WSUI>,
    supply_bag: ShareSupplyBag,
}

public fun supply_bag(self: &BattleMarket): &ShareSupplyBag {
    &self.supply_bag
}

public fun new(round_number: RoundNumber, ctx: &mut TxContext): BattleMarket {
    BattleMarket {
        id: object::new(ctx),
        round_number,
        reserve_wsui: balance::zero(),
        supply_bag: share_supply_bag::new(ctx),
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

public fun register_meme<Outcome>(self: &mut BattleMarket) {
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

public fun supply_value<Outcome>(self: &BattleMarket): u64 {
    self.supply_bag.supply_value<Outcome>()
}

public fun price<Outcome>(self: &BattleMarket): UQ64_64 {
    let sum_q = self.supply_bag.supply_value<Outcome>();
    let num_outcomes = self.supply_bag.num_outcomes();
    battle_market_math::price(sum_q, num_outcomes)
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

    print(&utf8(b"amount_in"));
    print(&coin_in.value());

    print(&utf8(b"amount_out"));
    print(&amount_out);

    assert!(amount_out > 0, EInvalidAmountOut);

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
