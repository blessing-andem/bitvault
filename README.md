# BitVault - Bitcoin-Native Real World Asset Protocol

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Clarity](https://img.shields.io/badge/Clarity-v3-orange.svg)](https://clarity-lang.org/)
[![Stacks](https://img.shields.io/badge/Stacks-2.1+-purple.svg)](https://stacks.org/)
[![Tests](https://img.shields.io/badge/Tests-Vitest-green.svg)](https://vitest.dev/)

## Overview

BitVault is a sophisticated tokenization infrastructure that leverages Bitcoin's unparalleled security through Stacks Layer 2 for institutional-grade real world asset (RWA) management. The protocol enables fractionalized ownership, automated yield distribution, and decentralized governance mechanisms for high-value traditional assets.

### Key Features

- **🔒 Bitcoin-Secured**: Built on Stacks L2, inheriting Bitcoin's security model
- **🏗️ Asset Tokenization**: Convert real estate, commodities, art, and infrastructure into digital tokens
- **⚖️ Fractionalized Ownership**: Precision-engineered semi-fungible tokens enabling fractional investment
- **💰 Automated Dividends**: Proportional yield distribution to token holders
- **🗳️ Decentralized Governance**: Token-weighted voting on asset management decisions
- **✅ Enterprise Compliance**: Built-in KYC/AML frameworks and regulatory compliance
- **📊 Oracle Integration**: Real-time asset valuations through trusted price feeds
- **🔐 Institutional Security**: Multi-signature custody and enterprise-grade security standards

## Architecture

### Core Components

1. **Asset Registry**: Manages tokenized real world assets with comprehensive metadata
2. **Token Ledger**: Tracks fractional ownership and balance management
3. **Compliance Engine**: Handles KYC/AML verification and regulatory requirements
4. **Governance System**: Facilitates decentralized decision-making processes
5. **Dividend Distribution**: Automates proportional yield payments to token holders
6. **Oracle Network**: Provides real-time asset valuations and price feeds

### Technical Specifications

- **Smart Contract Language**: Clarity (Version 3)
- **Blockchain**: Stacks Layer 2
- **Settlement Layer**: Bitcoin
- **Token Standard**: Semi-Fungible Tokens (SFTs)
- **Precision**: 100,000 tokens per asset for micro-fractional ownership
- **Governance**: Token-weighted voting with configurable quorum requirements

## Protocol Parameters

| Parameter | Value | Description |
|-----------|--------|-------------|
| Max Asset Valuation | $1 Trillion USD | Maximum supported asset value |
| Min Asset Valuation | $10,000 USD | Minimum asset threshold |
| Token Precision | 100,000 | Tokens per asset for fractional precision |
| Max Proposal Duration | ~60 days | Maximum voting period |
| Min Proposal Duration | ~1 day | Minimum voting period |
| Quorum Requirement | 20% | Minimum participation for valid proposals |
| KYC Validity | ~1 year | Maximum KYC verification period |

## Smart Contract Functions

### Asset Management

#### `register-tokenized-asset`

```clarity
(register-tokenized-asset (metadata-uri (string-ascii 512)) (initial-valuation uint) (compliance-tier uint))
```

Registers a new real world asset for tokenization (Owner only).

#### `update-asset-valuation`

```clarity
(update-asset-valuation (asset-id uint) (new-valuation uint) (oracle-signature (optional (buff 65))))
```

Updates asset valuation through authorized oracles.

### Token Operations

#### `transfer-asset-tokens`

```clarity
(transfer-asset-tokens (asset-id uint) (recipient principal) (token-amount uint))
```

Transfers fractional asset tokens between KYC-verified investors.

#### `get-token-balance`

```clarity
(get-token-balance (holder principal) (asset-id uint))
```

Retrieves token balance for a specific holder and asset.

### Dividend System

#### `claim-dividend-distribution`

```clarity
(claim-dividend-distribution (asset-id uint))
```

Claims proportional dividend distribution based on token holdings.

#### `deposit-dividend-pool`

```clarity
(deposit-dividend-pool (asset-id uint) (dividend-amount uint))
```

Deposits dividends into asset distribution pool (Owner only).

### Governance

#### `create-governance-proposal`

```clarity
(create-governance-proposal (asset-id uint) (proposal-title (string-ascii 256)) (voting-duration uint) (required-quorum uint))
```

Creates governance proposals for asset management decisions.

#### `cast-governance-vote`

```clarity
(cast-governance-vote (proposal-id uint) (vote-affirmative bool) (voting-weight uint))
```

Casts weighted votes on governance proposals.

### Compliance

#### `register-kyc-verification`

```clarity
(register-kyc-verification (investor-address principal) (compliance-level uint) (verification-duration uint))
```

Registers KYC verification for investors (Authority only).

#### `get-kyc-status`

```clarity
(get-kyc-status (investor-address principal))
```

Retrieves KYC compliance status for an investor.

## Error Codes

| Code Range | Category | Description |
|------------|----------|-------------|
| 100-199 | Authorization | Access control and permission errors |
| 200-299 | Asset Management | Asset-related operation errors |
| 300-399 | Token Operations | Balance and transfer errors |
| 400-499 | Compliance | KYC and regulatory compliance errors |
| 500-599 | Governance | Voting and proposal errors |
| 600-699 | Oracle | Price feed and data errors |
| 700-799 | Validation | Input validation errors |

## Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Clarity development environment
- [Node.js](https://nodejs.org/) (v16 or higher)
- [Stacks Wallet](https://wallet.hiro.so/) - For testnet interactions

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/blessing-andem/bitvault.git
   cd bitvault
   ```

2. **Install dependencies**

   ```bash
   npm install
   ```

3. **Check contract syntax**

   ```bash
   clarinet check
   ```

4. **Run tests**

   ```bash
   npm test
   ```

### Development Setup

1. **Start Clarinet console**

   ```bash
   clarinet console
   ```

2. **Deploy to devnet**

   ```bash
   clarinet integrate
   ```

3. **Run test suite with coverage**

   ```bash
   npm run test:report
   ```

4. **Watch mode for development**

   ```bash
   npm run test:watch
   ```

## Testing

The protocol includes comprehensive test coverage using Vitest and Clarinet SDK:

```bash
# Run all tests
npm test

# Run tests with coverage report
npm run test:report

# Run tests in watch mode
npm run test:watch
```

### Test Categories

- **Unit Tests**: Individual function testing
- **Integration Tests**: Multi-contract interactions
- **Compliance Tests**: KYC and regulatory workflows
- **Governance Tests**: Voting and proposal mechanisms
- **Security Tests**: Authorization and access control

## Security Considerations

### Access Control

- **Owner Functions**: Critical operations restricted to contract owner
- **KYC Requirements**: All token transfers require valid KYC verification
- **Oracle Security**: Price updates require authorized oracle signatures
- **Governance Thresholds**: Minimum token holdings required for proposals

### Compliance Features

- **KYC/AML Integration**: Built-in investor verification system
- **Regulatory Tiers**: Multiple compliance levels for different jurisdictions
- **Audit Trail**: Complete on-chain transaction history
- **Emergency Controls**: Owner can revoke KYC status if required

### Best Practices

- Input validation on all public functions
- Overflow protection with safe arithmetic
- Reentrancy protection through proper state management
- Time-based access controls for governance

## Protocol Governance

### Proposal Process

1. **Creation**: Token holders with minimum threshold can create proposals
2. **Voting Period**: Configurable duration (1-60 days)
3. **Quorum**: Minimum 20% participation required
4. **Execution**: Successful proposals automatically execute

### Voting Mechanism

- **Token-Weighted**: Vote power proportional to token holdings
- **One-Time Voting**: Prevents double voting per proposal
- **Transparent**: All votes recorded on-chain
- **Deadline Enforcement**: Votes must be cast within voting period

## Oracle Integration

### Price Feeds

- Real-time asset valuations
- Configurable confidence levels
- Staleness protection (24-hour threshold)
- Authorized oracle network

### Supported Data

- Asset current market value
- Historical price trends
- Confidence metrics
- Last update timestamps

## Roadmap

### Phase 1 (Current)

- ✅ Core tokenization infrastructure
- ✅ Fractionalized ownership system
- ✅ Basic governance mechanisms
- ✅ KYC compliance framework

### Phase 2 (Q2 2025)

- 🔄 Multi-oracle price aggregation
- 🔄 Advanced governance features
- 🔄 Cross-chain bridge integration
- 🔄 Institutional custody partnerships

### Phase 3 (Q3 2025)

- 📋 Mobile application
- 📋 Advanced analytics dashboard
- 📋 Automated compliance reporting
- 📋 Integration with traditional finance

### Phase 4 (Q4 2025)

- 📋 Global expansion
- 📋 Regulatory approvals
- 📋 Institutional-grade features
- 📋 DeFi protocol integrations

## Contributing

We welcome contributions from the community! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Process

1. Fork the repository
2. Create a feature branch
3. Implement changes with tests
4. Submit a pull request
5. Code review and approval

### Code Standards

- Follow Clarity best practices
- Maintain test coverage >90%
- Include comprehensive documentation
- Use semantic commit messages

## Security Audits

BitVault undergoes regular security audits by leading blockchain security firms:

- **Audit Firm**: [Pending]
- **Last Audit**: [Pending]
- **Next Audit**: [Scheduled Q2 2025]

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
