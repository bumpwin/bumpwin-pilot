module round_manager::account;

use round_manager::position::{Self, Position};
use round_manager::round_number::{Self, RoundNumber};
use round_manager::wsui::WSUI;
use sui::balance::{Self, Balance};
use sui::table::{Self, Table};

public struct Account has key, store {
    id: UID,
    owner: address,
    round_positions: Table<RoundNumber, Position>,
    reserver_wsui: Balance<WSUI>,
}

public fun new(ctx: &mut TxContext): Account {
    let account = Account {
        id: object::new(ctx),
        owner: ctx.sender(),
        round_positions: table::new(ctx),
        reserver_wsui: balance::zero(),
    };
    account
}

public fun deposit_wsui(self: &mut Account, balance: Balance<WSUI>): u64 {
    self.reserver_wsui.join(balance)
}

public fun withdraw_wsui(self: &mut Account, amount: u64): Balance<WSUI> {
    self.reserver_wsui.split(amount)
}

public fun create_position(self: &mut Account, round_number: RoundNumber, ctx: &mut TxContext) {
    let position = position::new(self.owner, round_number, ctx);
    self.round_positions.add(round_number, position);
}
