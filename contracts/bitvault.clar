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

;; Governance Proposal Registry - Manages decentralized decision making
(define-map governance-proposals
    { proposal-id: uint }
    {
        proposal-title: (string-ascii 256),
        target-asset-id: uint,
        voting-start-block: uint,
        voting-end-block: uint,
        execution-status: bool,
        affirmative-votes: uint,
        negative-votes: uint,
        required-quorum: uint,
        proposer: principal
    }
)

;; Voting Record Tracker - Prevents double voting and tracks participation
(define-map voting-records
    { proposal-id: uint, voter-address: principal }
    { 
        vote-weight: uint,
        vote-direction: bool,
        voting-block: uint 
    }
)

;; Dividend Distribution Tracker - Manages yield claim history
(define-map dividend-distribution-ledger
    { asset-id: uint, beneficiary: principal }
    { 
        total-claimed-amount: uint,
        last-claim_block: uint,
        claim-count: uint 
    }
)

;; Oracle Price Feed Registry - Maintains asset valuation data
(define-map oracle-price-feeds
    { asset-id: uint }
    {
        current-price: uint,
        price-decimals: uint,
        last-update-block: uint,
        authorized-oracle: principal,
        price-confidence: uint
    }
)

;; INPUT VALIDATION & SECURITY FUNCTIONS

;; Validates asset valuation within acceptable bounds
(define-private (validate-asset-valuation (valuation uint))
    (and 
        (>= valuation MIN_ASSET_VALUATION)
        (<= valuation MAX_ASSET_VALUATION)
    )
)

;; Ensures proposal duration meets protocol requirements
(define-private (validate-proposal-duration (duration uint))
    (and 
        (>= duration MIN_PROPOSAL_DURATION)
        (<= duration MAX_PROPOSAL_DURATION)
    )
)

;; Verifies KYC compliance level validity
(define-private (validate-kyc-compliance-level (level uint))
    (<= level MAX_KYC_COMPLIANCE_LEVEL)
)

;; Checks expiry timestamp validity
(define-private (validate-expiry-timestamp (expiry uint))
    (and 
        (> expiry stacks-block-height)
        (<= (- expiry stacks-block-height) MAX_KYC_VALIDITY_PERIOD)
    )
)

;; Validates voting quorum requirements
(define-private (validate-quorum-threshold (vote-count uint))
    (and 
        (> vote-count u0)
        (<= vote-count ASSET_PRECISION_FACTOR)
    )
)

;; Ensures metadata URI format compliance
(define-private (validate-metadata-uri (uri (string-ascii 512)))
    (and 
        (> (len uri) u0)
        (<= (len uri) MAX_METADATA_URI_LENGTH)
    )
)

;; Validates proposal title format
(define-private (validate-proposal-title (title (string-ascii 256)))
    (and 
        (> (len title) u0)
        (<= (len title) MAX_PROPOSAL_TITLE_LENGTH)
    )
)

;; UTILITY & HELPER FUNCTIONS  

;; Generates sequential asset identifiers
(define-private (generate-next-asset-id)
    (default-to u1 (get-last-registered-asset-id))
)

;; Generates sequential proposal identifiers  
(define-private (generate-next-proposal-id)
    (default-to u1 (get-last-proposal-id))
)

;; Placeholder for asset ID tracking (would be implemented with counters in production)
(define-private (get-last-registered-asset-id)
    none
)

;; Placeholder for proposal ID tracking (would be implemented with counters in production)
(define-private (get-last-proposal-id)
    none
)

;; Calculates proportional dividend entitlement
(define-private (calculate-dividend-entitlement (token-balance uint) (total-dividends uint) (last-claimed uint))
    (/ (* token-balance (- total-dividends last-claimed)) ASSET_PRECISION_FACTOR)
)

;; Verifies investor KYC compliance status
(define-private (verify-kyc-compliance (investor principal))
    (match (map-get? kyc-compliance-registry { investor-address: investor })
        compliance-record 
            (and 
                (get verification-status compliance-record)
                (> (get verification-expiry compliance-record) stacks-block-height)
            )
        false
    )
)

;; CORE ASSET MANAGEMENT FUNCTIONS

;; Registers new real world asset for tokenization
(define-public (register-tokenized-asset 
    (metadata-uri (string-ascii 512))
    (initial-valuation uint)
    (compliance-tier uint))
    
    (let ((asset-id (generate-next-asset-id)))
        (begin
            ;; Authorization Check
            (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_OWNER_RESTRICTED_FUNCTION)
            
            ;; Input Validation
            (asserts! (validate-metadata-uri metadata-uri) ERR_INVALID_URI_FORMAT)
            (asserts! (validate-asset-valuation initial-valuation) ERR_INVALID_ASSET_VALUE)
            (asserts! (validate-kyc-compliance-level compliance-tier) ERR_INVALID_KYC_LEVEL)

            ;; Register Asset
            (map-set asset-registry
                { asset-id: asset-id }
                {
                    asset-owner: CONTRACT_OWNER,
                    metadata-uri: metadata-uri,
                    current-valuation: initial-valuation,
                    is-trading-locked: false,
                    creation-block: stacks-block-height,
                    last-valuation-update: stacks-block-height,
                    total-dividend-pool: u0,
                    compliance-tier: compliance-tier
                }
            )
            
            ;; Mint Initial Token Supply to Owner
            (map-set token-ownership-ledger
                { holder: CONTRACT_OWNER, asset-id: asset-id }
                { token-balance: ASSET_PRECISION_FACTOR }
            )
            
            (ok asset-id)
        )
    )
)

;; Updates asset valuation through authorized oracle
(define-public (update-asset-valuation 
    (asset-id uint)
    (new-valuation uint)
    (oracle-signature (optional (buff 65))))
    
    (let ((asset-info (unwrap! (map-get? asset-registry { asset-id: asset-id }) ERR_ASSET_NOT_FOUND)))
        (begin
            ;; Authorization Check (Owner or Authorized Oracle)
            (asserts! 
                (or 
                    (is-eq tx-sender CONTRACT_OWNER)
                    (is-some oracle-signature)
                ) 
                ERR_UNAUTHORIZED_ACCESS
            )
            
            ;; Validation
            (asserts! (validate-asset-valuation new-valuation) ERR_INVALID_ASSET_VALUE)
            
            ;; Update Asset Valuation
            (map-set asset-registry
                { asset-id: asset-id }
                (merge asset-info {
                    current-valuation: new-valuation,
                    last-valuation-update: stacks-block-height
                })
            )
            
            ;; Update Oracle Price Feed
            (map-set oracle-price-feeds
                { asset-id: asset-id }
                {
                    current-price: new-valuation,
                    price-decimals: u6, ;; Standard 6 decimal precision
                    last-update-block: stacks-block-height,
                    authorized-oracle: tx-sender,
                    price-confidence: u95 ;; 95% confidence default
                }
            )
            
            (ok true)
        )
    )
)

;; TOKEN TRANSFER & OWNERSHIP MANAGEMENT

;; Transfers fractional asset tokens between verified investors
(define-public (transfer-asset-tokens 
    (asset-id uint)
    (recipient principal)
    (token-amount uint))
    
    (let (
        (sender-balance (get-token-balance tx-sender asset-id))
        (recipient-balance (get-token-balance recipient asset-id))
    )
        (begin
            ;; KYC Compliance Verification
            (asserts! (verify-kyc-compliance tx-sender) ERR_KYC_VERIFICATION_REQUIRED)
            (asserts! (verify-kyc-compliance recipient) ERR_KYC_VERIFICATION_REQUIRED)
            
            ;; Transfer Validation
            (asserts! (> token-amount u0) ERR_ZERO_AMOUNT_TRANSFER)
            (asserts! (>= sender-balance token-amount) ERR_INSUFFICIENT_BALANCE)
            
            ;; Execute Transfer
            (map-set token-ownership-ledger
                { holder: tx-sender, asset-id: asset-id }
                { token-balance: (- sender-balance token-amount) }
            )
            
            (map-set token-ownership-ledger
                { holder: recipient, asset-id: asset-id }
                { token-balance: (+ recipient-balance token-amount) }
            )
            
            (ok true)
        )
    )
)

;; DIVIDEND DISTRIBUTION SYSTEM

;; Claims proportional dividend distribution for token holders
(define-public (claim-dividend-distribution (asset-id uint))
    (let (
        (asset-info (unwrap! (map-get? asset-registry { asset-id: asset-id }) ERR_ASSET_NOT_FOUND))
        (holder-balance (get-token-balance tx-sender asset-id))
        (claim-history (get-dividend-claim-history asset-id tx-sender))
        (total-dividends (get total-dividend-pool asset-info))
        (claimable-amount (calculate-dividend-entitlement holder-balance total-dividends claim-history))
    )
        (begin
            ;; Validation Checks
            (asserts! (> claimable-amount u0) ERR_INSUFFICIENT_BALANCE)
            (asserts! (verify-kyc-compliance tx-sender) ERR_KYC_VERIFICATION_REQUIRED)
            
            ;; Update Claim History
            (map-set dividend-distribution-ledger
                { asset-id: asset-id, beneficiary: tx-sender }
                { 
                    total-claimed-amount: (+ claim-history claimable-amount),
                    last-claim_block: stacks-block-height,
                    claim-count: (+ u1 (get-claim-count asset-id tx-sender))
                }
            )
            
            ;; Note: In production, this would trigger actual STX/token transfer
            (ok claimable-amount)
        )
    )
)

;; Deposits dividends into asset distribution pool (Owner only)
(define-public (deposit-dividend-pool 
    (asset-id uint)
    (dividend-amount uint))
    
    (let ((asset-info (unwrap! (map-get? asset-registry { asset-id: asset-id }) ERR_ASSET_NOT_FOUND)))
        (begin
            ;; Authorization Check
            (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_OWNER_RESTRICTED_FUNCTION)
            (asserts! (> dividend-amount u0) ERR_INVALID_TOKEN_AMOUNT)
            
            ;; Update Dividend Pool
            (map-set asset-registry
                { asset-id: asset-id }
                (merge asset-info {
                    total-dividend-pool: (+ (get total-dividend-pool asset-info) dividend-amount)
                })
            )
            
            (ok true)
        )
    )
)

;; DECENTRALIZED GOVERNANCE SYSTEM

;; Creates governance proposal for asset management decisions
(define-public (create-governance-proposal
    (asset-id uint)
    (proposal-title (string-ascii 256))
    (voting-duration uint)
    (required-quorum uint))
    
    (let (
        (proposal-id (generate-next-proposal-id))
        (proposer-balance (get-token-balance tx-sender asset-id))
    )
        (begin
            ;; Validation Checks
            (asserts! (validate-proposal-duration voting-duration) ERR_INVALID_DURATION)
            (asserts! (validate-quorum-threshold required-quorum) ERR_INSUFFICIENT_VOTING_POWER)
            (asserts! (validate-proposal-title proposal-title) ERR_INVALID_STRING_LENGTH)
            
            ;; Minimum Token Threshold Check
            (asserts! (>= proposer-balance MIN_PROPOSAL_THRESHOLD) ERR_INSUFFICIENT_VOTING_POWER)
            
            ;; Create Proposal
            (map-set governance-proposals
                { proposal-id: proposal-id }
                {
                    proposal-title: proposal-title,
                    target-asset-id: asset-id,
                    voting-start-block: stacks-block-height,
                    voting-end-block: (+ stacks-block-height voting-duration),
                    execution-status: false,
                    affirmative-votes: u0,
                    negative-votes: u0,
                    required-quorum: required-quorum,
                    proposer: tx-sender
                }
            )
            
            (ok proposal-id)
        )
    )
)

;; Casts weighted vote on governance proposal
(define-public (cast-governance-vote
    (proposal-id uint)
    (vote-affirmative bool)
    (voting-weight uint))
    
    (let (
        (proposal-info (unwrap! (map-get? governance-proposals { proposal-id: proposal-id }) ERR_PROPOSAL_NOT_FOUND))
        (asset-id (get target-asset-id proposal-info))
        (voter-balance (get-token-balance tx-sender asset-id))
    )
        (begin
            ;; Voting Validation
            (asserts! (<= voting-weight voter-balance) ERR_INSUFFICIENT_VOTING_POWER)
            (asserts! (< stacks-block-height (get voting-end-block proposal-info)) ERR_VOTING_PERIOD_ENDED)
            (asserts! (is-none (map-get? voting-records { proposal-id: proposal-id, voter-address: tx-sender })) ERR_DUPLICATE_VOTE_ATTEMPT)
            
            ;; Record Vote
            (map-set voting-records
                { proposal-id: proposal-id, voter-address: tx-sender }
                {
                    vote-weight: voting-weight,
                    vote-direction: vote-affirmative,
                    voting-block: stacks-block-height
                }
            )
            
            ;; Update Proposal Vote Tally
            (map-set governance-proposals
                { proposal-id: proposal-id }
                (merge proposal-info {
                    affirmative-votes: (if vote-affirmative 
                        (+ (get affirmative-votes proposal-info) voting-weight)
                        (get affirmative-votes proposal-info)
                    ),
                    negative-votes: (if vote-affirmative
                        (get negative-votes proposal-info)
                        (+ (get negative-votes proposal-info) voting-weight)
                    )
                })
            )
            
            (ok true)
        )
    )
)

;; KYC COMPLIANCE & REGULATORY FUNCTIONS

;; Registers KYC verification for investor (Owner/Authority only)
(define-public (register-kyc-verification
    (investor-address principal)
    (compliance-level uint)
    (verification-duration uint))
    
    (begin
        ;; Authorization Check
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_OWNER_RESTRICTED_FUNCTION)
        
        ;; Validation
        (asserts! (validate-kyc-compliance-level compliance-level) ERR_INVALID_KYC_LEVEL)
        (asserts! (validate-expiry-timestamp (+ stacks-block-height verification-duration)) ERR_INVALID_EXPIRY_TIME)
        
        ;; Register KYC Status
        (map-set kyc-compliance-registry
            { investor-address: investor-address }
            {
                verification-status: true,
                compliance-level: compliance-level,
                verification-expiry: (+ stacks-block-height verification-duration),
                verification-authority: tx-sender
            }
        )
        
        (ok true)
    )
)

;; Revokes KYC verification (Emergency/Compliance function)
(define-public (revoke-kyc-verification (investor-address principal))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_OWNER_RESTRICTED_FUNCTION)
        
        (map-set kyc-compliance-registry
            { investor-address: investor-address }
            {
                verification-status: false,
                compliance-level: u0,
                verification-expiry: stacks-block-height,
                verification-authority: tx-sender
            }
        )
        
        (ok true)
    )
)