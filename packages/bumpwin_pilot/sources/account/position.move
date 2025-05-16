module bumpwin_pilot::position;

use bumpwin_pilot::round_number::RoundNumber;
use std::type_name;
use sui::bag::{Self, Bag};
use sui::balance::{Self, Balance};


public struct Position has store {
    owner: address,
    round_number: RoundNumber,
    bag: Bag, // type_name::get<CoinT>() -> Balance<CoinT>
}

public fun new(owner: address, round_number: RoundNumber, ctx: &mut TxContext): Position {
    Position {
        owner,
        round_number,
        bag: bag::new(ctx),
    }
}

public fun borrow_mut_balance<CoinT: store>(self: &mut Position): &mut Balance<CoinT> {
    let type_name = type_name::get<CoinT>();
    let key = type_name.into_string();

    if (!self.bag.contains_with_type<_, CoinT>(key)) {
        self.bag.add(key, balance::zero<CoinT>());
    };

    self.bag.borrow_mut(type_name.into_string())
}

public fun deposit_position<CoinT: store>(self: &mut Position, balance: Balance<CoinT>): u64 {
    self.borrow_mut_balance<CoinT>().join(balance)
}

public fun withdraw_position<CoinT: store>(self: &mut Position, amount: u64): Balance<CoinT> {
    self.borrow_mut_balance<CoinT>().split(amount)
}


// TODO: destroy position