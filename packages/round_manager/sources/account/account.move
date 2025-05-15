module round_manager::account;

use round_manager::round_number::{Self, RoundNumber};
use std::ascii::String;
use sui::bag::{Self, Bag};
use sui::table::{Self, Table};
use sui::sui::SUI;

public struct PositionBag has store {
    bag: Bag,
}

public struct Account has store {
    owner: address,
    positions: Table<RoundNumber, PositionBag>,
}

public fun new(ctx: &mut TxContext): Account {
    Account {
        owner: ctx.sender(),
        positions: table::new(ctx),
    }
}

public fun create_position(self: &mut Account, round_number: RoundNumber, ctx: &mut TxContext) {
    let position_bag = PositionBag {
        bag: bag::new(ctx),
    };
    self.positions.add(round_number, position_bag);
}

public fun borrow_position_bag(self: &Account, round_number: RoundNumber): &PositionBag {
    self.positions.borrow(round_number)
}

public fun borrow_mut_position_bag(
    self: &mut Account,
    round_number: RoundNumber,
): &mut PositionBag {
    self.positions.borrow_mut(round_number)
}
