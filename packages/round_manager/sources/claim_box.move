module round_manager::claim_box;

use round_manager::outcome_share_coin::OutcomeShare;
use std::uq64_64::{Self, UQ64_64};
use sui::balance::{Balance, Supply};
use sui::coin::{Self, Coin};

public struct ClaimBox<phantom CoinT> has key, store {
    id: UID,
    reserve_to_redeem: Balance<CoinT>,
    total_supply_claimed: Supply<OutcomeShare<CoinT>>,
    redeem_amount_per_claim: UQ64_64,
}

public fun new<CoinT>(
    reserve_to_redeem: Balance<CoinT>,
    total_supply_claimed: Supply<OutcomeShare<CoinT>>,
    ctx: &mut TxContext,
): ClaimBox<CoinT> {
    // let exchange_rate = uq64_64::from_quotient(reserve.value() as u128, total_supply_claimed.supply().value() as u128);
    let redeem_amount_per_claim = uq64_64::from_quotient(
        reserve_to_redeem.value() as u128,
        total_supply_claimed.supply_value() as u128,
    );

    ClaimBox<CoinT> {
        id: object::new(ctx),
        reserve_to_redeem,
        total_supply_claimed,
        redeem_amount_per_claim,
    }
}

public fun claim<CoinT>(
    self: &mut ClaimBox<CoinT>,
    claim_coin: Coin<OutcomeShare<CoinT>>,
    ctx: &mut TxContext,
): Coin<CoinT> {
    let amount_in = claim_coin.value();
    self.total_supply_claimed.decrease_supply(claim_coin.into_balance());

    let amount_out = self.redeem_amount_per_claim.mul(uq64_64::from_int(amount_in)).to_int();
    coin::from_balance(self.reserve_to_redeem.split(amount_out), ctx)
}
