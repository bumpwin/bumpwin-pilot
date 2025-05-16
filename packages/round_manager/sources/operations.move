module round_manager::operations;

use round_manager::battle_market::BattleMarket;
use round_manager::battle_round::BattleRound;
use round_manager::champ_amm::{Self, ChampAMM};
use round_manager::claim_box::{Self, ClaimBox};
use round_manager::meme_vault::MemeVault;
use round_manager::wsui::WSUI;
use sui::clock::Clock;

public fun sunrise_settlement<CoinT>(
    battle_round: &mut BattleRound,
    battle_market: BattleMarket,
    meme_vault: MemeVault<CoinT>,
    clock: &Clock,
    ctx: &mut TxContext,
): (ChampAMM<CoinT, WSUI>, ClaimBox<CoinT>) {
    battle_round.phase(clock).assert_after_end();

    let (sui_reserve, share_supply) = battle_market.destroy();

    let mut champ1 = meme_vault.destroy<CoinT>();
    let total = champ1.value();
    let champ2 = champ1.split(total/2);

    let champ_amm = champ_amm::new<CoinT, WSUI>(
        champ2,
        sui_reserve,
        ctx,
    );

    let claim_box = claim_box::new<CoinT>(
        champ1,
        share_supply,
        ctx,
    );

    (champ_amm, claim_box)
}
