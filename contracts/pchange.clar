;; Perpetual Exchange Contract - Phase 3
;; Adds funding rate, advanced orders, and enhanced trading mechanics

;; Constants from previous phases
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

;; New constants for funding and orders
(define-constant FUNDING_INTERVAL u6) ;; Blocks between funding
(define-constant MAX_PREMIUM_RATE u10) ;; 0.1% max premium
(define-constant ORDER_EXPIRY_BLOCKS u144) ;; 24 hours in blocks
(define-constant PRICE_IMPACT_LIMIT u20) ;; 0.2% max price impact

;; Order types
(define-constant ORDER_TYPE_MARKET u1)
(define-constant ORDER_TYPE_LIMIT u2)
(define-constant ORDER_TYPE_STOP_LOSS u3)
(define-constant ORDER_TYPE_TAKE_PROFIT u4)

;; Helper Functions
(define-private (get-absolute-int (value int))
    (if (< value 0)
        (* value -1)
        value))

;; New clamp function implementation
(define-private (clamp-int (value int) (min-val int) (max-val int))
    (if (< value min-val)
        min-val
        (if (> value max-val)
            max-val
            value)))

;; Enhanced market structure
(define-map markets 
    {asset-pair: (string-ascii 10)} 
    {
        liquidity: uint,
        last-price: uint,
        funding-rate: int,
        leverage-max: uint,
        maintenance-margin: uint,
        liquidation-count: uint,
        last-funding-time: uint,
        premium-index: int,
        target-price: uint,
        volume-24h: uint
    }
)

;; Advanced order structure
(define-map orders
    {order-id: uint, trader: principal}
    {
        asset-pair: (string-ascii 10),
        order-type: uint,
        size: int,
        price: uint,
        collateral: uint,
        leverage: uint,
        expiry: uint,
        trigger-price: (optional uint),
        is-active: bool
    }
)

;; Order book tracking
(define-map order-book
    {asset-pair: (string-ascii 10), price-level: uint}
    {
        total-size: int,
        order-count: uint
    }
)

;; Counter for order IDs
(define-data-var next-order-id uint u0)

;; Calculate funding rate
(define-private (calculate-funding-rate (market-data {
        liquidity: uint,
        last-price: uint,
        funding-rate: int,
        leverage-max: uint,
        maintenance-margin: uint,
        liquidation-count: uint,
        last-funding-time: uint,
        premium-index: int,
        target-price: uint,
        volume-24h: uint
    }))
    (let (
        (price-delta (to-int (- (get last-price market-data) (get target-price market-data))))
        (base-rate (/ (* price-delta 100) (to-int (get target-price market-data))))
        (max-rate (to-int MAX_PREMIUM_RATE))
        (min-rate (* -1 max-rate))
        (capped-rate (clamp-int base-rate min-rate max-rate))
    )
        (+ capped-rate (get premium-index market-data))
    )
)

;; Update funding payments
(define-public (update-funding (asset-pair (string-ascii 10)))
    (let ((market (unwrap! (map-get? markets {asset-pair: asset-pair}) ERR_INVALID_PARAMS)))
        (asserts! (>= block-height (+ (get last-funding-time market) FUNDING_INTERVAL)) ERR_INVALID_PARAMS)
        
        (let ((new-funding-rate (calculate-funding-rate market)))
            (ok (map-set markets
                {asset-pair: asset-pair}
                (merge market {
                    funding-rate: new-funding-rate,
                    last-funding-time: block-height
                })))
        )
    )
)

;; Create advanced order
(define-public (create-order (
        asset-pair (string-ascii 10))
        (order-type uint)
        (size int)
        (price uint)
        (collateral uint)
        (leverage uint)
        (trigger-price (optional uint)))
    (let (
        (market (unwrap! (map-get? markets {asset-pair: asset-pair}) ERR_INVALID_PARAMS))
        (order-id (var-get next-order-id))
    )
        ;; Validate order parameters
        (asserts! (> size 0) ERR_INVALID_PARAMS)
        (asserts! (> price u0) ERR_INVALID_PARAMS)
        (asserts! (<= leverage (get leverage-max market)) ERR_INVALID_PARAMS)
        
        ;; Check price impact
        (asserts! (< (get-absolute-int (to-int (- price (get last-price market)))) 
                    (to-int (/ (* (get last-price market) PRICE_IMPACT_LIMIT) u10000)))
                 ERR_PRICE_OUT_OF_RANGE)
        
        ;; Create order
        (map-set orders
            {order-id: order-id, trader: tx-sender}
            {
                asset-pair: asset-pair,
                order-type: order-type,
                size: size,
                price: price,
                collateral: collateral,
                leverage: leverage,
                expiry: (+ block-height ORDER_EXPIRY_BLOCKS),
                trigger-price: trigger-price,
                is-active: true
            }
        )
        
        ;; Update order book
        (let ((current-level (default-to 
                {total-size: 0, order-count: u0}
                (map-get? order-book {asset-pair: asset-pair, price-level: price}))))
            (map-set order-book
                {asset-pair: asset-pair, price-level: price}
                {
                    total-size: (+ (get total-size current-level) size),
                    order-count: (+ (get order-count current-level) u1)
                }
            )
        )
        
        ;; Increment order ID
        (var-set next-order-id (+ order-id u1))
        (ok order-id)
    )
)

;; Rest of the contract functions remain the same...

;; Get order details
(define-read-only (get-order (order-id uint) (trader principal))
    (ok (map-get? orders {order-id: order-id, trader: trader}))
)

;; Get order book for price level
(define-read-only (get-order-book-level (asset-pair (string-ascii 10)) (price-level uint))
    (ok (map-get? order-book {asset-pair: asset-pair, price-level: price-level}))
)