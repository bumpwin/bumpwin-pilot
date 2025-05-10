module msr_amm::outcome_vault;

use sui::balance::{Self, Balance, Supply};
use sui::coin::{Self, Coin};
use sui::object_bag::{Self, ObjectBag};


/// Token representing ownership of a specific outcome
public struct OutcomeShare<phantom CoinT> has drop {}

/// Vault for outcome tokens of a specific outcome
public struct OutcomeVault has key, store {
    id: UID,
    supply_bag: ObjectBag,
    num_of_outcomes: u64,
    total_shares: u64,
    total_share_squares: u64,
}

public struct OutcomeShareSupply<phantom CoinT> has key, store {
    id: UID,
    supply: Supply<OutcomeShare<CoinT>>
}

fun new_supply<CoinT>(ctx: &mut TxContext): OutcomeShareSupply<CoinT> {
    OutcomeShareSupply {
        id: object::new(ctx),
        supply: balance::create_supply(OutcomeShare<CoinT> {}),
    }
}

fun new(ctx: &mut TxContext): OutcomeVault {
    OutcomeVault {
        id: object::new(ctx),
        supply_bag: object_bag::new(ctx),
        num_of_outcomes: 0,
        total_shares: 0,
        total_share_squares: 0,
    }
}

fun register_coin<CoinT>(self: &mut OutcomeVault, ctx: &mut TxContext) {
    let type_name = std::type_name::get<CoinT>();
    self.supply_bag.add(type_name, new_supply<CoinT>(ctx));
    self.num_of_outcomes = self.num_of_outcomes + 1;
}


fun mint_shares<CoinT>(self: &mut OutcomeVault, amount: u64): Balance<OutcomeShare<CoinT>> {
    let type_name = std::type_name::get<CoinT>();
    let share_supply = self.supply_bag.borrow_mut<_, OutcomeShareSupply<CoinT>>(type_name);
    let balance = share_supply.supply.increase_supply(amount);

    self.total_shares = self.total_shares + amount;
    self.total_share_squares = self.total_share_squares + amount * amount;
    balance
}

fun burn_shares<CoinT>(self: &mut OutcomeVault, balance: Balance<OutcomeShare<CoinT>>): u64 {
    let type_name = std::type_name::get<CoinT>();
    let share_supply = self.supply_bag.borrow_mut<_, OutcomeShareSupply<CoinT>>(type_name);
    let amount = balance.value();

    self.total_shares = self.total_shares - amount;
    self.total_share_squares = self.total_share_squares - amount * amount;
    share_supply.supply.decrease_supply(balance)
}

public fun share_supply_value<CoinT>(self: &OutcomeVault): u64 {
    let type_name = std::type_name::get<CoinT>();
    let share_supply = self.supply_bag.borrow<_, OutcomeShareSupply<CoinT>>(type_name);
    share_supply.supply.supply_value()
}






