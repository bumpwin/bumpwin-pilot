# Move実装仕様

## 概要

このドキュメントでは、BUMP.WINプロトコルの具体的なMove実装について詳細に説明します。Sui Moveの特徴を活用した効率的で安全なスマートコントラクトの設計と実装方針を示します。

## プロジェクト構造

### **Moveパッケージ構成**
```
sources/
├── core/
│   ├── battle_vault.move          # 中核データ管理
│   ├── share_token.move           # Share<T>型定義
│   └── types.move                 # 共通型定義
├── phases/
│   ├── decision_market.move       # Daytime制御
│   ├── dark_pool.move            # DarkNight制御
│   └── settlement_engine.move     # Settlement制御
├── mechanisms/
│   ├── brier_score_math.move     # Brier Score計算
│   ├── sealed_batch_auction.move # TLE暗号化
│   └── champion_amm.move         # OBMM AMM
├── tokens/
│   ├── champ_coin.move           # ChampCoin管理
│   └── loser_token.move          # LOSER Token
├── utils/
│   ├── math.move                 # 数学関数
│   ├── events.move               # イベント定義
│   └── errors.move               # エラーコード
└── init.move                     # 初期化関数
```

## コア実装

### **battle_vault.move**
```move
module battle_market::battle_vault {
    use std::type_name::{Self, TypeName};
    use sui::object::{Self, UID, ID};
    use sui::object_bag::{Self, ObjectBag};
    use sui::balance::{Self, Balance, Supply};
    use sui::coin::{Self, Coin};
    use sui::tx_context::{Self, TxContext};
    use battle_market::share_token::Share;
    use battle_market::errors;
    
    /// 中核データ金庫
    public struct BattleVault has key, store {
        id: UID,
        /// WSUI準備金
        wsui_reserve: Balance<WSUI>,
        /// Share供給管理 (TypeName → Supply<Share<T>>)
        share_supplies: ObjectBag,
        /// 登録コイン数
        num_outcomes: u64,
        /// 総Share数（効率化キャッシュ）
        total_shares: u128,
        /// ラウンド識別子
        round_id: u64,
    }
    
    /// Vault作成能力
    public struct VaultCreationCap has key {
        id: UID,
    }
    
    // === 公開関数 ===
    
    /// 新しいVault作成
    public fun create_vault(
        cap: &VaultCreationCap,
        round_id: u64,
        ctx: &mut TxContext
    ): BattleVault {
        BattleVault {
            id: object::new(ctx),
            wsui_reserve: balance::zero(),
            share_supplies: object_bag::new(ctx),
            num_outcomes: 0,
            total_shares: 0,
            round_id,
        }
    }
    
    /// ミームコイン登録
    public fun register_coin<T>(
        vault: &mut BattleVault,
        registration_fee: Coin<WSUI>,
        ctx: &mut TxContext
    ) {
        let coin_type = type_name::get<T>();
        
        // 重複チェック
        assert!(
            !vault.share_supplies.contains(coin_type),
            errors::already_registered()
        );
        
        // 登録手数料預入
        vault.wsui_reserve.join(registration_fee.into_balance());
        
        // Share供給作成
        let share_supply = balance::create_supply(Share<T> {});
        vault.share_supplies.add(coin_type, share_supply);
        vault.num_outcomes = vault.num_outcomes + 1;
        
        // 登録イベント発行
        sui::event::emit(CoinRegistered<T> {
            vault_id: object::id(vault),
            coin_type,
            registration_time: tx_context::epoch_timestamp_ms(ctx),
        });
    }
    
    /// Share発行
    public fun mint_shares<T>(
        vault: &mut BattleVault,
        amount: u64,
        ctx: &mut TxContext
    ): Balance<Share<T>> {
        let coin_type = type_name::get<T>();
        assert!(
            vault.share_supplies.contains(coin_type),
            errors::coin_not_registered()
        );
        
        let supply = vault.share_supplies.borrow_mut<TypeName, Supply<Share<T>>>(coin_type);
        let new_shares = supply.increase_supply(amount);
        vault.total_shares = vault.total_shares + (amount as u128);
        
        new_shares
    }
    
    /// Share燃焼
    public fun burn_shares<T>(
        vault: &mut BattleVault,
        shares: Balance<Share<T>>
    ): u64 {
        let coin_type = type_name::get<T>();
        let amount = shares.value();
        
        let supply = vault.share_supplies.borrow_mut<TypeName, Supply<Share<T>>>(coin_type);
        supply.decrease_supply(shares);
        vault.total_shares = vault.total_shares - (amount as u128);
        
        amount
    }
    
    /// WSUI預入
    public fun deposit_wsui(
        vault: &mut BattleVault,
        payment: Coin<WSUI>
    ) {
        vault.wsui_reserve.join(payment.into_balance());
    }
    
    /// WSUI引出
    public fun withdraw_wsui(
        vault: &mut BattleVault,
        amount: u64,
        ctx: &mut TxContext
    ): Balance<WSUI> {
        assert!(
            vault.wsui_reserve.value() >= amount,
            errors::insufficient_balance()
        );
        
        vault.wsui_reserve.split(amount)
    }
    
    // === ゲッター関数 ===
    
    public fun get_wsui_reserve(vault: &BattleVault): u64 {
        vault.wsui_reserve.value()
    }
    
    public fun get_total_shares(vault: &BattleVault): u128 {
        vault.total_shares
    }
    
    public fun get_num_outcomes(vault: &BattleVault): u64 {
        vault.num_outcomes
    }
    
    public fun get_round_id(vault: &BattleVault): u64 {
        vault.round_id
    }
    
    public fun get_share_supply<T>(vault: &BattleVault): u64 {
        let coin_type = type_name::get<T>();
        if (!vault.share_supplies.contains(coin_type)) {
            return 0
        };
        
        let supply = vault.share_supplies.borrow<TypeName, Supply<Share<T>>>(coin_type);
        supply.supply_value()
    }
    
    /// 登録済みコインリスト
    public fun get_registered_coins(vault: &BattleVault): vector<TypeName> {
        vault.share_supplies.keys()
    }
    
    // === 内部関数 ===
    
    /// Vault内容の分解（フェーズ移管用）
    public(package) fun destructure_vault(
        vault: BattleVault
    ): (Balance<WSUI>, ObjectBag, u64, u128, u64) {
        let BattleVault {
            id,
            wsui_reserve,
            share_supplies,
            num_outcomes,
            total_shares,
            round_id,
        } = vault;
        
        object::delete(id);
        (wsui_reserve, share_supplies, num_outcomes, total_shares, round_id)
    }
    
    // === イベント ===
    
    public struct CoinRegistered<phantom T> has copy, drop {
        vault_id: ID,
        coin_type: TypeName,
        registration_time: u64,
    }
    
    public struct SharesMinted<phantom T> has copy, drop {
        vault_id: ID,
        coin_type: TypeName,
        amount: u64,
        recipient: address,
    }
    
    public struct SharesBurned<phantom T> has copy, drop {
        vault_id: ID,
        coin_type: TypeName,
        amount: u64,
        burner: address,
    }
}
```

### **share_token.move**
```move
module battle_market::share_token {
    use std::type_name::{Self, TypeName};
    use sui::object::{Self, UID};
    
    /// ファントムタイプShare（ゼロコスト抽象化）
    public struct Share<phantom T> has store {}
    
    /// 登録確認書
    public struct RegistrationReceipt<phantom T> has store {
        coin_type: TypeName,
        registration_time: u64,
        registrar: address,
    }
    
    /// 型名取得
    public fun get_share_type<T>(): TypeName {
        type_name::get<Share<T>>()
    }
    
    /// 元のコイン型取得
    public fun get_underlying_type<T>(): TypeName {
        type_name::get<T>()
    }
    
    /// 型検証
    public fun verify_share_type<T>(expected: TypeName): bool {
        type_name::get<Share<T>>() == expected
    }
}
```

## フェーズ制御実装

### **decision_market.move**
```move
module battle_market::decision_market {
    use sui::object::{Self, UID, ID};
    use sui::clock::{Self, Clock};
    use sui::coin::{Self, Coin};
    use sui::balance::Balance;
    use sui::tx_context::{Self, TxContext};
    use std::type_name::TypeName;
    use battle_market::battle_vault::{Self, BattleVault};
    use battle_market::share_token::Share;
    use battle_market::brier_score_math;
    use battle_market::errors;
    
    /// Daytime市場制御
    public struct DecisionMarket has key {
        id: UID,
        vault: BattleVault,
        registered_coins: vector<TypeName>,
        market_start_ms: u64,
        market_end_ms: u64,
        /// 手数料レート（basis points）
        fee_rate: u64,
    }
    
    /// 市場作成能力
    public struct MarketCreationCap has key {
        id: UID,
    }
    
    // === ライフサイクル管理 ===
    
    /// Registration→Daytime遷移
    public fun create_from_vault(
        cap: &MarketCreationCap,
        vault: BattleVault,
        duration_hours: u64,
        clock: &Clock,
        ctx: &mut TxContext
    ): DecisionMarket {
        let current_time = clock::timestamp_ms(clock);
        let registered_coins = battle_vault::get_registered_coins(&vault);
        
        // 最小参加者数確認
        assert!(
            registered_coins.length() >= 3,
            errors::insufficient_participants()
        );
        
        DecisionMarket {
            id: object::new(ctx),
            vault,
            registered_coins,
            market_start_ms: current_time,
            market_end_ms: current_time + (duration_hours * 3600 * 1000),
            fee_rate: 100, // 1%
        }
    }
    
    /// Daytime→DarkNight遷移
    public fun transition_to_darknight(
        market: DecisionMarket,
        clock: &Clock
    ): (BattleVault, vector<TypeName>) {
        let current_time = clock::timestamp_ms(clock);
        assert!(
            current_time >= market.market_end_ms,
            errors::market_not_ended()
        );
        
        let DecisionMarket {
            id,
            vault,
            registered_coins,
            ..
        } = market;
        
        object::delete(id);
        
        // Top 8選出
        let finalist_coins = select_top_8_coins(&vault, &registered_coins);
        
        (vault, finalist_coins)
    }
    
    // === 取引操作 ===
    
    /// Share購入
    public fun buy_shares<T>(
        market: &mut DecisionMarket,
        payment: Coin<WSUI>,
        min_shares_out: u64,
        clock: &Clock,
        ctx: &mut TxContext
    ): Coin<Share<T>> {
        // 市場開放時間確認
        assert!(is_market_active(market, clock), errors::market_closed());
        
        let wsui_amount = payment.value();
        
        // 手数料計算
        let fee_amount = (wsui_amount * market.fee_rate) / 10000;
        let wsui_after_fee = wsui_amount - fee_amount;
        
        // Brier Score価格計算
        let shares_to_mint = brier_score_math::calculate_buy_amount(
            battle_vault::get_share_supply<T>(&market.vault),
            battle_vault::get_total_shares(&market.vault),
            wsui_after_fee,
            battle_vault::get_num_outcomes(&market.vault)
        );
        
        // スリッページ確認
        assert!(shares_to_mint >= min_shares_out, errors::excessive_slippage());
        
        // Vault更新
        battle_vault::deposit_wsui(&mut market.vault, payment);
        let new_shares = battle_vault::mint_shares<T>(&mut market.vault, shares_to_mint, ctx);
        
        // 手数料をLOSERプールに送金
        let fee_balance = battle_vault::withdraw_wsui(&mut market.vault, fee_amount, ctx);
        transfer_fee_to_loser_pool(fee_balance);
        
        // イベント発行
        sui::event::emit(SharesPurchased<T> {
            market_id: object::id(market),
            buyer: tx_context::sender(ctx),
            wsui_amount,
            shares_received: shares_to_mint,
            price: wsui_after_fee / shares_to_mint,
            fee_paid: fee_amount,
        });
        
        coin::from_balance(new_shares, ctx)
    }
    
    /// Share売却
    public fun sell_shares<T>(
        market: &mut DecisionMarket,
        shares: Coin<Share<T>>,
        min_wsui_out: u64,
        clock: &Clock,
        ctx: &mut TxContext
    ): Coin<WSUI> {
        assert!(is_market_active(market, clock), errors::market_closed());
        
        let share_amount = shares.value();
        
        // Brier Score逆計算
        let wsui_output = brier_score_math::calculate_sell_amount(
            share_amount,
            battle_vault::get_share_supply<T>(&market.vault),
            battle_vault::get_total_shares(&market.vault),
            battle_vault::get_num_outcomes(&market.vault)
        );
        
        // 手数料計算
        let fee_amount = (wsui_output * market.fee_rate) / 10000;
        let wsui_after_fee = wsui_output - fee_amount;
        
        // スリッページ確認
        assert!(wsui_after_fee >= min_wsui_out, errors::excessive_slippage());
        
        // Vault更新
        battle_vault::burn_shares<T>(&mut market.vault, shares.into_balance());
        let wsui_balance = battle_vault::withdraw_wsui(&mut market.vault, wsui_after_fee, ctx);
        
        // 手数料処理
        let fee_balance = battle_vault::withdraw_wsui(&mut market.vault, fee_amount, ctx);
        transfer_fee_to_loser_pool(fee_balance);
        
        // イベント発行
        sui::event::emit(SharesSold<T> {
            market_id: object::id(market),
            seller: tx_context::sender(ctx),
            shares_amount: share_amount,
            wsui_received: wsui_after_fee,
            price: wsui_after_fee / share_amount,
            fee_paid: fee_amount,
        });
        
        coin::from_balance(wsui_balance, ctx)
    }
    
    // === 内部関数 ===
    
    fun is_market_active(market: &DecisionMarket, clock: &Clock): bool {
        let current_time = clock::timestamp_ms(clock);
        current_time >= market.market_start_ms && current_time < market.market_end_ms
    }
    
    fun select_top_8_coins(
        vault: &BattleVault,
        registered_coins: &vector<TypeName>
    ): vector<TypeName> {
        // Share数でソートして上位8つを選出
        // 実装は簡略化
        let mut finalist = vector::empty();
        let mut i = 0;
        while (i < registered_coins.length() && i < 8) {
            finalist.push_back(registered_coins[i]);
            i = i + 1;
        };
        finalist
    }
    
    fun transfer_fee_to_loser_pool(fee: Balance<WSUI>) {
        // LOSER保有者プールへの手数料転送
        // 実装は LOSER token モジュールと連携
    }
    
    // === イベント ===
    
    public struct SharesPurchased<phantom T> has copy, drop {
        market_id: ID,
        buyer: address,
        wsui_amount: u64,
        shares_received: u64,
        price: u64,
        fee_paid: u64,
    }
    
    public struct SharesSold<phantom T> has copy, drop {
        market_id: ID,
        seller: address,
        shares_amount: u64,
        wsui_received: u64,
        price: u64,
        fee_paid: u64,
    }
}
```

## 数学ライブラリ実装

### **brier_score_math.move**
```move
module battle_market::brier_score_math {
    use battle_market::math;
    
    /// 固定小数点スケール
    const SCALE: u128 = 1000000000; // 10^9
    const MAX_ITERATIONS: u64 = 100;
    const CONVERGENCE_THRESHOLD: u128 = 1000; // 0.000001
    
    /// Brier Score買い注文計算
    public fun calculate_buy_amount(
        current_shares: u64,
        total_shares: u128,
        wsui_input: u64,
        num_outcomes: u64
    ): u64 {
        // 現在確率計算
        let current_prob = if (total_shares == 0) {
            SCALE / (num_outcomes as u128)
        } else {
            (current_shares as u128) * SCALE / total_shares
        };
        
        // Newton-Raphson法で最適解を計算
        let optimal_shares = solve_optimal_shares(
            current_prob,
            wsui_input,
            total_shares,
            num_outcomes
        );
        
        (optimal_shares as u64)
    }
    
    /// Brier Score売り注文計算
    public fun calculate_sell_amount(
        share_input: u64,
        current_shares: u64,
        total_shares: u128,
        num_outcomes: u64
    ): u64 {
        // 売却後の状態計算
        let new_current_shares = current_shares - share_input;
        let new_total_shares = total_shares - (share_input as u128);
        
        // 価格変化に基づくWSUI量計算
        let wsui_output = calculate_value_change(
            current_shares,
            new_current_shares,
            total_shares,
            new_total_shares,
            num_outcomes
        );
        
        wsui_output
    }
    
    /// Newton-Raphson最適化
    fun solve_optimal_shares(
        current_prob: u128,
        investment: u64,
        total_shares: u128,
        num_outcomes: u64
    ): u128 {
        let mut shares = (investment as u128) * SCALE / num_outcomes as u128;
        let mut iteration = 0;
        
        while (iteration < MAX_ITERATIONS) {
            // f(s) = Brier Score gradient
            let f_val = brier_score_gradient(
                shares,
                current_prob,
                investment,
                total_shares,
                num_outcomes
            );
            
            // f'(s) = second derivative
            let df_val = brier_score_second_derivative(
                shares,
                total_shares,
                num_outcomes
            );
            
            // Newton update
            let delta = (f_val * SCALE) / df_val;
            
            if (delta < CONVERGENCE_THRESHOLD) {
                break
            };
            
            shares = if (delta > shares) {
                shares / 2 // 発散防止
            } else {
                shares - delta
            };
            
            iteration = iteration + 1;
        };
        
        shares
    }
    
    /// Brier Score勾配計算
    fun brier_score_gradient(
        shares: u128,
        current_prob: u128,
        investment: u64,
        total_shares: u128,
        num_outcomes: u64
    ): u128 {
        // ∂BS/∂s の計算
        let new_prob = shares * SCALE / (total_shares + shares);
        let prob_diff = new_prob - current_prob;
        
        2 * prob_diff * SCALE / (num_outcomes as u128)
    }
    
    /// 二次微分計算
    fun brier_score_second_derivative(
        shares: u128,
        total_shares: u128,
        num_outcomes: u64
    ): u128 {
        // ∂²BS/∂s² の計算
        let denominator = (total_shares + shares) * (total_shares + shares);
        (2 * SCALE * SCALE) / (denominator * (num_outcomes as u128))
    }
    
    /// 価値変化計算
    fun calculate_value_change(
        old_shares: u64,
        new_shares: u64,
        old_total: u128,
        new_total: u128,
        num_outcomes: u64
    ): u64 {
        let old_prob = (old_shares as u128) * SCALE / old_total;
        let new_prob = (new_shares as u128) * SCALE / new_total;
        
        let prob_diff = old_prob - new_prob;
        let value_change = (prob_diff * old_total) / SCALE;
        
        (value_change as u64)
    }
}
```

## エラーハンドリング

### **errors.move**
```move
module battle_market::errors {
    /// バトル金庫エラー
    public fun insufficient_balance(): u64 { 1001 }
    public fun already_registered(): u64 { 1002 }
    public fun coin_not_registered(): u64 { 1003 }
    public fun invalid_vault_state(): u64 { 1004 }
    
    /// 決定市場エラー
    public fun market_closed(): u64 { 2001 }
    public fun market_not_ended(): u64 { 2002 }
    public fun insufficient_participants(): u64 { 2003 }
    public fun excessive_slippage(): u64 { 2004 }
    
    /// DarkPoolエラー
    public fun batch_not_ended(): u64 { 3001 }
    public fun already_executed(): u64 { 3002 }
    public fun invalid_batch_index(): u64 { 3003 }
    public fun decryption_failed(): u64 { 3004 }
    
    /// Settlement エラー
    public fun already_settled(): u64 { 4001 }
    public fun invalid_winner(): u64 { 4002 }
    public fun settlement_failed(): u64 { 4003 }
    
    /// 一般エラー
    public fun unauthorized_access(): u64 { 9001 }
    public fun invalid_parameters(): u64 { 9002 }
    public fun calculation_overflow(): u64 { 9003 }
}
```

## 初期化とデプロイ

### **init.move**
```move
module battle_market::init {
    use sui::object;
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use battle_market::battle_vault::VaultCreationCap;
    use battle_market::decision_market::MarketCreationCap;
    
    /// パッケージ初期化
    fun init(ctx: &mut TxContext) {
        // 管理者権限の作成と配布
        let vault_cap = VaultCreationCap {
            id: object::new(ctx),
        };
        
        let market_cap = MarketCreationCap {
            id: object::new(ctx),
        };
        
        // 管理者に権限を譲渡
        let admin = tx_context::sender(ctx);
        transfer::transfer(vault_cap, admin);
        transfer::transfer(market_cap, admin);
        
        // プロトコル設定の初期化
        initialize_protocol_settings(ctx);
    }
    
    fun initialize_protocol_settings(ctx: &mut TxContext) {
        // グローバル設定の初期化
        // LOSER配布レート、手数料設定等
    }
}
```

## テスト実装

### **テスト構造**
```move
#[test_only]
module battle_market::battle_vault_tests {
    use sui::test_scenario::{Self, Scenario};
    use sui::coin;
    use battle_market::battle_vault;
    
    #[test]
    fun test_vault_creation() {
        let admin = @0x1;
        let scenario = test_scenario::begin(admin);
        
        // Vault作成テスト
        let vault = battle_vault::create_vault(1, test_scenario::ctx(&mut scenario));
        
        assert!(battle_vault::get_round_id(&vault) == 1, 0);
        assert!(battle_vault::get_num_outcomes(&vault) == 0, 1);
        
        test_scenario::end(scenario);
    }
    
    #[test] 
    fun test_coin_registration() {
        // コイン登録テスト実装
    }
    
    #[test]
    fun test_share_minting() {
        // Share発行テスト実装
    }
}
```

## ガス最適化戦略

### **バッチ処理**
```move
/// 複数操作の一括実行
public fun batch_operations<T>(
    market: &mut DecisionMarket,
    operations: vector<Operation<T>>,
    ctx: &mut TxContext
): vector<Result> {
    let mut results = vector::empty();
    
    // 事前検証フェーズ
    validate_all_operations(&operations);
    
    // 一括実行フェーズ
    let i = 0;
    while (i < operations.length()) {
        let result = execute_operation(market, &operations[i], ctx);
        results.push_back(result);
        i = i + 1;
    };
    
    results
}
```

### **状態キャッシング**
```move
/// 計算結果のキャッシュ
public struct ComputationCache has store {
    last_update: u64,
    cached_values: Table<vector<u8>, u64>,
}

public fun get_cached_computation(
    cache: &mut ComputationCache,
    input: vector<u8>,
    compute_fn: |vector<u8>| -> u64,
    ttl_ms: u64,
    current_time: u64
): u64 {
    if (cache.cached_values.contains(input) && 
        current_time - cache.last_update < ttl_ms) {
        return *cache.cached_values.borrow(input)
    };
    
    let result = compute_fn(input);
    cache.cached_values.add(input, result);
    cache.last_update = current_time;
    result
}
```

---

**次**: [デプロイメント手順](./11-deployment-guide.md)