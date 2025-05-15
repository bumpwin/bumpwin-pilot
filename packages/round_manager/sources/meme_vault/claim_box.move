module round_manager::claim_box;

use round_manager::outcome_share_coin::OutcomeShare;
use std::uq64_64::{Self, UQ64_64};
use sui::balance::{Balance, Supply};
use sui::coin::{Self, Coin};

public struct ClaimBox<phantom Outcome> has key, store {
    id: UID,
    reserve_to_redeem: Balance<Outcome>,
    total_supply_claimed: Supply<OutcomeShare<Outcome>>,
    redeem_amount_per_claim: UQ64_64,
}

public fun new<Outcome>(
    reserve_to_redeem: Balance<Outcome>,
    total_supply_claimed: Supply<OutcomeShare<Outcome>>,
    ctx: &mut TxContext,
): ClaimBox<Outcome> {
    let redeem_amount_per_claim = uq64_64::from_quotient(
        reserve_to_redeem.value() as u128,
        total_supply_claimed.supply_value() as u128,
    );

    ClaimBox<Outcome> {
        id: object::new(ctx),
        reserve_to_redeem,
        total_supply_claimed,
        redeem_amount_per_claim,
    }
}

public fun claim<Outcome>(
    self: &mut ClaimBox<Outcome>,
    claim_coin: Coin<OutcomeShare<Outcome>>,
    ctx: &mut TxContext,
): Coin<Outcome> {
    let amount_in = claim_coin.value();
    self.total_supply_claimed.decrease_supply(claim_coin.into_balance());

    let amount_out = self.redeem_amount_per_claim.mul(uq64_64::from_int(amount_in)).to_int();
    coin::from_balance(self.reserve_to_redeem.split(amount_out), ctx)
}
