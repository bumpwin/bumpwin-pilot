module battle_market::market_vault;

use battle_market::market_math;
use safemath::u128_safe;
use sui::balance::{Self, Balance, Supply};
use sui::coin::Coin;
use sui::object_bag::{Self, ObjectBag};
use sui::sui::SUI;

/// Token representing ownership of a specific market outcome
public struct MarketToken<phantom CoinT> has drop {}

/// Vault for market tokens of a specific outcome
public struct MarketVault has key, store {
    id: UID,
    numeraire_reserve: Balance<SUI>,
    supply_bag: ObjectBag,
    num_outcomes: u64,
    total_shares: u128,
}

public struct TokenSupply<phantom CoinT> has key, store {
    id: UID,
    supply: Supply<MarketToken<CoinT>>,
}

public fun num_outcomes(self: &MarketVault): u64 {
    self.num_outcomes
}

fun new_supply<CoinT>(ctx: &mut TxContext): TokenSupply<CoinT> {
    TokenSupply {
        id: object::new(ctx),
        supply: balance::create_supply(MarketToken<CoinT> {}),
    }
}

public fun new(ctx: &mut TxContext): MarketVault {
    MarketVault {
        id: object::new(ctx),
        numeraire_reserve: balance::zero(),
        supply_bag: object_bag::new(ctx),
        num_outcomes: 0,
        total_shares: 0,
    }
}

public fun register_coin<CoinT>(self: &mut MarketVault, ctx: &mut TxContext) {
    let type_name = std::type_name::get<CoinT>();
    self.supply_bag.add(type_name, new_supply<CoinT>(ctx));
    self.num_outcomes = self.num_outcomes + 1;
}

fun deposit_numeraire(self: &mut MarketVault, balance: Balance<SUI>): u64 {
    self.numeraire_reserve.join(balance)
}

fun withdraw_numeraire(self: &mut MarketVault, amount: u64): Balance<SUI> {
    self.numeraire_reserve.split(amount)
}

fun mint_shares<CoinT>(self: &mut MarketVault, amount: u64): Balance<MarketToken<CoinT>> {
    let type_name = std::type_name::get<CoinT>();
    let share_supply = self.supply_bag.borrow_mut<_, TokenSupply<CoinT>>(type_name);
    let balance = share_supply.supply.increase_supply(amount);

    self.total_shares = u128_safe::add(self.total_shares, amount as u128);
    balance
}

fun burn_shares<CoinT>(self: &mut MarketVault, balance: Balance<MarketToken<CoinT>>): u64 {
    let type_name = std::type_name::get<CoinT>();
    let share_supply = self.supply_bag.borrow_mut<_, TokenSupply<CoinT>>(type_name);
    let amount = balance.value();

    self.total_shares = u128_safe::sub(self.total_shares, amount as u128);
    share_supply.supply.decrease_supply(balance)
}

public fun share_supply_value<CoinT>(self: &MarketVault): u64 {
    let type_name = std::type_name::get<CoinT>();
    let share_supply = self.supply_bag.borrow<_, TokenSupply<CoinT>>(type_name);
    share_supply.supply.supply_value()
}

public fun total_share_supply_value(self: &MarketVault): u128 {
    self.total_shares
}

public fun buy_shares<CoinT>(
    self: &mut MarketVault,
    coin_in: Coin<SUI>,
    ctx: &mut TxContext,
): Coin<MarketToken<CoinT>> {
    let amount_out = market_math::swap_rate_z_to_xi(
        self.share_supply_value<CoinT>(),
        self.total_share_supply_value(),
        coin_in.value(),
        self.num_outcomes,
    );

    self.deposit_numeraire(coin_in.into_balance());

    let coin_out = self.mint_shares<CoinT>(amount_out).into_coin(ctx);
    coin_out
}

public fun sell_shares<CoinT>(
    self: &mut MarketVault,
    coin_in: Coin<MarketToken<CoinT>>,
    ctx: &mut TxContext,
): Coin<SUI> {
    let amount_out = market_math::swap_rate_xi_to_z(
        self.share_supply_value<CoinT>(),
        self.total_share_supply_value(),
        coin_in.value(),
        self.num_outcomes,
    );

    self.burn_shares<CoinT>(coin_in.into_balance());
    self.withdraw_numeraire(amount_out).into_coin(ctx)
}

#[test_only]
public(package) fun mint_shares_for_test<CoinT>(
    self: &mut MarketVault,
    amount: u64,
): Balance<MarketToken<CoinT>> {
    mint_shares<CoinT>(self, amount)
}

#[test_only]
public(package) fun burn_shares_for_test<CoinT>(
    self: &mut MarketVault,
    balance: Balance<MarketToken<CoinT>>,
): u64 {
    burn_shares<CoinT>(self, balance)
}
