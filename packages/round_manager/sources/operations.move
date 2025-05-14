module round_manager::operations;

use round_manager::battle_round::BattleRound;
use round_manager::bs::BalanceSheet;
use round_manager::champ_amm::{Self, ChampAMM};
use round_manager::claim_box::{Self, ClaimBox};
use sui::balance::Balance;
use sui::clock::Clock;
use sui::sui::SUI;

#[allow(unused_field)]
public struct MemeVault<phantom CoinT> has key, store {
    id: UID,
    meme_reserve: Balance<CoinT>,
}

public fun sunrise_settlement<CoinT>(
    battle_round: &mut BattleRound,
    balance_sheet: BalanceSheet<CoinT>,
    meme_vault: &mut MemeVault<CoinT>,
    clock: &Clock,
    ctx: &mut TxContext,
): (ChampAMM<CoinT, SUI>, ClaimBox<CoinT>) {
    battle_round.phase(clock).assert_after_end();

    let (sui_reserve, share_supply) = balance_sheet.destroy();

    let total = meme_vault.meme_reserve.value();
    let champ1 = meme_vault.meme_reserve.split(total/2);
    let champ2 = meme_vault.meme_reserve.split(total);

    let champ_amm = champ_amm::new<CoinT, SUI>(
        champ1,
        sui_reserve,
        ctx,
    );

    let claim_box = claim_box::new<CoinT>(
        champ2,
        share_supply,
        ctx,
    );

    (champ_amm, claim_box)
}
