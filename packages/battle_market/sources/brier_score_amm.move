/// Brier Score Dual SCPM (Shared Cost Prediction Market)
/// Revolutionary prediction market where all coin prices sum to exactly 100%
/// Mathematical foundation for BUMP.WIN battle royale mechanics
module battle_market::brier_score_amm;

use battle_market::market_math;
use std::type_name::{Self, TypeName};
use sui::balance::{Self, Balance, Supply};
use sui::coin::{Self, Coin};
use sui::event;
use sui::object_bag::{Self, ObjectBag};
use sui::sui::SUI;
use sui::table::{Self, Table};

// ========== Error Constants ==========
const EInvalidMarket: u64 = 1;
const EZeroInvestment: u64 = 2;
const ECoinNotRegistered: u64 = 3;

// ========== Core Types ==========

/// Token representing ownership of a specific meme coin outcome
public struct BattleToken<phantom CoinT> has drop {}

/// Supply wrapper for battle tokens
public struct TokenSupply<phantom CoinT> has key, store {
    id: UID,
    supply: Supply<BattleToken<CoinT>>,
}

/// Core battle market vault implementing Brier Score Dual SCPM
public struct BattleVault has key, store {
    id: UID,
    /// Total SUI liquidity (numeraire reserve)
    numeraire_reserve: Balance<SUI>,
    /// Supply bag containing all token supplies
    supply_bag: ObjectBag,
    /// Number of competing meme coins
    num_outcomes: u64,
    /// Total shares outstanding across all outcomes
    total_shares: u128,
    /// Battle round identifier
    round_id: u64,
}

// ========== Events ==========

public struct VaultCreated has copy, drop {
    vault_id: address,
    round_id: u64,
}

public struct CoinRegistered has copy, drop {
    vault_id: address,
    coin_type: TypeName,
    outcome_index: u64,
}

public struct SharesPurchased has copy, drop {
    vault_id: address,
    buyer: address,
    coin_type: TypeName,
    numeraire_paid: u64,
    shares_received: u64,
    new_price: u64,
}

public struct SharesSold has copy, drop {
    vault_id: address,
    seller: address,
    coin_type: TypeName,
    shares_sold: u64,
    numeraire_received: u64,
    new_price: u64,
}

// ========== Core Functions ==========

/// Create new battle vault for meme coin competition
public fun new_vault(round_id: u64, ctx: &mut TxContext): BattleVault {
    let vault = BattleVault {
        id: object::new(ctx),
        numeraire_reserve: balance::zero(),
        supply_bag: object_bag::new(ctx),
        num_outcomes: 0,
        total_shares: 0,
        round_id,
    };

    event::emit(VaultCreated {
        vault_id: object::uid_to_address(&vault.id),
        round_id,
    });

    vault
}

/// Register a new meme coin type for competition
public fun register_coin<CoinT>(vault: &mut BattleVault, ctx: &mut TxContext) {
    let type_name = type_name::get<CoinT>();
    let token_supply = TokenSupply {
        id: object::new(ctx),
        supply: balance::create_supply(BattleToken<CoinT> {}),
    };

    vault.supply_bag.add(type_name, token_supply);
    vault.num_outcomes = vault.num_outcomes + 1;

    event::emit(CoinRegistered {
        vault_id: object::uid_to_address(&vault.id),
        coin_type: type_name,
        outcome_index: vault.num_outcomes - 1,
    });
}

/// Buy shares of a specific meme coin using Brier Score pricing
public fun buy_shares<CoinT>(
    vault: &mut BattleVault,
    coin_in: Coin<SUI>,
    ctx: &mut TxContext,
): Coin<BattleToken<CoinT>> {
    assert!(vault.num_outcomes > 1, EInvalidMarket);
    let numeraire_amount = coin_in.value();
    assert!(numeraire_amount > 0, EZeroInvestment);

    // Get current state for Brier Score calculation
    let current_shares = share_supply_value<CoinT>(vault);
    let total_shares = vault.total_shares;

    // Calculate shares to mint using Brier Score formula
    let shares_out = market_math::swap_rate_z_to_xi(
        current_shares,
        total_shares,
        numeraire_amount,
        vault.num_outcomes,
    );

    // Update vault state
    vault.numeraire_reserve.join(coin_in.into_balance());
    let shares_balance = mint_shares<CoinT>(vault, shares_out);
    let coin_out = shares_balance.into_coin(ctx);

    // Calculate new price for event
    let new_price = get_price<CoinT>(vault);

    event::emit(SharesPurchased {
        vault_id: object::uid_to_address(&vault.id),
        buyer: ctx.sender(),
        coin_type: type_name::get<CoinT>(),
        numeraire_paid: numeraire_amount,
        shares_received: shares_out,
        new_price,
    });

    coin_out
}

/// Sell shares of a specific meme coin using Brier Score pricing
public fun sell_shares<CoinT>(
    vault: &mut BattleVault,
    coin_in: Coin<BattleToken<CoinT>>,
    ctx: &mut TxContext,
): Coin<SUI> {
    assert!(vault.num_outcomes > 1, EInvalidMarket);
    let shares_amount = coin_in.value();
    assert!(shares_amount > 0, EZeroInvestment);

    // Get current state for Brier Score calculation
    let current_shares = share_supply_value<CoinT>(vault);
    let total_shares = vault.total_shares;

    // Calculate numeraire to return using Brier Score formula
    let numeraire_out = market_math::swap_rate_xi_to_z(
        current_shares,
        total_shares,
        shares_amount,
        vault.num_outcomes,
    );

    // Update vault state
    burn_shares<CoinT>(vault, coin_in.into_balance());
    let coin_out = vault.numeraire_reserve.split(numeraire_out).into_coin(ctx);

    // Calculate new price for event
    let new_price = get_price<CoinT>(vault);

    event::emit(SharesSold {
        vault_id: object::uid_to_address(&vault.id),
        seller: ctx.sender(),
        coin_type: type_name::get<CoinT>(),
        shares_sold: shares_amount,
        numeraire_received: numeraire_out,
        new_price,
    });

    coin_out
}

// ========== Price Discovery Functions ==========

/// Get current market price for a meme coin (0-100% scaled)
public fun get_price<CoinT>(vault: &BattleVault): u64 {
    assert!(vault.num_outcomes > 0, EInvalidMarket);
    let shares = share_supply_value<CoinT>(vault);
    let total_shares = vault.total_shares as u64;

    market_math::price(total_shares, shares)
}

/// Get total numeraire reserves in vault
public fun get_total_reserves(vault: &BattleVault): u64 {
    vault.numeraire_reserve.value()
}

/// Get number of registered meme coins
public fun get_num_outcomes(vault: &BattleVault): u64 {
    vault.num_outcomes
}

/// Get round ID
public fun get_round_id(vault: &BattleVault): u64 {
    vault.round_id
}

// ========== Internal Helper Functions ==========

fun mint_shares<CoinT>(vault: &mut BattleVault, amount: u64): Balance<BattleToken<CoinT>> {
    let type_name = type_name::get<CoinT>();
    let token_supply = vault.supply_bag.borrow_mut<TypeName, TokenSupply<CoinT>>(type_name);
    let balance = token_supply.supply.increase_supply(amount);

    vault.total_shares = vault.total_shares + (amount as u128);
    balance
}

fun burn_shares<CoinT>(vault: &mut BattleVault, balance: Balance<BattleToken<CoinT>>): u64 {
    let type_name = type_name::get<CoinT>();
    let token_supply = vault.supply_bag.borrow_mut<TypeName, TokenSupply<CoinT>>(type_name);
    let amount = balance.value();

    vault.total_shares = vault.total_shares - (amount as u128);
    token_supply.supply.decrease_supply(balance);
    amount
}

public fun share_supply_value<CoinT>(vault: &BattleVault): u64 {
    let type_name = type_name::get<CoinT>();
    let token_supply = vault.supply_bag.borrow<TypeName, TokenSupply<CoinT>>(type_name);
    token_supply.supply.supply_value()
}

// ========== Administrative Functions ==========

/// Share the vault publicly for trading
public fun share_vault(vault: BattleVault) {
    transfer::public_share_object(vault);
}
