# バトルラウンド管理設計

## 概要

バトルラウンド管理は、BUMP.WINの競争的ミームコイントーナメントの中核オーケストレーションシステムです。各ラウンドは、複数のミームコインが生存をかけて競い合い、勝者のみが全流動性を獲得する完全なバトルサイクルを表します。

## ラウンドライフサイクル

### フェーズ構造

```
登録期間(3日) → 日中戦闘(24時間) → 深夜決戦(1時間) → 決済 → 次ラウンド
```

### 1. 登録フェーズ (72時間)

- **コイン登録**: ミーム作成者がバトル用コインを提出
- **コミュニティ構築**: 早期サポーター向けインサイダー優位期間
- **初期流動性**: シード資金と早期ポジション取得
- **最大参加者数**: 最大10,000の競争ミームコイン

### 2. 日中フェーズ (24時間)

- **オープン取引**: 登録済み全コインが予測市場で取引可能
- **価格発見**: Brier Score Dual SCPMが勝率を決定
- **コミュニティ参加**: 有料チャットが市場センチメントに影響
- **動的淘汰**: 最弱パフォーマーが段階的にフィルタリング

### 3. 深夜フェーズ (1時間、5バッチ × 12分)

- **封印バッチオークション**: Time-Locked Encryptionが操作を防止
- **秘匿オークション**: 5バッチの封印取引で最終価格決定
- **最終決定**: 数学的勝者選出
- **Sui TLE統合**: 暗号学的公平性保証

### 4. 決済フェーズ

- **勝者宣言**: 単一コインが勝利
- **流動性移転**: 全SUI準備金がチャンピオンに流入
- **敗者補償**: LOSERトークンが淘汰ホルダーに分配
- **チャンピオンAMM**: 勝者が自動マーケットメーカーをデプロイ

## 状態管理アーキテクチャ

### ラウンド状態オブジェクト

```move
public struct BattleRound has key, store {
    id: UID,
    round_number: u64,
    phase: RoundPhase,
    start_timestamp_ms: u64,
    registration_end_ms: u64,
    daytime_end_ms: u64,
    darknight_end_ms: u64,
    meme_registry: Table<TypeName, MemeMetadata>,
    participant_count: u64,
    total_liquidity: u64,
    winner: Option<TypeName>,
    // Account管理
    accounts: Table<address, BattleAccount>,
    // デモ用時間操作
    time_offset_ms: u64,
    is_demo_mode: bool,
}
```

### アカウント管理システム

```move
public struct BattleAccount has key, store {
    id: UID,
    owner: address,
    round_id: u64,
    /// SUI残高（未投資分）
    sui_balance: Balance<SUI>,
    /// 各ミームコインのシェア保有量
    share_balances: Table<TypeName, u64>,
    /// 投資履歴
    investment_history: vector<Investment>,
    /// 清算用データ
    settlement_data: SettlementData,
}

public struct Investment has store, drop {
    coin_type: TypeName,
    sui_amount: u64,
    shares_received: u64,
    timestamp_ms: u64,
    transaction_type: u8, // 0: Buy, 1: Switch
}

public struct SettlementData has store, drop {
    total_sui_invested: u64,
    final_share_values: Table<TypeName, u64>,
    claimable_amount: u64,
    is_settled: bool,
}
```

### フェーズ遷移

```move
public enum RoundPhase has copy, drop {
    Registration,
    Daytime,
    DarkNight { batch: u8, batch_start_ms: u64 },
    Settlement,
    Complete,
}
```

## 淘汰メカニズム

### 市場力学による自然選択

1. **Brier Score価格設定**: 価格が真の確率を反映する数学的保証
2. **流動性集中**: 投資が認知された勝者に流れる
3. **価格ベースランキング**: 市場評価に基づくリアルタイムリーダーボード
4. **閾値淘汰**: 各バッチで下位パーセンタイルコインを除去

### 深夜バッチシステム (Sealed Batch Auction)

```
バッチ1 (0-12分):   Buy/Switch取引秘匿化 → 一括執行
バッチ2 (12-24分):  Buy/Switch取引秘匿化 → 一括執行
バッチ3 (24-36分):  Buy/Switch取引秘匿化 → 一括執行
バッチ4 (36-48分):  Buy/Switch取引秘匿化 → 一括執行
バッチ5 (48-60分):  Buy/Switch取引秘匿化 → 一括執行 → 最終価格決定
```

**メカニズム:**

- **秘匿取引**: 各バッチで取引をTLEで暗号化
- **バッチ実行**: 12分後に全取引を同時実行
- **価格更新**: バッチ処理後に新価格反映
- **最終決定**: 5バッチ後の最高価格コインが勝者

## 勝者決定アルゴリズム

### 最終選出基準

1. **最高時価総額**: 総SUI投資による主要ランキング
2. **一貫パフォーマンス**: 日中を通じて持続的高価格
3. **コミュニティサポート**: ボリュームと参加度メトリクス
4. **数学的検証**: Brier Score確率検証

### 決済プロセス

```move
public fun declare_winner<WinnerCoin>(
    round: &mut BattleRound,
    vault: BattleVault,
    clock: &Clock,
    ctx: &mut TxContext,
): (ChampionAMM<WinnerCoin>, SettlementPool) {
    // ラウンド完了検証
    assert!(round.phase == RoundPhase::Settlement);

    // 勝者の総準備金抽出
    let winner_reserves = extract_winner_liquidity<WinnerCoin>(&vault);

    // 全アカウントの清算データ計算
    calculate_settlement_for_all_accounts<WinnerCoin>(round, &vault);

    // 50%流動性でチャンピオンAMM作成
    let amm_liquidity = winner_reserves / 2;
    let champion_amm = create_champion_amm<WinnerCoin>(amm_liquidity, ctx);

    // 残り50%を個人清算用プール作成
    let claim_liquidity = winner_reserves - amm_liquidity;
    let settlement_pool = create_settlement_pool(claim_liquidity, round, ctx);

    // ラウンド完了マーク
    round.phase = RoundPhase::Complete;
    round.winner = option::some(type_name::get<WinnerCoin>());

    (champion_amm, settlement_pool)
}

/// 個人アカウント清算関数
public fun settle_account(
    round: &mut BattleRound,
    settlement_pool: &mut SettlementPool,
    account_owner: address,
    ctx: &mut TxContext,
): (Coin<SUI>, vector<Coin<LoserToken>>) {
    let account = round.accounts.borrow_mut(account_owner);
    assert!(!account.settlement_data.is_settled, E_ALREADY_SETTLED);

    // 勝者シェア保有者への報酬計算
    let winner_payout = calculate_winner_payout(account, round.winner);
    let sui_payout = settlement_pool.withdraw_sui(winner_payout);

    // 敗者への LOSER トークン発行
    let loser_tokens = mint_loser_tokens_for_account(account, round);

    // アカウント清算完了マーク
    account.settlement_data.is_settled = true;

    // 未投資SUI残高 + 勝者報酬
    let sui_balance = account.sui_balance.withdraw_all();
    sui_balance.join(sui_payout);

    (sui_balance.into_coin(ctx), loser_tokens)
}
```

### アカウント操作関数

```move
/// アカウント作成または取得
public fun get_or_create_account(
    round: &mut BattleRound,
    user: address,
    ctx: &mut TxContext,
): &mut BattleAccount {
    if (!round.accounts.contains(user)) {
        let account = BattleAccount {
            id: object::new(ctx),
            owner: user,
            round_id: round.round_number,
            sui_balance: balance::zero(),
            share_balances: table::new(ctx),
            investment_history: vector::empty(),
            settlement_data: SettlementData {
                total_sui_invested: 0,
                final_share_values: table::new(ctx),
                claimable_amount: 0,
                is_settled: false,
            },
        };
        round.accounts.add(user, account);
    };
    round.accounts.borrow_mut(user)
}

/// SUI入金
public fun deposit_sui(
    round: &mut BattleRound,
    user: address,
    sui_coin: Coin<SUI>,
    ctx: &mut TxContext,
) {
    let account = get_or_create_account(round, user, ctx);
    account.sui_balance.join(sui_coin.into_balance());
}

/// シェア購入（アカウント経由）
public fun buy_shares_via_account<CoinT>(
    round: &mut BattleRound,
    vault: &mut BattleVault,
    user: address,
    sui_amount: u64,
    ctx: &mut TxContext,
) {
    let account = get_or_create_account(round, user, ctx);
    assert!(account.sui_balance.value() >= sui_amount, E_INSUFFICIENT_BALANCE);

    // アカウントからSUI取得
    let sui_payment = account.sui_balance.split(sui_amount);

    // シェア購入
    let shares_coin = vault.buy_shares<CoinT>(sui_payment.into_coin(ctx), ctx);
    let shares_amount = shares_coin.value();

    // シェア残高更新
    let coin_type = type_name::get<CoinT>();
    if (!account.share_balances.contains(coin_type)) {
        account.share_balances.add(coin_type, 0);
    };
    let current_shares = account.share_balances.borrow_mut(coin_type);
    *current_shares = *current_shares + shares_amount;

    // 投資履歴記録
    let investment = Investment {
        coin_type,
        sui_amount,
        shares_received: shares_amount,
        timestamp_ms: clock::timestamp_ms(clock),
        transaction_type: 0, // Buy
    };
    account.investment_history.push_back(investment);

    // シェアコインをバーン（アカウントで管理するため）
    // TODO: 実際の実装では適切にバーン処理
}
```

## 経済モデル

### 勝者総取り

- **100% SUI準備金**: 全バトル流動性が勝者に流入
- **チャンピオンAMM**: 50%が取引ペア流動性になる
- **ホルダー報酬**: 50%が勝者トークンホルダーに分配

### 敗者補償

- **LOSERトークン**: 淘汰参加者への慰労賞
- **ステーキング利回り**: プロトコル手数料100%をLOSERホルダーに分配
- **減少発行**: ラウンド毎に100 LOSERから1 LOSERまで時間経過で減少

### 手数料構造

- **取引手数料**: 全予測市場取引で0.3%
- **決済手数料**: 最終勝者流動性で1%
- **登録手数料**: スパム防止用少額SUI

## 時間管理

### 精密タイミング

```move
const REGISTRATION_DURATION_MS: u64 = 259_200_000; // 3日
const DAYTIME_DURATION_MS: u64 = 86_400_000;       // 24時間
const DARKNIGHT_DURATION_MS: u64 = 3_600_000;      // 1時間
const BATCH_DURATION_MS: u64 = 720_000;            // 12分
```

### クロックベーストリガー

- **自動遷移**: Clockオブジェクトに基づくスマートコントラクトトリガー
- **猶予期間**: トランザクションタイミングを考慮した小さなバッファ
- **緊急停止**: 重要問題用管理者機能

### デモ用時間操作機能

```move
/// デモモードでのタイムオフセット設定（管理者のみ）
public fun set_time_offset(
    round: &mut BattleRound,
    admin_cap: &AdminCap,
    offset_ms: u64,
) {
    assert!(round.is_demo_mode, E_NOT_DEMO_MODE);
    round.time_offset_ms = offset_ms;
}

/// 実効時刻取得（オフセット考慮）
public fun get_effective_time(
    round: &BattleRound,
    clock: &Clock,
): u64 {
    let current_time = clock::timestamp_ms(clock);
    if (round.is_demo_mode) {
        current_time + round.time_offset_ms
    } else {
        current_time
    }
}

/// フェーズ判定（オフセット対応）
public fun get_current_phase(
    round: &BattleRound,
    clock: &Clock,
): RoundPhase {
    let effective_time = get_effective_time(round, clock);

    if (effective_time < round.registration_end_ms) {
        RoundPhase::Registration
    } else if (effective_time < round.daytime_end_ms) {
        RoundPhase::Daytime
    } else if (effective_time < round.darknight_end_ms) {
        // DarkNight内のバッチ判定
        let darknight_elapsed = effective_time - round.daytime_end_ms;
        let batch_number = (darknight_elapsed / BATCH_DURATION_MS) + 1;
        let batch_start = round.daytime_end_ms + ((batch_number - 1) * BATCH_DURATION_MS);

        RoundPhase::DarkNight {
            batch: (batch_number as u8),
            batch_start_ms: batch_start
        }
    } else {
        RoundPhase::Settlement
    }
}

/// デモ用時間早送り
public fun fast_forward_time(
    round: &mut BattleRound,
    admin_cap: &AdminCap,
    forward_ms: u64,
) {
    assert!(round.is_demo_mode, E_NOT_DEMO_MODE);
    round.time_offset_ms = round.time_offset_ms + forward_ms;
}

/// 特定フェーズまでスキップ
public fun skip_to_phase(
    round: &mut BattleRound,
    admin_cap: &AdminCap,
    target_phase: u8, // 0:Registration, 1:Daytime, 2:DarkNight, 3:Settlement
    clock: &Clock,
) {
    assert!(round.is_demo_mode, E_NOT_DEMO_MODE);

    let current_time = clock::timestamp_ms(clock);
    let target_time = if (target_phase == 0) {
        round.start_timestamp_ms
    } else if (target_phase == 1) {
        round.registration_end_ms
    } else if (target_phase == 2) {
        round.daytime_end_ms
    } else if (target_phase == 3) {
        round.darknight_end_ms
    } else {
        abort E_INVALID_PHASE
    };

    if (target_time > current_time) {
        round.time_offset_ms = target_time - current_time;
    };
}
```

### デモモード管理

```move
public struct AdminCap has key, store {
    id: UID,
}

/// デモ用ラウンド作成
public fun create_demo_round(
    admin_cap: &AdminCap,
    ctx: &mut TxContext,
): BattleRound {
    let current_time = clock::timestamp_ms(clock);

    BattleRound {
        id: object::new(ctx),
        round_number: 0, // Demo round
        phase: RoundPhase::Registration,
        start_timestamp_ms: current_time,
        registration_end_ms: current_time + REGISTRATION_DURATION_MS,
        daytime_end_ms: current_time + REGISTRATION_DURATION_MS + DAYTIME_DURATION_MS,
        darknight_end_ms: current_time + REGISTRATION_DURATION_MS + DAYTIME_DURATION_MS + DARKNIGHT_DURATION_MS,
        meme_registry: table::new(ctx),
        participant_count: 0,
        total_liquidity: 0,
        winner: option::none(),
        accounts: table::new(ctx),
        // デモ設定
        time_offset_ms: 0,
        is_demo_mode: true,
    }
}

/// 通常ラウンド作成（プロダクション用）
public fun create_production_round(
    admin_cap: &AdminCap,
    round_number: u64,
    ctx: &mut TxContext,
): BattleRound {
    // ... 同様だが is_demo_mode: false
}
```

## セキュリティ考慮事項

### 攻撃ベクター

1. **フラッシュローン操作**: 時間ロックフェーズで防止
2. **シビル攻撃**: 登録手数料とアイデンティティ要件で軽減
3. **共謀**: 大規模参加者プールで影響を削減
4. **タイミング攻撃**: 決定論的クロックベーストリガーで無効化

### 緩和戦略

1. **マルチバッチ淘汰**: 単一点操作の影響を削減
2. **数学的保証**: Brier Scoreが裁定取引悪用を防止
3. **コミュニティ監視**: 透明なオンチェーン実行
4. **緊急手順**: 重要障害への管理者介入

## 今後の拡張

### 計画機能

1. **動的ラウンド期間**: 参加状況に基づく適応タイミング
2. **マルチラウンドトーナメント**: ブラケット付き季節競技
3. **クロスチェーン統合**: 非Suiミームコインサポート
4. **高度メトリクス**: 洗練された勝者決定アルゴリズム

### 研究領域

1. **MEV保護**: 高度なフロントランニング防止
2. **ガバナンス統合**: ラウンドパラメーターのコミュニティ制御
3. **機械学習**: 最適タイミングの予測モデリング
4. **量子耐性**: 将来対応暗号手法
