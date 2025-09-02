;; Title: BitVault - Bitcoin-Native Real World Asset Protocol
;;
;; Summary: 
;; A sophisticated tokenization infrastructure leveraging Bitcoin's security through Stacks L2
;; for institutional-grade real world asset management with fractionalized ownership, automated
;; yield distribution, and decentralized governance mechanisms.
;;
;; Description:
;; BitVault transforms traditional asset ownership by creating Bitcoin-secured digital representations
;; of real world assets through Stacks smart contracts. The protocol enables institutional and retail
;; investors to access fractionalized ownership of high-value assets including real estate, commodities,
;; art, and infrastructure projects. Each asset is tokenized into precision-engineered semi-fungible
;; tokens with built-in compliance frameworks, oracle-driven valuations, and sophisticated governance
;; structures. Token holders benefit from proportional dividend distributions, voting rights on asset
;; management decisions, and the unprecedented security of Bitcoin's settlement layer. The platform
;; incorporates enterprise-grade KYC/AML compliance, multi-signature custody solutions, and transparent
;; on-chain governance, making traditional asset investment accessible while maintaining regulatory
;; compliance and institutional security standards.

;; ADMINISTRATIVE CONSTANTS & CONFIGURATION

(define-constant CONTRACT_OWNER tx-sender)

;; ERROR CODE REGISTRY

;; Core Authorization Errors
(define-constant ERR_UNAUTHORIZED_ACCESS (err u100))
(define-constant ERR_OWNER_RESTRICTED_FUNCTION (err u101))
(define-constant ERR_INSUFFICIENT_PERMISSIONS (err u102))

;; Asset Management Errors  
(define-constant ERR_ASSET_NOT_FOUND (err u200))
(define-constant ERR_ASSET_ALREADY_EXISTS (err u201))
(define-constant ERR_ASSET_LOCKED (err u202))
(define-constant ERR_INVALID_ASSET_VALUE (err u203))
(define-constant ERR_ASSET_EXPIRED (err u204))

;; Token & Balance Errors
(define-constant ERR_INSUFFICIENT_BALANCE (err u300))
(define-constant ERR_INVALID_TOKEN_AMOUNT (err u301))
(define-constant ERR_TRANSFER_FAILED (err u302))
(define-constant ERR_ZERO_AMOUNT_TRANSFER (err u303))

;; Compliance & KYC Errors
(define-constant ERR_KYC_VERIFICATION_REQUIRED (err u400))
(define-constant ERR_KYC_EXPIRED (err u401))
(define-constant ERR_INVALID_KYC_LEVEL (err u402))
(define-constant ERR_COMPLIANCE_VIOLATION (err u403))

;; Governance & Voting Errors
(define-constant ERR_PROPOSAL_NOT_FOUND (err u500))
(define-constant ERR_VOTING_PERIOD_ENDED (err u501))
(define-constant ERR_DUPLICATE_VOTE_ATTEMPT (err u502))
(define-constant ERR_PROPOSAL_EXECUTION_FAILED (err u503))
(define-constant ERR_INSUFFICIENT_VOTING_POWER (err u504))

;; Oracle & Pricing Errors
(define-constant ERR_PRICE_FEED_STALE (err u600))
(define-constant ERR_ORACLE_UNAUTHORIZED (err u601))
(define-constant ERR_INVALID_PRICE_DATA (err u602))

;; Input Validation Errors
(define-constant ERR_INVALID_URI_FORMAT (err u700))
(define-constant ERR_INVALID_DURATION (err u701))
(define-constant ERR_INVALID_EXPIRY_TIME (err u702))
(define-constant ERR_INVALID_ADDRESS_FORMAT (err u703))
(define-constant ERR_INVALID_STRING_LENGTH (err u704))

;; PROTOCOL CONFIGURATION PARAMETERS

;; Asset Valuation Limits
(define-constant MAX_ASSET_VALUATION u1000000000000) ;; $1 Trillion USD equivalent
(define-constant MIN_ASSET_VALUATION u10000)         ;; $10,000 USD minimum threshold
(define-constant ASSET_PRECISION_FACTOR u100000)     ;; 100k tokens per asset for precision

;; Temporal Constraints
(define-constant MAX_PROPOSAL_DURATION u8640)        ;; ~60 days maximum voting period
(define-constant MIN_PROPOSAL_DURATION u144)         ;; ~1 day minimum voting period  
(define-constant MAX_KYC_VALIDITY_PERIOD u52560)     ;; ~1 year KYC expiration
(define-constant ORACLE_STALENESS_THRESHOLD u144)    ;; ~1 day price staleness limit

;; Governance Parameters
(define-constant MIN_PROPOSAL_THRESHOLD u10000)      ;; 10% of tokens required to create proposal
(define-constant QUORUM_REQUIREMENT u20000)          ;; 20% participation for valid proposal
(define-constant MAX_KYC_COMPLIANCE_LEVEL u5)        ;; Highest KYC verification tier

;; String & Data Limits
(define-constant MAX_METADATA_URI_LENGTH u512)       ;; Extended URI support
(define-constant MAX_PROPOSAL_TITLE_LENGTH u256)     ;; Proposal title character limit

;; CORE DATA STRUCTURES & STORAGE MAPS

;; Primary Asset Registry - Stores comprehensive asset information
(define-map asset-registry
    { asset-id: uint }
    {
        asset-owner: principal,
        metadata-uri: (string-ascii 512),
        current-valuation: uint,
        is-trading-locked: bool,
        creation-block: uint,
        last-valuation-update: uint,
        total-dividend-pool: uint,
        compliance-tier: uint
    }
)

;; Token Balance Ledger - Tracks fractional ownership
(define-map token-ownership-ledger
    { holder: principal, asset-id: uint }
    { token-balance: uint }
)

;; KYC Compliance Registry - Manages investor verification status
(define-map kyc-compliance-registry
    { investor-address: principal }
    {
        verification-status: bool,
        compliance-level: uint,
        verification-expiry: uint,
        verification-authority: principal
    }
)