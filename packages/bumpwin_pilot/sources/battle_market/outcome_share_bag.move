module bumpwin_pilot::outcome_share_bag;

use bumpwin_pilot::outcome_share_coin::{Self, OutcomeShare};
use sui::bag::{Self, Bag};
use sui::balance::{Supply, Balance};

const ESupplyNotFound: u64 = 0;
const EAlreadyRegistered: u64 = 1;

public struct SupplyBag has store {
    inner: Bag,
    total_supply: u64,
}

public fun new(ctx: &mut TxContext): SupplyBag {
    SupplyBag {
        inner: bag::new(ctx),
        total_supply: 0,
    }
}

public fun destroy<Outcome>(self: SupplyBag): Supply<OutcomeShare<Outcome>> {
    let SupplyBag { inner: mut inner, .. } = self;

    // TODO: Improve this

    let type_name = std::type_name::get<OutcomeShare<Outcome>>();
    let key = type_name.into_string();
    let supply = inner.remove<_, Supply<OutcomeShare<Outcome>>>(key);

    transfer::public_freeze_object(inner);

    supply
}

public fun register_outcome<Outcome>(self: &mut SupplyBag) {
    let type_name = std::type_name::get<OutcomeShare<Outcome>>();
    let supply = outcome_share_coin::new_supply<Outcome>();
    let key = type_name.into_string();
    assert!(
        !self.inner.contains_with_type<_, Supply<OutcomeShare<Outcome>>>(key),
        EAlreadyRegistered,
    );
    self.inner.add(key, supply);
}

public fun contains_supply<Outcome>(self: &SupplyBag): bool {
    let type_name = std::type_name::get<OutcomeShare<Outcome>>();
    let key = type_name.into_string();
    self.inner.contains(key)
}

public fun assert_contains_supply<Outcome>(self: &SupplyBag) {
    assert!(self.contains_supply<OutcomeShare<Outcome>>(), ESupplyNotFound);
}

public fun borrow_supply<Outcome>(self: &SupplyBag): &Supply<OutcomeShare<Outcome>> {
    let type_name = std::type_name::get<Outcome>();
    let key = type_name.into_string();

    self.assert_contains_supply<Outcome>();
    self.inner.borrow(key)
}

public fun borrow_mut_supply<Outcome>(self: &mut SupplyBag): &mut Supply<OutcomeShare<Outcome>> {
    let type_name = std::type_name::get<Outcome>();
    let key = type_name.into_string();

    self.assert_contains_supply<Outcome>();
    self.inner.borrow_mut(key)
}

public fun increase_supply<Outcome>(
    self: &mut SupplyBag,
    amount: u64,
): Balance<OutcomeShare<Outcome>> {
    let supply = self.borrow_mut_supply<Outcome>();
    let balance = supply.increase_supply(amount);
    self.total_supply = self.total_supply + amount;
    balance
}

public fun decrease_supply<Outcome>(
    self: &mut SupplyBag,
    balance: Balance<OutcomeShare<Outcome>>,
): u64 {
    let supply = self.borrow_mut_supply<Outcome>();
    let amount = supply.decrease_supply(balance);
    self.total_supply = self.total_supply - amount;
    amount
}

public fun supply_value<Outcome>(self: &SupplyBag): u64 {
    let supply = self.borrow_supply<Outcome>();
    supply.supply_value()
}

public fun total_supply_value(self: &SupplyBag): u64 {
    self.total_supply
}
