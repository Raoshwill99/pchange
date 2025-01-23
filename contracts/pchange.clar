;; Perpetual Exchange Contract - Phase 2
;; Adds liquidation mechanics and enhanced risk management

;; Define trait for fungible tokens
(define-trait ft-trait
    (
        (transfer (uint principal principal) (response bool uint))
        (get-balance (principal) (response uint uint))
        (get-total-supply () (response uint uint))
        (get-decimals () (response uint uint))
        (get-token-uri () (response (optional (string-utf8 256)) uint))
        (get-name () (response (string-ascii 32) uint))
        (get-symbol () (response (string-ascii 32) uint))
    )
)

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u1001))
(define-constant ERR_INVALID_PARAMS (err u1002))
(define-constant ERR_INSUFFICIENT_BALANCE (err u1003))
(define-constant ERR_POSITION_NOT_FOUND (err u1004))
(define-constant ERR_ALREADY_LIQUIDATED (err u1005))
(define-constant ERR_HEALTHY_POSITION (err u1006))
(define-constant DEFAULT_MAINTENANCE_MARGIN u5)
(define-constant LIQUIDATION_PENALTY u10)  ;; 10% penalty on liquidation
(define-constant MINIMUM_COLLATERAL u100)  ;; Minimum collateral required

;; Helper Functions
(define-private (get-absolute-int (value int))
    (if (< value 0)
        (* value -1)
        value))

;; New helper for calculating position value
(define-private (calculate-position-value (size int) (current-price uint))
    (* (to-uint (get-absolute-int size)) current-price))

;; New helper for calculating liquidation price
(define-private (calculate-liquidation-price (position-size int) 
                                           (collateral uint)
                                           (maintenance-margin uint))
    (let ((abs-size (to-uint (get-absolute-int position-size))))
        (if (is-eq abs-size u0)
            u0
            (/ (* collateral maintenance-margin) abs-size))))

;; Data structures
(define-map markets 
    {asset-pair: (string-ascii 10)} 
    {
        liquidity: uint,
        last-price: uint,
        funding-rate: int,
        leverage-max: uint,
        maintenance-margin: uint,
        liquidation-count: uint  ;; New field to track liquidations
    }
)

(define-map positions 
    {trader: principal, asset-pair: (string-ascii 10)} 
    {
        size: int,
        entry-price: uint,
        collateral: uint,
        leverage: uint,
        last-funding-time: uint,
        liquidation-price: uint,  ;; New field
        is-liquidated: bool       ;; New field
    }
)

;; New map for liquidation statistics
(define-map liquidation-stats
    principal
    {
        total-liquidations: uint,
        total-penalty-paid: uint
    }
)

;; Enhanced check for position health
(define-private (is-position-healthy (position {size: int, 
                                              entry-price: uint, 
                                              collateral: uint, 
                                              leverage: uint,
                                              last-funding-time: uint,
                                              liquidation-price: uint,
                                              is-liquidated: bool})
                                    (current-price uint)
                                    (maintenance-margin uint))
    (let ((position-value (calculate-position-value (get size position) current-price)))
        (>= (get collateral position) 
            (/ (* position-value maintenance-margin) u100))))

;; Liquidation function
(define-public (liquidate-position (trader principal) 
                                 (asset-pair (string-ascii 10)))
    (let ((position (unwrap! (map-get? positions {trader: trader, asset-pair: asset-pair}) 
                            ERR_POSITION_NOT_FOUND))
          (market (unwrap! (map-get? markets {asset-pair: asset-pair}) 
                          ERR_INVALID_PARAMS)))
        
        ;; Check if position can be liquidated
        (asserts! (not (get is-liquidated position)) ERR_ALREADY_LIQUIDATED)
        (asserts! (not (is-position-healthy position 
                                          (get last-price market)
                                          (get maintenance-margin market)))
                 ERR_HEALTHY_POSITION)
        
        ;; Calculate liquidation penalty
        (let ((penalty (/ (* (get collateral position) LIQUIDATION_PENALTY) u100))
              (remaining-collateral (- (get collateral position) penalty)))
            
            ;; Update position as liquidated
            (map-set positions
                {trader: trader, asset-pair: asset-pair}
                (merge position 
                      {
                          size: 0,
                          collateral: u0,
                          is-liquidated: true
                      }))
            
            ;; Update market liquidation count
            (map-set markets
                {asset-pair: asset-pair}
                (merge market 
                      {
                          liquidation-count: (+ (get liquidation-count market) u1)
                      }))
            
            ;; Update liquidation statistics
            (map-set liquidation-stats
                trader
                (merge (default-to 
                        {total-liquidations: u0, total-penalty-paid: u0}
                        (map-get? liquidation-stats trader))
                      {
                          total-liquidations: (+ u1 (get total-liquidations 
                            (default-to {total-liquidations: u0, total-penalty-paid: u0} 
                                      (map-get? liquidation-stats trader)))),
                          total-penalty-paid: (+ penalty (get total-penalty-paid
                            (default-to {total-liquidations: u0, total-penalty-paid: u0}
                                      (map-get? liquidation-stats trader))))
                      }))
            
            ;; Return success with liquidation details
            (ok {
                penalty: penalty,
                remaining-collateral: remaining-collateral
            })
        )
    ))

;; Enhanced open position function with liquidation price calculation
(define-public (open-position (asset-pair (string-ascii 10)) 
                            (size int)
                            (collateral uint)
                            (leverage uint))
    (let ((market (unwrap! (map-get? markets {asset-pair: asset-pair}) ERR_INVALID_PARAMS))
          (position-size-abs (get-absolute-int size)))
        
        ;; Enhanced validation
        (asserts! (<= leverage (get leverage-max market)) ERR_INVALID_PARAMS)
        (asserts! (>= collateral MINIMUM_COLLATERAL) ERR_INSUFFICIENT_BALANCE)
        (asserts! (>= collateral (/ (* (to-uint position-size-abs) (get last-price market)) leverage)) 
                 ERR_INSUFFICIENT_BALANCE)
        
        ;; Calculate liquidation price
        (let ((liquidation-price (calculate-liquidation-price 
                                 size 
                                 collateral 
                                 (get maintenance-margin market))))
            
            (ok (map-set positions
                {trader: tx-sender, asset-pair: asset-pair}
                {
                    size: size,
                    entry-price: (get last-price market),
                    collateral: collateral,
                    leverage: leverage,
                    last-funding-time: block-height,
                    liquidation-price: liquidation-price,
                    is-liquidated: false
                }))
        )
    ))

;; Get liquidation statistics
(define-read-only (get-liquidation-stats (trader principal))
    (ok (default-to 
        {total-liquidations: u0, total-penalty-paid: u0}
        (map-get? liquidation-stats trader)))
)