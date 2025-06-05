# デプロイメント手順

## 概要

このドキュメントでは、BUMP.WINプロトコルをSui Testnet/Mainnetにデプロイするためのステップバイステップガイドを提供します。開発環境のセットアップから本番運用まで、完全なデプロイメントプロセスを説明します。

## 前提条件

### **システム要件**
- **OS**: Linux/macOS/WSL2
- **Node.js**: v18以上
- **Rust**: 1.70以上
- **Git**: 2.30以上
- **メモリ**: 8GB以上推奨

### **必要なツール**
```bash
# Sui CLI インストール
cargo install --locked --git https://github.com/MystenLabs/sui.git --branch testnet sui

# Move Analyzer（VS Code拡張）
# VS CodeでMove言語サポートをインストール

# 依存関係確認
sui --version
```

## 開発環境セットアップ

### **1. プロジェクトクローン**
```bash
git clone https://github.com/your-org/bump-win-protocol.git
cd bump-win-protocol

# サブモジュール初期化（TLE実装等）
git submodule update --init --recursive
```

### **2. Sui設定**
```bash
# Sui設定初期化
sui client active-env

# testnet環境追加
sui client new-env --alias testnet --rpc https://fullnode.testnet.sui.io:443

# testnet切り替え
sui client switch --env testnet

# ガス用アドレス作成
sui client new-address ed25519
sui client switch --address [新しいアドレス]

# Testnet Faucetからガス取得
curl --location --request POST 'https://faucet.testnet.sui.io/gas' \
--header 'Content-Type: application/json' \
--data-raw '{
    "FixedAmountRequest": {
        "recipient": "YOUR_ADDRESS"
    }
}'
```

### **3. 依存関係設定**
```bash
cd move-package/

# Move.toml確認・編集
cat Move.toml
```

### **Move.toml 設定例**
```toml
[package]
name = "BattleMarket"
version = "1.0.0"
edition = "2024.beta"

[dependencies]
Sui = { git = "https://github.com/MystenLabs/sui.git", subdir = "crates/sui-framework/packages/sui-framework", rev = "testnet" }

[addresses]
battle_market = "0x0"
sui = "0x2"
std = "0x1"

[dev-dependencies]
[dev-addresses]
battle_market = "0x123"
```

## コンパイルとテスト

### **1. Move パッケージコンパイル**
```bash
# 構文チェック
sui move build

# 詳細チェック
sui move build --dump-bytecode-as-base64

# 依存関係グラフ表示
sui move build --dump-package-digest
```

### **2. 単体テスト実行**
```bash
# 全テスト実行
sui move test

# 特定モジュールテスト
sui move test battle_vault_tests

# テストカバレッジ
sui move test --coverage

# ガス使用量分析
sui move test --gas-limit 1000000
```

### **3. 統合テスト**
```bash
# TypeScript SDKテスト
cd ../ts-sdk/
npm install
npm test

# エンドツーエンドテスト
npm run test:e2e
```

## Testnet デプロイ

### **1. パッケージ公開**
```bash
# Testnetに公開
sui client publish --gas-budget 200000000

# 公開結果確認
# Transaction Hash: 0x...
# Package ID: 0x...

# 公開済みオブジェクト確認
sui client object PACKAGE_ID
```

### **2. 初期化実行**
```bash
# 初期化トランザクション実行
sui client call \
  --package PACKAGE_ID \
  --module init \
  --function init \
  --gas-budget 50000000

# 権限オブジェクト確認
sui client objects --owned-by YOUR_ADDRESS
```

### **3. 設定とテスト**
```bash
# 環境変数設定
export PACKAGE_ID="0x..."
export ADMIN_CAP_ID="0x..."

# 基本機能テスト
cd ../scripts/

# Vault作成テスト
tsx create-test-vault.ts

# コイン登録テスト  
tsx register-test-coins.ts

# 取引テスト
tsx test-trading.ts
```

### **テストスクリプト例**
```typescript
// scripts/create-test-vault.ts
import { SuiClient, getFullnodeUrl } from '@mysten/sui.js/client';
import { Ed25519Keypair } from '@mysten/sui.js/keypairs/ed25519';
import { TransactionBlock } from '@mysten/sui.js/transactions';

const client = new SuiClient({ url: getFullnodeUrl('testnet') });
const keypair = Ed25519Keypair.fromSecretKey(process.env.PRIVATE_KEY!);

async function createTestVault() {
    const tx = new TransactionBlock();
    
    tx.moveCall({
        target: `${process.env.PACKAGE_ID}::battle_vault::create_vault`,
        arguments: [
            tx.object(process.env.ADMIN_CAP_ID!),
            tx.pure(1), // round_id
        ],
    });
    
    const result = await client.signAndExecuteTransactionBlock({
        signer: keypair,
        transactionBlock: tx,
        options: {
            showObjectChanges: true,
            showEffects: true,
        },
    });
    
    console.log('Vault created:', result.digest);
    console.log('Object changes:', result.objectChanges);
}

createTestVault().catch(console.error);
```

## Frontend 統合

### **1. React アプリケーション設定**
```bash
cd ../frontend/

# 依存関係インストール
npm install @mysten/sui.js @mysten/wallet-kit

# 環境設定
cp .env.example .env.local
```

### **.env.local 設定**
```bash
NEXT_PUBLIC_NETWORK=testnet
NEXT_PUBLIC_PACKAGE_ID=0x...
NEXT_PUBLIC_RPC_URL=https://fullnode.testnet.sui.io:443
```

### **2. SDK 統合**
```typescript
// lib/sui-client.ts
import { SuiClient, getFullnodeUrl } from '@mysten/sui.js/client';

export const suiClient = new SuiClient({
    url: getFullnodeUrl(process.env.NEXT_PUBLIC_NETWORK as 'testnet' | 'mainnet')
});

// hooks/useBattleMarket.ts
import { useWallet } from '@mysten/wallet-kit';
import { TransactionBlock } from '@mysten/sui.js/transactions';

export function useBattleMarket() {
    const { currentAccount, signAndExecuteTransactionBlock } = useWallet();
    
    const buyShares = async (coinType: string, amount: string) => {
        if (!currentAccount) throw new Error('Wallet not connected');
        
        const tx = new TransactionBlock();
        
        tx.moveCall({
            target: `${process.env.NEXT_PUBLIC_PACKAGE_ID}::decision_market::buy_shares`,
            typeArguments: [coinType],
            arguments: [
                tx.object(MARKET_ID),
                tx.object(COIN_ID),
                tx.pure(amount),
                tx.object('0x6'), // clock
            ],
        });
        
        return await signAndExecuteTransactionBlock({
            transactionBlock: tx,
            options: { showObjectChanges: true },
        });
    };
    
    return { buyShares };
}
```

## Mainnet デプロイ

### **1. セキュリティ監査**
```bash
# Move Prover実行
sui move prove

# セキュリティチェックリスト確認
# - 整数オーバーフロー対策
# - 権限管理の適切性
# - 再帰呼び出し防止
# - フロントランニング対策
```

### **2. Mainnet 設定**
```bash
# Mainnet環境追加
sui client new-env --alias mainnet --rpc https://fullnode.mainnet.sui.io:443

# Mainnet切り替え
sui client switch --env mainnet

# 本番用ガス準備（実際のSUIが必要）
sui client gas
```

### **3. 本番デプロイ**
```bash
# 最終コンパイル
sui move build --skip-fetch-latest-git-deps

# Mainnetに公開
sui client publish --gas-budget 500000000

# 公開確認
sui client object PACKAGE_ID --json
```

### **4. 設定とモニタリング**
```bash
# 本番設定
export MAINNET_PACKAGE_ID="0x..."
export MAINNET_ADMIN_CAP="0x..."

# 監視設定
# - Transaction監視
# - エラーログ収集
# - パフォーマンス監視
```

## 継続的インテグレーション

### **GitHub Actions 設定**
```yaml
# .github/workflows/ci.yml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Install Sui
        run: |
          cargo install --locked --git https://github.com/MystenLabs/sui.git --branch testnet sui
          
      - name: Build Move Package
        run: |
          cd move-package
          sui move build
          
      - name: Run Move Tests
        run: |
          cd move-package
          sui move test
          
      - name: Test TypeScript SDK
        run: |
          cd ts-sdk
          npm ci
          npm test

  deploy-testnet:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/develop'
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to Testnet
        env:
          SUI_PRIVATE_KEY: ${{ secrets.TESTNET_PRIVATE_KEY }}
        run: |
          cd deploy-scripts
          tsx deploy-testnet.ts

  deploy-mainnet:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to Mainnet
        env:
          SUI_PRIVATE_KEY: ${{ secrets.MAINNET_PRIVATE_KEY }}
        run: |
          cd deploy-scripts
          tsx deploy-mainnet.ts
```

## モニタリングと保守

### **1. ログ監視**
```typescript
// monitoring/transaction-monitor.ts
import { SuiClient } from '@mysten/sui.js/client';

class TransactionMonitor {
    private client: SuiClient;
    
    constructor(rpcUrl: string) {
        this.client = new SuiClient({ url: rpcUrl });
    }
    
    async monitorPackageEvents(packageId: string) {
        const events = await this.client.queryEvents({
            query: {
                MoveModule: {
                    package: packageId,
                    module: 'battle_vault'
                }
            },
            limit: 100,
        });
        
        for (const event of events.data) {
            console.log('Event:', event.type, event.parsedJson);
            
            // エラーイベントの検出
            if (event.type.includes('Error')) {
                await this.alertError(event);
            }
        }
    }
    
    private async alertError(event: any) {
        // Slack/Discord通知等
        console.error('Protocol Error Detected:', event);
    }
}
```

### **2. パフォーマンス監視**
```typescript
// monitoring/performance-monitor.ts
class PerformanceMonitor {
    async checkGasUsage(packageId: string) {
        // 最近のトランザクションのガス使用量分析
        const recentTxs = await this.getRecentTransactions(packageId);
        
        const avgGas = recentTxs.reduce((sum, tx) => 
            sum + tx.effects.gasUsed.computationCost, 0) / recentTxs.length;
            
        if (avgGas > THRESHOLD) {
            await this.alertHighGasUsage(avgGas);
        }
    }
    
    async checkLatency(rpcUrl: string) {
        const start = Date.now();
        await fetch(rpcUrl, {
            method: 'POST',
            body: JSON.stringify({
                jsonrpc: '2.0',
                method: 'sui_getLatestSuiSystemState',
                params: [],
                id: 1
            })
        });
        const latency = Date.now() - start;
        
        if (latency > 5000) { // 5秒以上
            await this.alertHighLatency(latency);
        }
    }
}
```

## アップグレード手順

### **1. 互換性確認**
```bash
# 互換性テスト
sui move build --dump-bytecode-as-base64 > new-bytecode.txt
diff old-bytecode.txt new-bytecode.txt

# ABIチェック
sui move build --dump-abi
```

### **2. アップグレード実行**
```bash
# アップグレード能力確認
sui client object UPGRADE_CAP_ID

# 新バージョンパッケージ作成
sui client upgrade --package . --upgrade-capability UPGRADE_CAP_ID

# アップグレード確認
sui client object NEW_PACKAGE_ID
```

## トラブルシューティング

### **よくある問題と解決策**

1. **コンパイルエラー**
```bash
# 依存関係更新
sui client create-env --alias latest --rpc https://fullnode.testnet.sui.io:443
sui move build --dump-bytecode-as-base64
```

2. **ガス不足エラー**
```bash
# ガス残高確認
sui client gas
# 追加ガス取得
sui client faucet
```

3. **型エラー**
```bash
# 型チェック
sui move build --dump-bytecode-as-base64
# Move Prover実行
sui move prove
```

### **デバッグツール**
```bash
# トランザクション詳細確認
sui client tx-details TRANSACTION_HASH

# オブジェクト状態確認
sui client object OBJECT_ID --json

# イベント確認
sui client events --package PACKAGE_ID
```

## セキュリティチェックリスト

### **デプロイ前確認事項**
- [ ] 全ての単体テスト通過
- [ ] 統合テスト通過
- [ ] セキュリティ監査実施
- [ ] ガス効率化確認
- [ ] 権限管理適切性確認
- [ ] エラーハンドリング網羅性確認
- [ ] フロントランニング対策確認
- [ ] 整数オーバーフロー対策確認

### **運用中監視事項**
- [ ] Transaction成功率監視
- [ ] ガス使用量監視
- [ ] レスポンス時間監視
- [ ] エラーログ監視
- [ ] セキュリティインシデント監視

---

**完了**: BUMP.WIN統一アーキテクチャドキュメンテーション