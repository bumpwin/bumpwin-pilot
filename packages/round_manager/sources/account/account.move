module round_manager::account;

use round_manager::position::{Self, Position};
use round_manager::round_number::RoundNumber;
use round_manager::wsui::WSUI;
use sui::balance::{Self, Balance};
use sui::table::{Self, Table};

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

// TODO: Implement expiration data
public fun commit_txs(self: &mut Account, txs: vector<DarkBatchTx>) {
    self.dark_batch_tx_board.add(txs);
}