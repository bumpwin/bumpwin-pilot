module round_manager::bs;

use round_manager::outcome_share_coin::OutcomeShare;
use sui::balance::{Balance, Supply};
use round_manager::wsui::WSUI;

public struct BalanceSheet<phantom CoinT> has key, store {
    id: UID,
    reserve_wsui: Balance<WSUI>,
    share_supply: Supply<OutcomeShare<CoinT>>,
}

public fun destroy<CoinT>(self: BalanceSheet<CoinT>): (Balance<WSUI>, Supply<OutcomeShare<CoinT>>) {
    let BalanceSheet {
        id,
        reserve_wsui,
        share_supply,
    } = self;
    id.delete();

    (reserve_wsui, share_supply)
}
