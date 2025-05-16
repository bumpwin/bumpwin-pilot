module round_manager::account;

use round_manager::position::{Self, Position};
use round_manager::round_number::RoundNumber;
use round_manager::wsui::WSUI;
use sui::balance::{Self, Balance};
use sui::table::{Self, Table};
use round_manager::sealed_tx_board::SealedTxBoard;

const EInvalidNullifier: u64 = 0;
const ESealedTxNotFound: u64 = 1;

public struct Account has key, store {
    id: UID,
    owner: address,
    round_positions: Table<RoundNumber, Position>,
    reserve_wsui: Balance<WSUI>,
}

public fun new(ctx: &mut TxContext): Account {
    let account = Account {
        id: object::new(ctx),
        owner: ctx.sender(),
        round_positions: table::new(ctx),
        reserve_wsui: balance::zero(),
    };
    account
}

public fun deposit_wsui(self: &mut Account, balance: Balance<WSUI>): u64 {
    self.reserve_wsui.join(balance)
}

public fun withdraw_wsui(self: &mut Account, amount: u64): Balance<WSUI> {
    self.reserve_wsui.split(amount)
}

public fun create_position(self: &mut Account, round_number: RoundNumber, ctx: &mut TxContext) {
    let position = position::new(self.owner, round_number, ctx);
    self.round_positions.add(round_number, position);
}


public fun switch_position(self: &mut Account, round_number: RoundNumber) {
}


public fun switch_position_with_sealed_tx(
    self: &mut Account,
    amount: u64,
    round_number: RoundNumber,
    nullifier: u256,
    sealed_tx_board: &SealedTxBoard,
    ctx: &TxContext,
) {
    let expected_nullifier = sealed_tx_board.get_nullifier(ctx.sender());
    assert!(expected_nullifier.is_some(), ESealedTxNotFound);
    assert!(expected_nullifier.borrow() == nullifier, EInvalidNullifier);


    self.switch_position(round_number);
}
