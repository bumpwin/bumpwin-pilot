module round_manager::outcome_share_coin;

use sui::balance::{Self, Supply};

public struct OutcomeShare<phantom Outcome> has drop {}

public fun new_supply<Outcome>(): Supply<OutcomeShare<Outcome>> {
    balance::create_supply(OutcomeShare<Outcome> {})
}
