;; Perpetual Exchange Contract - Initial Version
;; Provides basic perpetual futures trading functionality with BTC collateral

;; Define our own trait for fungible tokens
(define-trait ft-trait
    (
        ;; Transfer from the caller to a new principal
        (transfer (uint principal principal) (response bool uint))
        ;; Get the token balance of owner
        (get-balance (principal) (response uint uint))
        ;; Get the total number of tokens
        (get-total-supply () (response uint uint))
        ;; Get the token decimals
        (get-decimals () (response uint uint))
        ;; Get the token URI
        (get-token-uri () (response (optional (string-utf8 256)) uint))
        ;; Get the token name
        (get-name () (response (string-ascii 32) uint))
        ;; Get the token symbol
        (get-symbol () (response (string-ascii 32) uint))
    )
)

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u1001))
(define-constant ERR_INVALID_PARAMS (err u1002))
(define-constant ERR_INSUFFICIENT_BALANCE (err u1003))
(define-constant DEFAULT_MAINTENANCE_MARGIN u5)

;; Helper Functions
(define-private (get-absolute-int (value int))
    (if (< value 0)
        (* value -1)
        value))

;; Data structures
(define-map markets 
    {asset-pair: (string-ascii 10)} 
    {
        liquidity: uint,
        last-price: uint,
        funding-rate: int,
        leverage-max: uint,
        maintenance-margin: uint
    }
)

(define-map positions 
    {trader: principal, asset-pair: (string-ascii 10)} 
    {
        size: int,
        entry-price: uint,
        collateral: uint,
        leverage: uint,
        last-funding-time: uint
    }
)

;; Initialize a new perpetual market
(define-public (create-perp-market 
    (asset-pair (string-ascii 10)) 
    (initial-liquidity uint)
    (max-leverage uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (> initial-liquidity u0) ERR_INVALID_PARAMS)
        (asserts! (> max-leverage u0) ERR_INVALID_PARAMS)
        
        (ok (map-set markets 
            {asset-pair: asset-pair}
            {
                liquidity: initial-liquidity,
                last-price: u0,
                funding-rate: 0,
                leverage-max: max-leverage,
                maintenance-margin: DEFAULT_MAINTENANCE_MARGIN
            }))
    )
)

;; Open a new position
(define-public (open-position (asset-pair (string-ascii 10)) 
                            (size int)
                            (collateral uint)
                            (leverage uint))
    (let ((market (unwrap! (map-get? markets {asset-pair: asset-pair}) ERR_INVALID_PARAMS))
          (current-position (default-to 
                            {
                                size: 0,
                                entry-price: u0,
                                collateral: u0,
                                leverage: u0,
                                last-funding-time: u0
                            }
                            (map-get? positions {trader: tx-sender, asset-pair: asset-pair})))
          (position-size-abs (get-absolute-int size)))
        
        (asserts! (<= leverage (get leverage-max market)) ERR_INVALID_PARAMS)
        (asserts! (>= collateral (/ (* (to-uint position-size-abs) (get last-price market)) leverage)) 
                 ERR_INSUFFICIENT_BALANCE)
        
        (ok (map-set positions
            {trader: tx-sender, asset-pair: asset-pair}
            {
                size: (+ size (get size current-position)),
                entry-price: (get last-price market),
                collateral: (+ collateral (get collateral current-position)),
                leverage: leverage,
                last-funding-time: block-height
            }))
    )
)

;; Get position details
(define-read-only (get-position (trader principal) (asset-pair (string-ascii 10)))
    (ok (map-get? positions {trader: trader, asset-pair: asset-pair}))
)

;; Get market details
(define-read-only (get-market (asset-pair (string-ascii 10)))
    (ok (map-get? markets {asset-pair: asset-pair}))
)

;; Update price feed (only authorized oracle)
(define-public (update-price (asset-pair (string-ascii 10)) (new-price uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (let ((market (unwrap! (map-get? markets {asset-pair: asset-pair}) ERR_INVALID_PARAMS)))
            (ok (map-set markets 
                {asset-pair: asset-pair}
                (merge market {last-price: new-price})))
        )
    )
)