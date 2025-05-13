module round_manager::round_registry;


use sui::table::{Self, Table};

use round_manager::round::{Self, Round};


public struct RoundRegistry has key, store {
    id: UID,
    round_table: Table<u64, Round>,
    current_round: u64,
    max_num_rounds: u64,
}

public(package) fun new(ctx: &mut TxContext): RoundRegistry {
    RoundRegistry {
        id: object::new(ctx),
        round_table: table::new(ctx),
        current_round: 0,
        max_num_rounds: 10,
    }
}


public fun create_round(
    self: &mut RoundRegistry,
    ctx: &mut TxContext,
) {
    self.current_round = self.current_round;

    let round = round::new(self.current_round, ctx);
    self.round_table.add(self.current_round, round);
}
