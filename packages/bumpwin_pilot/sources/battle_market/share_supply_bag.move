module bumpwin_pilot::share_supply_bag;

use bumpwin_pilot::outcome_share::{Self, OutcomeShare};
use std::debug;
use sui::bag::{Self, Bag};
use sui::balance::{Supply, Balance};

const ESupplyNotFound: u64 = 0;
const EAlreadyRegistered: u64 = 1;

public struct ShareSupplyBag has store {
    inner: Bag,
    total_supply: u128,
    num_outcomes: u64,
}

public fun new(ctx: &mut TxContext): ShareSupplyBag {
    ShareSupplyBag {
        inner: bag::new(ctx),
        total_supply: 0,
        num_outcomes: 0,
    }
}

public fun destroy<Outcome>(self: ShareSupplyBag): Supply<OutcomeShare<Outcome>> {
    let ShareSupplyBag { inner: mut inner, .. } = self;

    // TODO: Improve this

    let type_name = std::type_name::get<OutcomeShare<Outcome>>();
    let key = type_name.into_string();
    let supply = inner.remove<_, Supply<OutcomeShare<Outcome>>>(key);

    transfer::public_freeze_object(inner);

    supply
}

public fun register_outcome<Outcome>(self: &mut ShareSupplyBag) {
    let type_name = std::type_name::get<OutcomeShare<Outcome>>();
    let supply = outcome_share::new_supply<Outcome>();
    let key = type_name.into_string();
    assert!(
        !self.inner.contains_with_type<_, Supply<OutcomeShare<Outcome>>>(key),
        EAlreadyRegistered,
    );
    self.inner.add(key, supply);

    self.num_outcomes = self.num_outcomes + 1;
}

public fun num_outcomes(self: &ShareSupplyBag): u64 {
    self.num_outcomes
}

public fun contains_supply<Outcome>(self: &ShareSupplyBag): bool {
    let type_name = std::type_name::get<OutcomeShare<Outcome>>();
    let key = type_name.into_string();
    debug::print(&key);
    self.inner.contains(key)
}

public fun assert_contains_supply<Outcome>(self: &ShareSupplyBag) {
    assert!(self.contains_supply<Outcome>(), ESupplyNotFound);
}

public fun borrow_supply<Outcome>(self: &ShareSupplyBag): &Supply<OutcomeShare<Outcome>> {
    let type_name = std::type_name::get<Outcome>();
    let key = type_name.into_string();

    self.assert_contains_supply<Outcome>();
    self.inner.borrow(key)
}

public fun borrow_mut_supply<Outcome>(
    self: &mut ShareSupplyBag,
): &mut Supply<OutcomeShare<Outcome>> {
    let type_name = std::type_name::get<Outcome>();
    let key = type_name.into_string();

    self.assert_contains_supply<Outcome>();
    self.inner.borrow_mut(key)
}

public fun increase_supply<Outcome>(
    self: &mut ShareSupplyBag,
    amount: u64,
): Balance<OutcomeShare<Outcome>> {
    let supply = self.borrow_mut_supply<Outcome>();
    let balance = supply.increase_supply(amount);
    self.total_supply = self.total_supply + (amount as u128);
    balance
}

public fun decrease_supply<Outcome>(
    self: &mut ShareSupplyBag,
    balance: Balance<OutcomeShare<Outcome>>,
): u64 {
    let supply = self.borrow_mut_supply<Outcome>();
    let amount = supply.decrease_supply(balance);
    self.total_supply = self.total_supply - (amount as u128);
    amount
}

public fun supply_value<Outcome>(self: &ShareSupplyBag): u64 {
    let supply = self.borrow_supply<Outcome>();
    supply.supply_value()
}

public fun total_supply_value(self: &ShareSupplyBag): u128 {
    self.total_supply
}
