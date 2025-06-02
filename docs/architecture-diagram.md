# BUMP.WIN アーキテクチャ構造図

## 主要構造体の関係

```mermaid
classDiagram
    class BattleRound {
        +UID id
        +u64 round_number
        +RoundPhase phase
        +u64 start_timestamp_ms
        +u64 registration_end_ms
        +u64 daytime_end_ms
        +u64 darknight_end_ms
        +Table~TypeName, MemeMetadata~ meme_registry
        +u64 participant_count
        +u64 total_liquidity
        +Option~TypeName~ winner
        +Table~address, BattleAccount~ accounts
        +u64 time_offset_ms
        +bool is_demo_mode
    }

    class BattleAccount {
        +UID id
        +address owner
        +u64 round_id
        +Balance~WSUI~ wsui_balance
        +Table~TypeName, Balance~BattleToken~~ share_coins
        +Option~SealedTransaction~ pending_sealed_tx
        +u8 current_batch
        +u64 batch_start_ms
        +vector~Investment~ investment_history
        +SettlementData settlement_data
    }

    class BattleVault {
        +UID id
        +Balance~WSUI~ wsui_reserve
        +ObjectBag supply_bag
        +u64 num_outcomes
        +u128 total_shares
        +u64 round_id
    }

    class TokenSupply {
        +UID id
        +Supply~BattleToken~ supply
    }

    class Investment {
        +TypeName coin_type
        +u64 wsui_amount
        +u64 shares_received
        +u64 timestamp_ms
        +u8 transaction_type
    }

    class SettlementData {
        +u64 total_wsui_invested
        +Table~TypeName, u64~ final_share_values
        +u64 claimable_amount
        +bool is_settled
    }

    class WSUIVault {
        +UID id
        +Balance~SUI~ sui_reserve
        +Supply~WSUI~ wsui_supply
    }

    class ChampionAMM {
        +UID id
        +Balance~WinnerCoin~ winner_reserve
        +Balance~WSUI~ wsui_reserve
    }

    class SettlementPool {
        +UID id
        +Balance~WSUI~ claimable_wsui
        +Table~address, u64~ claim_amounts
    }

    BattleRound "1" *-- "*" BattleAccount : accounts管理
    BattleAccount "1" *-- "*" Investment : 投資履歴
    BattleAccount "1" *-- "1" SettlementData : 清算データ
    BattleVault "1" *-- "*" TokenSupply : supply_bag内
    BattleRound "1" ..> "1" BattleVault : 使用
    BattleAccount ..> BattleVault : Buy/Switch実行
    WSUIVault ..> BattleAccount : WSUI供給
    BattleRound ..> ChampionAMM : 勝者決定後作成
    BattleRound ..> SettlementPool : 清算用作成
```

## データフロー図

```mermaid
flowchart TB
    User([ユーザー])

    subgraph "準備フェーズ"
        WSUIVault[WSUI Vault]
        SUI[SUI Coin]
    end

    subgraph "Battle Round"
        BR[BattleRound]
        BA[BattleAccount]
        BV[BattleVault/Decision Market]
    end

    subgraph "DarkNight/SBA"
        ST[SealedTransaction]
        TLE[TLE暗号化]
    end

    subgraph "清算フェーズ"
        CAMM[ChampionAMM]
        SP[SettlementPool]
        LOSER[LOSERトークン]
    end

    %% 準備フロー
    User -->|1. SUI預入| WSUIVault
    WSUIVault -->|2. WSUI発行| User

    %% Battle参加
    User -->|3. WSUI入金| BA
    BA -->|4. Buy注文| BV
    BV -->|5. Share発行| BA

    %% SBA (DarkNight)
    User -->|6. Sealed Tx作成| TLE
    TLE -->|7. 暗号化Tx| ST
    ST -->|8. 提出| BA
    BA -->|9. バッチ実行| BV

    %% 清算
    BR -->|10. 勝者決定| CAMM
    BR -->|11. 清算Pool| SP
    BA -->|12. Share精算| SP
    SP -->|13. WSUI分配| User
    BA -->|14. 敗者補償| LOSER
```

## 時系列状態遷移

```mermaid
stateDiagram-v2
    [*] --> Registration: ラウンド開始

    Registration --> Daytime: 3日後
    state Registration {
        [*] --> MemeRegister
        MemeRegister --> CommunityBuild
        CommunityBuild --> InitialInvest
    }

    Daytime --> DarkNight: 24時間後
    state Daytime {
        [*] --> OpenTrading
        OpenTrading --> PriceDiscovery
        PriceDiscovery --> MarketMaking
    }

    DarkNight --> Settlement: 1時間後
    state DarkNight {
        [*] --> Batch1
        Batch1 --> Batch2: 12分
        Batch2 --> Batch3: 12分
        Batch3 --> Batch4: 12分
        Batch4 --> Batch5: 12分
        Batch5 --> [*]: 価格確定

        state Batch1 {
            WSUIDeposit --> SealedTxSubmit
            SealedTxSubmit --> TxReplace
            TxReplace --> BatchExecute
        }
    }

    Settlement --> Complete: 清算完了
    state Settlement {
        [*] --> WinnerDeclare
        WinnerDeclare --> CreateAMM
        CreateAMM --> DistributeRewards
        DistributeRewards --> IssueLOSER
    }

    Complete --> [*]
```

## 核心的な関係性

1. **BattleRound** が全体を統括
   - 複数の **BattleAccount** を管理
   - **BattleVault** (Decision Market) を参照

2. **BattleAccount** が個人資産を管理
   - WSUI残高（SBA期間のみ、全額消費必須）
   - Share実体（BattleTokenのBalance）
   - Sealed取引

3. **BattleVault** が市場メカニズムを実装
   - Brier Score価格計算
   - Share発行管理
   - WSUI準備金保持

4. **清算時の分離**
   - **ChampionAMM**: 勝者の50%流動性
   - **SettlementPool**: 残り50%の分配用
   - **LOSERトークン**: 敗者への補償
