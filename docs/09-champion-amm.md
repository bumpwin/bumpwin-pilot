# Champion AMM（OBMM実装）

## 概要

Champion AMMは、勝者ChampCoinの継続的流動性を提供するAutomatic Market Makerです。**Order Book Inspired Market Making（OBMM）**を採用し、従来のConstant Product型AMM（x×y=k）を超えた効率的な価格発見を実現します。

## OBMM理論

### **従来AMM vs OBMM**

| 特徴 | Constant Product (Uniswap v2) | OBMM |
|------|-------------------------------|------|
| **価格関数** | x × y = k | √(x × y) = k |
| **価格インパクト** | 双曲線的 | 平方根的 |
| **流動性効率** | 低（全域分散） | 高（現在価格集中） |
| **大口取引** | 高いスリッページ | 低いスリッページ |

### **OBMM数学的定義**
```
価格関数: P = √(WSUI_reserve / ChampCoin_reserve)
不変式: √(WSUI_reserve × ChampCoin_reserve) = k
```

## 価格計算メカニズム

### **現在価格**
```move
/// 現在の市場価格計算
public fun get_current_price<T>(
    market: &ChampionsMarket<T>
): u64 {
    let wsui_reserve = market.wsui_reserve.value();
    let champ_reserve = market.champ_reserve.value();

    if (champ_reserve == 0) {
        return market.initial_price
    };

    // P = WSUI / ChampCoin（平方根調整済み）
    let price_numerator = wsui_reserve * PRICE_SCALE;
    let price = price_numerator / champ_reserve;

    price
}
```

### **OBMM Swap計算**
```move
/// WSUI → ChampCoin スワップ量計算
public fun calculate_wsui_to_champ_swap<T>(
    market: &ChampionsMarket<T>,
    wsui_input: u64
): (u64, u64) { // (champ_output, price_impact)
    let wsui_reserve = market.wsui_reserve.value();
    let champ_reserve = market.champ_reserve.value();

    // OBMM不変式: √(x × y) = k
    let k = math::sqrt(wsui_reserve * champ_reserve);

    // 新しいWSUI残高
    let new_wsui_reserve = wsui_reserve + wsui_input;

    // 不変式から新しいChampCoin残高を計算
    // k² = new_wsui_reserve × new_champ_reserve
    // new_champ_reserve = k² / new_wsui_reserve
    let k_squared = k * k;
    let new_champ_reserve = k_squared / new_wsui_reserve;

    let champ_output = champ_reserve - new_champ_reserve;

    // 価格インパクト計算
    let old_price = (wsui_reserve * PRICE_SCALE) / champ_reserve;
    let new_price = (new_wsui_reserve * PRICE_SCALE) / new_champ_reserve;
    let price_impact = ((new_price - old_price) * 100) / old_price;

    (champ_output, price_impact)
}
```

### **逆向きスワップ**
```move
/// ChampCoin → WSUI スワップ量計算
public fun calculate_champ_to_wsui_swap<T>(
    market: &ChampionsMarket<T>,
    champ_input: u64
): (u64, u64) { // (wsui_output, price_impact)
    let wsui_reserve = market.wsui_reserve.value();
    let champ_reserve = market.champ_reserve.value();

    let k = math::sqrt(wsui_reserve * champ_reserve);

    // 新しいChampCoin残高
    let new_champ_reserve = champ_reserve + champ_input;

    // 不変式から新しいWSUI残高を計算
    let k_squared = k * k;
    let new_wsui_reserve = k_squared / new_champ_reserve;

    let wsui_output = wsui_reserve - new_wsui_reserve;

    // 価格インパクト計算
    let old_price = (wsui_reserve * PRICE_SCALE) / champ_reserve;
    let new_price = (new_wsui_reserve * PRICE_SCALE) / new_champ_reserve;
    let price_impact = ((old_price - new_price) * 100) / old_price;

    (wsui_output, price_impact)
}
```

## スワップ実行システム

### **WSUI → ChampCoin スワップ**
```move
/// WSUIでChampCoinを購入
public fun swap_wsui_to_champ<T>(
    market: &mut ChampionsMarket<T>,
    wsui_payment: Coin<WSUI>,
    min_champ_out: u64,
    ctx: &mut TxContext
): Coin<ChampCoin<T>> {
    let wsui_amount = wsui_payment.value();

    // スワップ量計算
    let (champ_output, price_impact) = calculate_wsui_to_champ_swap(
        market,
        wsui_amount
    );

    // スリッページ保護
    assert!(champ_output >= min_champ_out, E_EXCESSIVE_SLIPPAGE);

    // 手数料計算（0.3%）
    let fee_amount = (wsui_amount * market.fee_rate) / 10000;
    let wsui_after_fee = wsui_amount - fee_amount;

    // 実際のスワップ量再計算（手数料調整後）
    let (actual_champ_output, _) = calculate_wsui_to_champ_swap(
        market,
        wsui_after_fee
    );

    // 残高更新
    let wsui_balance = wsui_payment.into_balance();
    market.wsui_reserve.join(wsui_balance);

    let champ_output_balance = market.champ_reserve.split(actual_champ_output);

    // 統計更新
    market.total_volume = market.total_volume + wsui_amount;

    // イベント発行
    emit_swap_executed_event<T>(
        tx_context::sender(ctx),
        SwapDirection::WSUIToChamp,
        wsui_amount,
        actual_champ_output,
        price_impact,
        fee_amount
    );

    coin::from_balance(champ_output_balance, ctx)
}
```

### **ChampCoin → WSUI スワップ**
```move
/// ChampCoinでWSUIを取得
public fun swap_champ_to_wsui<T>(
    market: &mut ChampionsMarket<T>,
    champ_payment: Coin<ChampCoin<T>>,
    min_wsui_out: u64,
    ctx: &mut TxContext
): Coin<WSUI> {
    let champ_amount = champ_payment.value();

    // スワップ量計算
    let (wsui_output, price_impact) = calculate_champ_to_wsui_swap(
        market,
        champ_amount
    );

    // スリッページ保護
    assert!(wsui_output >= min_wsui_out, E_EXCESSIVE_SLIPPAGE);

    // 手数料計算（WSUI出力から差し引き）
    let fee_amount = (wsui_output * market.fee_rate) / 10000;
    let wsui_after_fee = wsui_output - fee_amount;

    // 残高更新
    let champ_balance = champ_payment.into_balance();
    market.champ_reserve.join(champ_balance);

    let wsui_output_balance = market.wsui_reserve.split(wsui_after_fee);

    // 手数料をプロトコルに送信（LOSER保有者向け）
    let fee_balance = market.wsui_reserve.split(fee_amount);
    transfer_fee_to_loser_pool(fee_balance);

    // 統計更新
    market.total_volume = market.total_volume + wsui_output;

    // イベント発行
    emit_swap_executed_event<T>(
        tx_context::sender(ctx),
        SwapDirection::ChampToWSUI,
        wsui_after_fee,
        champ_amount,
        price_impact,
        fee_amount
    );

    coin::from_balance(wsui_output_balance, ctx)
}
```

## 流動性プロビジョン

### **流動性追加**
```move
/// 流動性提供（両サイド同時）
public fun add_liquidity<T>(
    market: &mut ChampionsMarket<T>,
    wsui_payment: Coin<WSUI>,
    champ_payment: Coin<ChampCoin<T>>,
    min_lp_tokens: u64,
    ctx: &mut TxContext
): Coin<LiquidityToken<T>> {
    let wsui_amount = wsui_payment.value();
    let champ_amount = champ_payment.value();

    // 現在の比率確認
    let current_ratio = get_current_price<T>(market);
    let provided_ratio = (wsui_amount * PRICE_SCALE) / champ_amount;

    // 比率許容範囲確認（±1%）
    let ratio_tolerance = current_ratio / 100;
    assert!(
        provided_ratio >= current_ratio - ratio_tolerance &&
        provided_ratio <= current_ratio + ratio_tolerance,
        E_RATIO_MISMATCH
    );

    // LP Token発行量計算
    let total_lp_supply = get_total_lp_supply<T>(market);
    let lp_tokens_to_mint = if (total_lp_supply == 0) {
        // 初回流動性: 幾何平均
        math::sqrt(wsui_amount * champ_amount)
    } else {
        // 既存流動性: 比例計算
        math::min(
            (wsui_amount * total_lp_supply) / market.wsui_reserve.value(),
            (champ_amount * total_lp_supply) / market.champ_reserve.value()
        )
    };

    assert!(lp_tokens_to_mint >= min_lp_tokens, E_INSUFFICIENT_LP_OUTPUT);

    // 残高更新
    market.wsui_reserve.join(wsui_payment.into_balance());
    market.champ_reserve.join(champ_payment.into_balance());

    // LP Token発行
    let lp_tokens = mint_lp_tokens<T>(market, lp_tokens_to_mint, ctx);

    coin::from_balance(lp_tokens, ctx)
}
```

### **流動性除去**
```move
/// 流動性除去
public fun remove_liquidity<T>(
    market: &mut ChampionsMarket<T>,
    lp_tokens: Coin<LiquidityToken<T>>,
    min_wsui_out: u64,
    min_champ_out: u64,
    ctx: &mut TxContext
): (Coin<WSUI>, Coin<ChampCoin<T>>) {
    let lp_amount = lp_tokens.value();
    let total_lp_supply = get_total_lp_supply<T>(market);

    // 引き出し比率計算
    let withdrawal_ratio = (lp_amount * RATIO_SCALE) / total_lp_supply;

    // 引き出し量計算
    let wsui_output = (market.wsui_reserve.value() * withdrawal_ratio) / RATIO_SCALE;
    let champ_output = (market.champ_reserve.value() * withdrawal_ratio) / RATIO_SCALE;

    // 最小出力確認
    assert!(wsui_output >= min_wsui_out, E_INSUFFICIENT_WSUI_OUTPUT);
    assert!(champ_output >= min_champ_out, E_INSUFFICIENT_CHAMP_OUTPUT);

    // 残高更新
    let wsui_balance = market.wsui_reserve.split(wsui_output);
    let champ_balance = market.champ_reserve.split(champ_output);

    // LP Token燃焼
    burn_lp_tokens<T>(market, lp_tokens.into_balance());

    (
        coin::from_balance(wsui_balance, ctx),
        coin::from_balance(champ_balance, ctx)
    )
}
```

## 価格オラクル機能

### **TWAP（Time-Weighted Average Price）**
```move
/// 時間加重平均価格の計算
public struct PriceOracle<phantom T> has key {
    id: UID,
    market_id: ID,
    /// 価格履歴（時刻, 価格）
    price_history: vector<PricePoint>,
    /// 最終更新時刻
    last_update: u64,
    /// TWAP期間（秒）
    twap_period: u64,
}

public struct PricePoint has store {
    timestamp: u64,
    price: u64,
    cumulative_price: u128,
}

/// TWAP更新
public fun update_price_oracle<T>(
    oracle: &mut PriceOracle<T>,
    market: &ChampionsMarket<T>,
    clock: &Clock
) {
    let current_time = clock::timestamp_ms(clock);
    let current_price = get_current_price<T>(market);

    // 累積価格更新
    let time_elapsed = current_time - oracle.last_update;
    let last_cumulative = if (oracle.price_history.is_empty()) {
        0u128
    } else {
        oracle.price_history.borrow(oracle.price_history.length() - 1).cumulative_price
    };

    let new_cumulative = last_cumulative +
        (current_price as u128) * (time_elapsed as u128);

    // 新しい価格ポイント追加
    let price_point = PricePoint {
        timestamp: current_time,
        price: current_price,
        cumulative_price: new_cumulative,
    };

    oracle.price_history.push_back(price_point);
    oracle.last_update = current_time;

    // 古いデータクリーンアップ
    cleanup_old_price_data(oracle, current_time);
}

/// TWAP価格取得
public fun get_twap_price<T>(
    oracle: &PriceOracle<T>,
    clock: &Clock
): u64 {
    let current_time = clock::timestamp_ms(clock);
    let start_time = current_time - (oracle.twap_period * 1000); // 秒をミリ秒に変換

    // 期間内の価格データを検索
    let start_index = find_price_index_at_time(oracle, start_time);
    let end_index = oracle.price_history.length() - 1;

    if (start_index == end_index) {
        // データ不足: 現在価格を返す
        return oracle.price_history.borrow(end_index).price
    };

    // TWAP計算
    let start_point = oracle.price_history.borrow(start_index);
    let end_point = oracle.price_history.borrow(end_index);

    let cumulative_diff = end_point.cumulative_price - start_point.cumulative_price;
    let time_diff = end_point.timestamp - start_point.timestamp;

    (cumulative_diff / (time_diff as u128)) as u64
}
```

## 高度な取引機能

### **リミットオーダー**
```move
/// リミット注文システム
public struct LimitOrder<phantom T> has key {
    id: UID,
    trader: address,
    order_type: u8, // 0=buy, 1=sell
    target_price: u64,
    wsui_amount: u64,
    champ_amount: u64,
    created_at: u64,
    expires_at: u64,
}

/// リミット注文作成
public fun create_limit_order<T>(
    market: &ChampionsMarket<T>,
    order_type: u8,
    target_price: u64,
    payment: Coin<WSUI>, // またはChampCoin
    expires_in_hours: u64,
    ctx: &mut TxContext
): LimitOrder<T> {
    let current_time = tx_context::epoch_timestamp_ms(ctx);
    let expires_at = current_time + (expires_in_hours * 3600 * 1000);

    LimitOrder {
        id: object::new(ctx),
        trader: tx_context::sender(ctx),
        order_type,
        target_price,
        wsui_amount: if (order_type == 0) payment.value() else 0,
        champ_amount: if (order_type == 1) payment.value() else 0,
        created_at: current_time,
        expires_at,
    }
}

/// リミット注文実行チェック
public fun try_execute_limit_order<T>(
    market: &mut ChampionsMarket<T>,
    order: &mut LimitOrder<T>,
    clock: &Clock,
    ctx: &mut TxContext
): bool {
    let current_price = get_current_price<T>(market);
    let current_time = clock::timestamp_ms(clock);

    // 期限チェック
    if (current_time > order.expires_at) {
        return false
    };

    // 価格条件チェック
    let should_execute = if (order.order_type == 0) {
        // Buy order: 現在価格が目標価格以下
        current_price <= order.target_price
    } else {
        // Sell order: 現在価格が目標価格以上
        current_price >= order.target_price
    };

    if (!should_execute) {
        return false
    };

    // 注文実行
    if (order.order_type == 0) {
        // Buy実行
        let wsui_coin = coin::mint_for_testing<WSUI>(order.wsui_amount, ctx);
        let champ_coin = swap_wsui_to_champ<T>(market, wsui_coin, 0, ctx);
        transfer::public_transfer(champ_coin, order.trader);
    } else {
        // Sell実行
        let champ_coin = coin::mint_for_testing<ChampCoin<T>>(order.champ_amount, ctx);
        let wsui_coin = swap_champ_to_wsui<T>(market, champ_coin, 0, ctx);
        transfer::public_transfer(wsui_coin, order.trader);
    };

    true
}
```

### **DCA（Dollar Cost Averaging）**
```move
/// 定期購入設定
public struct DCASchedule<phantom T> has key {
    id: UID,
    trader: address,
    wsui_per_purchase: u64,
    interval_hours: u64,
    total_purchases: u64,
    completed_purchases: u64,
    next_purchase_time: u64,
    wsui_vault: Balance<WSUI>,
}

/// DCA実行
public fun execute_dca_purchase<T>(
    schedule: &mut DCASchedule<T>,
    market: &mut ChampionsMarket<T>,
    clock: &Clock,
    ctx: &mut TxContext
): Option<Coin<ChampCoin<T>>> {
    let current_time = clock::timestamp_ms(clock);

    // 実行時刻チェック
    if (current_time < schedule.next_purchase_time) {
        return option::none()
    };

    // 完了チェック
    if (schedule.completed_purchases >= schedule.total_purchases) {
        return option::none()
    };

    // 残高チェック
    if (schedule.wsui_vault.value() < schedule.wsui_per_purchase) {
        return option::none()
    };

    // 購入実行
    let wsui_payment = schedule.wsui_vault.split(schedule.wsui_per_purchase);
    let wsui_coin = coin::from_balance(wsui_payment, ctx);
    let champ_coin = swap_wsui_to_champ<T>(market, wsui_coin, 0, ctx);

    // スケジュール更新
    schedule.completed_purchases = schedule.completed_purchases + 1;
    schedule.next_purchase_time = current_time +
        (schedule.interval_hours * 3600 * 1000);

    option::some(champ_coin)
}
```

## 統計・分析機能

### **市場統計**
```move
/// 市場統計情報
public struct MarketStats<phantom T> has copy, drop {
    total_volume_24h: u64,
    price_change_24h: i64, // basis points
    high_24h: u64,
    low_24h: u64,
    liquidity_depth: u64,
    active_traders: u64,
}

/// 24時間統計計算
public fun calculate_24h_stats<T>(
    market: &ChampionsMarket<T>,
    oracle: &PriceOracle<T>,
    clock: &Clock
): MarketStats<T> {
    let current_time = clock::timestamp_ms(clock);
    let start_time = current_time - (24 * 3600 * 1000);

    // 24時間前の価格
    let price_24h_ago = get_price_at_time<T>(oracle, start_time);
    let current_price = get_current_price<T>(market);

    // 価格変動計算
    let price_change = ((current_price as i128) - (price_24h_ago as i128)) * 10000 /
                      (price_24h_ago as i128);

    MarketStats {
        total_volume_24h: calculate_volume_in_period(market, start_time, current_time),
        price_change_24h: price_change as i64,
        high_24h: get_high_in_period<T>(oracle, start_time, current_time),
        low_24h: get_low_in_period<T>(oracle, start_time, current_time),
        liquidity_depth: calculate_liquidity_depth<T>(market),
        active_traders: count_active_traders(market, start_time, current_time),
    }
}
```

---

**次**: [Move実装仕様](./10-move-implementation.md)
