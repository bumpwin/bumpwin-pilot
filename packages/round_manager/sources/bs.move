module round_manager::bs;

use round_manager::outcome_share_coin::OutcomeShare;
use sui::balance::{Balance, Supply};
use sui::sui::SUI;

public struct BalanceSheet<phantom CoinT> has key, store {
    id: UID,
    sui_reserve: Balance<SUI>,
    share_supply: Supply<OutcomeShare<CoinT>>,
}

public fun destroy<CoinT>(self: BalanceSheet<CoinT>): (Balance<SUI>, Supply<OutcomeShare<CoinT>>) {
    let BalanceSheet {
        id,
        sui_reserve,
        share_supply,
    } = self;
    id.delete();

    (sui_reserve, share_supply)
}
