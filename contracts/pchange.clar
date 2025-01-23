;; Perpetual Exchange Contract - Phase 4

;; Define trait for fungible tokens
(define-trait ft-trait
    (
        (transfer (uint principal principal (optional (buff 34))) (response bool uint))
    )
)

;; Error Codes
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u1001))
(define-constant ERR_INVALID_PARAMS (err u1002))
(define-constant ERR_INSUFFICIENT_BALANCE (err u1003))
(define-constant ERR_POSITION_NOT_FOUND (err u1004))
(define-constant ERR_ALREADY_LIQUIDATED (err u1005))
(define-constant ERR_HEALTHY_POSITION (err u1006))
(define-constant ERR_INVALID_ORDER (err u1007))
(define-constant ERR_ORDER_NOT_FOUND (err u1008))
(define-constant ERR_PRICE_OUT_OF_RANGE (err u1009))
(define-constant ERR_INVALID_PROPOSAL (err u1010))
(define-constant ERR_PROPOSAL_EXPIRED (err u1011))
(define-constant ERR_ALREADY_VOTED (err u1012))
(define-constant ERR_INSUFFICIENT_STAKE (err u1013))
(define-constant ERR_INSURANCE_FUND_LOW (err u1014))
(define-constant ERR_ALREADY_REGISTERED (err u1015))

;; Constants
(define-constant PROPOSAL_DURATION u1008)
(define-constant MIN_PROPOSAL_STAKE u1000000)
(define-constant VOTE_THRESHOLD u6000)
(define-constant INSURANCE_FUND_TARGET u1000000000)
(define-constant MARKET_MAKER_MIN_STAKE u100000)
(define-constant MIN_ORDERS_REQUIRED u4)
(define-constant MAX_SPREAD_ALLOWED u500)
(define-constant MM_STATUS_ACTIVE u1)
(define-constant MM_STATUS_INACTIVE u0)

;; Data Variables
(define-data-var next-proposal-id uint u0)
(define-data-var max-leverage uint u20)
(define-data-var maintenance-margin uint u5)
(define-data-var liquidation-threshold uint u75)
(define-data-var funding-interval uint u6)

;; Market Makers Map
(define-map market-makers
    principal
    {
        total-volume: uint,
        active-orders: uint,
        quote-quality: uint,
        last-update: uint,
        stake-amount: uint,
        rewards-accumulated: uint,
        min-spread: uint,
        performance-score: uint,
        status: uint
    }
)

;; Market Maker Registration
(define-public (register-market-maker (stake-amount uint) (token <ft-trait>))
    (let (
        (existing-mm (map-get? market-makers tx-sender))
    )
        (asserts! (is-none existing-mm) ERR_ALREADY_REGISTERED)
        (asserts! (>= stake-amount MARKET_MAKER_MIN_STAKE) ERR_INSUFFICIENT_STAKE)
        
        (try! (contract-call? token transfer 
            stake-amount
            tx-sender
            (as-contract tx-sender)
            none))
        
        (ok (map-set market-makers
            tx-sender
            {
                total-volume: u0,
                active-orders: u0,
                quote-quality: u100,
                last-update: block-height,
                stake-amount: stake-amount,
                rewards-accumulated: u0,
                min-spread: MAX_SPREAD_ALLOWED,
                performance-score: u0,
                status: MM_STATUS_ACTIVE
            }))
    ))

;; Helper Functions
(define-private (calculate-performance (orders uint) (spread uint) (volume uint))
    (let (
        (order-score (if (>= orders MIN_ORDERS_REQUIRED) u50 u0))
        (spread-score (if (<= spread MAX_SPREAD_ALLOWED) u30 u0))
        (volume-score (if (> volume u0) u20 u0))
    )
        (+ order-score (+ spread-score volume-score))
    ))

;; Update Market Maker Metrics
(define-public (update-market-maker-metrics 
    (maker principal) 
    (orders uint)
    (spread uint)
    (new-volume uint))
    
    (let (
        (mm-data (unwrap! (map-get? market-makers maker) ERR_INVALID_PARAMS))
    )
        (asserts! (or (is-eq tx-sender maker) 
                     (is-eq tx-sender CONTRACT_OWNER)) 
                 ERR_UNAUTHORIZED)
        
        (ok (map-set market-makers
            maker
            {
                total-volume: (+ (get total-volume mm-data) new-volume),
                active-orders: orders,
                quote-quality: u100,
                last-update: block-height,
                stake-amount: (get stake-amount mm-data),
                rewards-accumulated: (get rewards-accumulated mm-data),
                min-spread: (if (< spread (get min-spread mm-data))
                              spread
                              (get min-spread mm-data)),
                performance-score: (calculate-performance 
                                   orders
                                   spread
                                   new-volume),
                status: (get status mm-data)
            }))
    ))

;; Read Functions
(define-read-only (get-market-maker (maker principal))
    (ok (map-get? market-makers maker)))

(define-read-only (get-market-maker-status (maker principal))
    (match (map-get? market-makers maker)
        mm-data (ok (get status mm-data))
        ERR_INVALID_PARAMS))

(define-read-only (is-active-market-maker (maker principal))
    (match (map-get? market-makers maker)
        mm-data (ok (is-eq (get status mm-data) MM_STATUS_ACTIVE))
        ERR_INVALID_PARAMS))

;; Update Market Maker Status
(define-public (update-market-maker-status (maker principal) (new-status uint))
    (let (
        (mm-data (unwrap! (map-get? market-makers maker) ERR_INVALID_PARAMS))
    )
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (or (is-eq new-status MM_STATUS_ACTIVE)
                     (is-eq new-status MM_STATUS_INACTIVE))
                 ERR_INVALID_PARAMS)
        
        (ok (map-set market-makers
            maker
            (merge mm-data {status: new-status})))
    ))