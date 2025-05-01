module qmsr_amm::qmsr_amm;

use sui::coin::{Coin};
use sui::balance::{Self, Balance};
use sui::sui::SUI;

public struct ShareCoin<phantom CoinT> has drop {}

public struct QMSR_AMM has key, store {
    id: UID,
    quote_reserve: Balance<SUI>,
    share_vault_list: vector<ID>,
}

public struct ShareVault<phantom CoinT> has key, store {
    id: UID,
    share_reserve: Balance<ShareCoin<CoinT>>,
}

public fun create(ctx: &mut TxContext): QMSR_AMM {
    QMSR_AMM {
        id: object::new(ctx),
        quote_reserve: balance::zero(),
        share_vault_list: vector::empty(),
    }
}

public fun create_share_vault<CoinT>(
    amm: &mut QMSR_AMM,
    ctx: &mut TxContext
) {
    let share_vault = ShareVault<CoinT> {
        id: object::new(ctx),
        share_reserve: balance::zero(),
    };

    amm.share_vault_list.push_back(share_vault.id.to_inner());
    transfer::public_share_object(share_vault);
}

/// Deposits quote (SUI) into the quote reserve
fun deposit_quote(amm: &mut QMSR_AMM, balance_in: Balance<SUI>): u64 {
    amm.quote_reserve.join(balance_in)
}

/// Withdraws quote (SUI) from the quote reserve
fun withdraw_quote(amm: &mut QMSR_AMM, amount_out: u64): Balance<SUI> {
    amm.quote_reserve.split(amount_out)
}

/// Deposits share tokens into the vector
fun deposit_share<CoinT>(vault: &mut ShareVault<CoinT>, balance_in: Balance<ShareCoin<CoinT>>): u64 {
    vault.share_reserve.join(balance_in)
}

/// Withdraws share tokens from the vector
fun withdraw_share<CoinT>(vault: &mut ShareVault<CoinT>, amount: u64): Balance<ShareCoin<CoinT>> {
    vault.share_reserve.split(amount)
}

/// Calculates the amount of shares to receive when buying with quote
/// Formula: (shares[i]^2 + 2*amount_in)^(1/2) - shares[i]
public fun swap_rate_quote_to_share<CoinT>(vault: &mut ShareVault<CoinT>, quote_in: u64): u64 {
    let shares_ith = vault.share_reserve.value();
    (shares_ith * shares_ith + 2 * quote_in).sqrt() - shares_ith
}

/// Calculates the amount of quote to receive when selling shares
/// Formula: shares[i]*amount_in - (1/2)*amount_in^2
public fun swap_rate_share_to_quote<CoinT>(vault: &mut ShareVault<CoinT>, share_in: u64): u64 {
    let shares_ith = vault.share_reserve.value();
    shares_ith * share_in - (share_in * share_in) / 2
}

/// Swaps quote (SUI) for share tokens of the outcome
public fun swap_quote_to_share<CoinT>(
    amm: &mut QMSR_AMM,
    vault: &mut ShareVault<CoinT>,
    coin_in: Coin<SUI>,
    ctx: &mut TxContext
): Coin<ShareCoin<CoinT>> {
    let amount_out = vault.swap_rate_quote_to_share(coin_in.value());
    amm.deposit_quote(coin_in.into_balance());
    vault.withdraw_share(amount_out).into_coin(ctx)
}

/// Swaps share tokens of the outcome for quote (SUI)
public fun swap_share_to_quote<CoinT>(
    amm: &mut QMSR_AMM,
    vault: &mut ShareVault<CoinT>,
    coin_in: Coin<ShareCoin<CoinT>>,
    ctx: &mut TxContext
): Coin<SUI> {
    let amount_out = vault.swap_rate_share_to_quote(coin_in.value());
    vault.deposit_share(coin_in.into_balance());
    amm.withdraw_quote(amount_out).into_coin(ctx)
}
