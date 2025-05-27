# BUMPWIN - Next-Gen Prediction Market on Sui

> Bump. Survive. Win.

![npm](https://img.shields.io/npm/v/bumpwin)

## Overview

BUMPWIN is a sophisticated DeFi protocol suite on Sui blockchain, featuring advanced prediction markets and token swap capabilities. Built with cutting-edge market maker algorithms and comprehensive safety features.

## Key Features

### 🎯 Battle Market - Advanced Prediction Market
- **Brier Score Dual SCPM**: Sophisticated scoring rule market maker for multi-outcome predictions
- **Price Normalization**: All outcome prices automatically sum to 1
- **Bounded Loss Guarantee**: Market maker's maximum loss is predictable and controlled
- **Multi-outcome Support**: Trade on multiple mutually exclusive outcomes simultaneously

### 💱 Champ Market - Efficient Token Swaps
- **Constant Product AMM**: Classic x*y=k formula for reliable price discovery
- **Low Slippage Trading**: Optimized for efficient token swaps
- **Event-driven Architecture**: Real-time swap tracking and analytics
- **Composable Liquidity**: Seamlessly integrate with other DeFi protocols

### 💬 On-chain Chat System
- **Decentralized Messaging**: Fully on-chain chat with Walrus integration
- **Event Emissions**: Real-time updates for seamless UX
- **Modular Architecture**: Easy integration with existing dApps

### 🛡️ Safety First
- **SafeMath Library**: Comprehensive overflow/underflow protection with i32 support
- **Capability-based Access Control**: Secure admin functions
- **Battle-tested**: Extensive test coverage across all modules

## Technical Architecture

```
packages/
├── battle_market/     # Core prediction market AMM
├── champ_market/      # NFT-based champion trading
├── justchat/          # Decentralized chat system
├── mockcoins/         # Test token framework
└── safemath/          # Safe arithmetic operations

ts-sdk/                # TypeScript SDK for seamless integration
```

## Quick Start

```bash
# Install SDK
npm add bumpwin

# Example usage
import { battleMarket, champMarket } from 'bumpwin';

// Trade on prediction markets
const tx = await battleMarket.buyShares({
  marketId: "0x123...",
  outcomeIndex: 0,  // Buy shares for outcome 0
  amount: 1000000   // 1 SUI
});

// Swap tokens via Champ Market
await champMarket.swapXtoY({
  poolId: "0x456...",
  amountIn: 5000000  // 5 tokens
});
```

## Live on Testnet

- Battle Market: `0x80ded5c56a6375c887fd4357487bd7d725712694b3b4b994d224b1ff23565364`
- Champ Market: `0x271c2fd30fd48ed9cf5b9bb903ccfbe19398becb2cab3c65026149a6a4a956b4`
- JustChat: `0x366ffbcaf9c51db02857ff81141702f114f3b5675dd960be74f3c5f34e2ba3c3`

## Why BUMPWIN?

- **Sui-Native**: Built from ground up for Sui's object-centric model
- **Modular Design**: Each component works independently or together
- **Developer Friendly**: Comprehensive TypeScript SDK with type safety
- **Production Ready**: Deployed and tested on testnet

## Roadmap

- [x] Core AMM implementation
- [x] On-chain chat system
- [x] TypeScript SDK
- [x] Testnet deployment
- [ ] Mainnet launch
- [ ] Mobile app
- [ ] Cross-chain bridges

## Contributing

We welcome contributions! Check out our packages for areas to contribute:
- Smart contract development (Move)
- SDK improvements (TypeScript)
- Documentation and examples

## License

MIT

---

Built with ❤️ for the Sui ecosystem
