# BUMP.WIN Move アーキテクチャ矛盾分析報告書

## 要約

docs/内の全ドキュメントを妥協なく分析した結果、Context7によるSui Move事実確認により、**初期分析で指摘した「Move制約違反」の多くは実装可能**であることが判明しました。しかし、**2つの異なるシステムの混在による一貫性の問題**は依然として存在します。

## 🔍 事実確認後の修正分析

### Context7からの正確な事実

Sui Move ドキュメントから以下の事実が判明：

1. **`has key + store`オブジェクトは他のオブジェクトに格納可能**:
```move
// ✅ 実際には可能（Context7より）
public struct Config has key, store {
    id: UID,
    stores: Storable,
}

public struct MegaConfig has key {
    id: UID,
    config: Config, // ✅ key + store は格納可能
}
```

2. **`has store`は`Balance`格納の要件**:
```move
// ✅ 正しい（Context7より）
public struct Balance<phantom T> has store {
    value: u64,
}
```

### 1. ~~オブジェクト所有権違反~~ → **設計可能**

```move
// ✅ 実際には実装可能（BattleVaultに store を追加すれば）
public struct DecisionMarket has key {
    vault: BattleVault,  // ✅ BattleVault が has key, store なら可能
}
```

**修正案**: BattleVaultに`store`能力を追加すれば実装可能

### 2. ~~トークン定義の致命的エラー~~ → **設計修正で解決**

```move
// ✅ 修正版
public struct Share<phantom CoinT> has store {}  // store のみ

// ✅ これで可能
share_balances: Table<TypeName, Balance<Share<T>>>
```

## 📊 構造体定義の深刻な不一致

### BattleAccount構造体

| ドキュメント | sui_balance型 | share_balances型 | トレイト |
|------------|--------------|----------------|---------|
| architecture-diagram.md | `Balance<WSUI>` | `Table<TypeName, Balance<Share<T>>>` | 不明 |
| battle-round-design.md | `Balance<SUI>` | `Table<TypeName, u64>` | `has key, store` |
| battle-round-manager.md | `Balance<WSUI>` | `Table<TypeName, Balance<Share<CoinT>>>` | `has store` |

**問題点**:
1. **通貨の不一致**: SUI vs WSUI
2. **Share管理方法の根本的違い**: u64（数値）vs Balance（トークン実体）
3. **オブジェクト能力の不一致**: key有無でアクセスパターンが全く異なる

### BattleVault構造体

| ドキュメント | reserve型 | supplies/share管理 | 所有モデル |
|------------|----------|------------------|----------|
| architecture-diagram.md | `Balance<WSUI>` | `ObjectBag supplies` | 共有オブジェクト |
| decision-market.md | `Balance<WSUI>` | `ObjectBag supplies` | Marketに内包 |
| sealed-batch-auction.md | `Balance<WSUI>` | `ObjectBag share_supplies` | 移管可能（❌不可能） |

## 🔄 実装不可能なオブジェクトライフサイクル

### 提案されている移管フロー（実装不可能）

```
1. DecisionMarket { vault: BattleVault } ← Daytime
2. destroy_decision_market() → BattleVault を取り出す ❌
3. DarkPool { vault: BattleVault } ← DarkNight
4. destroy_darkpool() → BattleVault を返却 ❌
```

**代替案が必要**: IDベースの参照、または共有オブジェクトパターン

## 🌀 循環依存地獄

```
BattleRoundManager
    ↓ uses
DecisionMarket ←→ BattleVault
    ↓ transfers to           ↑ transfers back
SealedBatchAuction ─────────┘
    ↓ creates
SettlementEngine
```

Moveのパッケージシステムでは、このような循環依存は解決不可能です。

## 🎭 2つの非互換システムの存在

### システムA（Battle Round中心）
- **中心構造体**: BattleRound + BattleAccount
- **通貨**: SUI直接使用
- **Share管理**: u64で数値管理
- **清算**: SettlementPool → SUI直接分配
- **ドキュメント**: battle-round-design.md, battle-round-manager.md

### システムB（Market/Vault中心）
- **中心構造体**: DecisionMarket + DarkPool + SettlementEngine
- **通貨**: WSUI使用
- **Share管理**: Balance<Share<T>>でトークン管理
- **清算**: ChampCoin変換 → ClaimableVault
- **ドキュメント**: decision-market.md, sealed-batch-auction.md, sunrise-settlement.md

**これらは根本的に異なるアーキテクチャであり、統合は不可能です。**

## 🔍 関数シグネチャの完全な不一致

### buy_shares関数の例

```move
// Version 1 (decision-market.md)
public fun buy_shares<T>(
    market: &mut Market,
    payment: Coin<WSUI>,
    ctx: &mut TxContext
): Coin<Share<T>>

// Version 2 (battle-round-manager.md)
public fun buy_shares<T>(
    manager: &mut BattleRoundManager,
    market: &mut Market,
    payment: Coin<WSUI>,
    clock: &Clock,
    ctx: &mut TxContext
): Coin<Share<T>>

// Version 3 (battle-round-design.md)
public fun buy_shares_via_account<CoinT>(
    round: &mut BattleRound,
    vault: &mut BattleVault,
    user: address,
    sui_amount: u64,  // Coinではない！
    ctx: &mut TxContext
)  // 返り値なし！
```

## 💸 経済モデルの矛盾

### WSUI準備金の分配

**battle-round-design.md**:
- 50%: ChampionAMM
- 50%: SettlementPool（勝者への直接分配）

**sunrise-settlement.md**:
- 100%: Champions Market（AMM）
- 0%: 直接WSUI分配なし（ChampCoinのみ配布）

### 価値の流れ

**システムA**: SUI → Share → SUI（直接返却）
**システムB**: SUI → WSUI → Share → ChampCoin → AMM価格

## 📝 型システムの崩壊

### Share<T>の定義混乱

```move
// 場所によって異なる定義
Share<T>           // generic
Share<CoinT>       // phantom generic
Share<WinnerCoin>  // concrete type

// トレイトも不一致
has drop          // Balance不可
has store         // Balance可能
has key, store    // 共有オブジェクト可能
```

### ChampCoin設計の矛盾

```move
// 提案された定義
public struct ChampCoin<phantom T> has drop {}

// しかし使用箇所
champ_reserve: Balance<ChampCoin<T>>  // ❌ has dropはBalance不可
```

## 🚫 実装阻害要因まとめ

### レベル1: Move言語違反（修正必須）
1. `has key`オブジェクトの直接所有 ❌
2. `has drop`トークンのBalance格納 ❌
3. 循環依存パッケージ構造 ❌

### レベル2: アーキテクチャ対立（選択必須）
1. システムA vs システムB
2. SUI vs WSUI
3. 数値管理 vs トークン管理

### レベル3: 詳細設計不足（補完必須）
1. Vault移管の代替メカニズム
2. エラーハンドリング
3. アップグレード戦略

## 🎯 修正された結論と推奨事項

### 現状評価
**Context7による事実確認の結果、Move制約違反の多くは解決可能です。主要な問題は2つのシステムの設計不統一です。**

### 実装可能な修正
1. **BattleVault**: `has key, store`に修正 → オブジェクト格納可能
2. **Share<T>**: `has store`のみに修正 → Balance格納可能  
3. **循環依存**: モジュール設計の再構成で解決可能

### 残る真の問題
1. **システム選択**: システムA（BattleRound中心）かシステムB（Market中心）
2. **データ管理方式**: u64数値管理 vs Balance<T>トークン管理
3. **通貨統一**: SUI vs WSUI の一貫性

### 推奨アプローチ
1. システムB（Market中心）ベースで統一
2. 能力（abilities）の適切な設定
3. 型システムの一貫性確保
4. 統一されたインターフェース設計

**修正された分析の結果、適切な能力設定により実装可能と判断します。**
