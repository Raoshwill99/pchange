# Decentralized Perpetual Exchange

A sophisticated decentralized perpetual futures exchange built on the Stacks blockchain using Clarity smart contracts. This platform enables Bitcoin-collateralized perpetual contracts with advanced market making, robust trading features, and comprehensive risk management.

## Features Evolution

### Core Functionality (Phase 1)
- Bitcoin-collateralized perpetual contracts
- Multi-asset trading pairs support
- Configurable leverage up to 20x
- Built-in liquidation protection
- Decentralized price oracle integration

### Advanced Features (Phase 2)
- Dynamic liquidation system with penalties
- Position health monitoring
- Liquidation price calculation
- Advanced risk management parameters
- Comprehensive liquidation statistics

### Enhanced Trading Features (Phase 3)
- Automated funding rate mechanism
- Advanced order types (Market, Limit, Stop-Loss, Take-Profit)
- Order book management system
- Price impact controls
- 24-hour volume tracking

### Market Making System (Phase 4)
- Professional market maker registration
- Performance-based rewards
- Automated metrics tracking
- Quality-based incentives
- Status management system

## Technical Architecture

### Market Maker System

1. **Registration Process**
   ```clarity
   (define-public (register-market-maker (stake-amount uint) (token <ft-trait>))
   ```
   - Minimum stake requirement
   - Token staking mechanism
   - Duplicate registration prevention
   - Status tracking

2. **Performance Metrics**
   ```clarity
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
   ```

3. **Status Management**
   - Active/Inactive states
   - Performance-based status
   - Owner-controlled updates
   - Automated tracking

### System Parameters

1. **Market Maker Requirements**
   ```clarity
   (define-constant MARKET_MAKER_MIN_STAKE u100000)
   (define-constant MIN_ORDERS_REQUIRED u4)
   (define-constant MAX_SPREAD_ALLOWED u500)
   ```

2. **Performance Scoring**
   - Order count weighting (50%)
   - Spread maintenance (30%)
   - Volume contribution (20%)

3. **Status Codes**
   ```clarity
   (define-constant MM_STATUS_ACTIVE u1)
   (define-constant MM_STATUS_INACTIVE u0)
   ```

## Contract Functions

### Public Functions

1. **Market Maker Registration**
   ```clarity
   (define-public (register-market-maker (stake-amount uint) (token <ft-trait>))
   ```
   - Parameters:
     - stake-amount: Minimum required stake
     - token: FT trait for staking

2. **Metrics Update**
   ```clarity
   (define-public (update-market-maker-metrics 
       (maker principal) 
       (orders uint)
       (spread uint)
       (new-volume uint))
   ```
   - Updates performance metrics
   - Calculates scores
   - Tracks volume

3. **Status Management**
   ```clarity
   (define-public (update-market-maker-status (maker principal) (new-status uint))
   ```
   - Owner-only function
   - Status validation
   - State updates

### Read-Only Functions

1. **Market Maker Info**
   ```clarity
   (define-read-only (get-market-maker (maker principal))
   ```
   - Retrieves complete maker data

2. **Status Checks**
   ```clarity
   (define-read-only (is-active-market-maker (maker principal))
   ```
   - Validates active status

## Error Handling

1. **Registration Errors**
   - ERR_ALREADY_REGISTERED
   - ERR_INSUFFICIENT_STAKE
   - ERR_UNAUTHORIZED

2. **Operation Errors**
   - ERR_INVALID_PARAMS
   - ERR_UNAUTHORIZED
   - ERR_POSITION_NOT_FOUND

## Security Features

1. **Access Control**
   - Owner-only functions
   - Maker self-management
   - Status restrictions

2. **Stake Management**
   - Minimum stake requirement
   - Token locking mechanism
   - Withdrawal restrictions

3. **Performance Monitoring**
   - Continuous metric tracking
   - Quality assessments
   - Volume verification

## Setup and Deployment

### Prerequisites
- Stacks blockchain development environment
- Clarity CLI tools
- Node.js and npm

### Installation Steps
1. Clone repository:
   ```bash
   git clone [repository-url]
   cd perpetual-exchange
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Deploy contract:
   ```bash
   clarinet contract deploy
   ```

## Testing

### Test Categories

1. **Registration Tests**
   - Stake validation
   - Duplicate prevention
   - Token transfers

2. **Metrics Tests**
   - Performance calculation
   - Volume tracking
   - Score updates

3. **Status Tests**
   - State transitions
   - Access controls
   - Update validation

### Test Commands
```bash
npm run test:registration
npm run test:metrics
npm run test:status
```

## Future Improvements

1. **Enhanced Features**
   - Tiered market making
   - Advanced reward systems
   - Dynamic parameters

2. **System Upgrades**
   - Cross-margin trading
   - Portfolio management
   - Advanced analytics

## Contributing

1. Fork repository
2. Create feature branch
3. Submit pull request
4. Add test coverage

## License

MIT License - See LICENSE file for details

## Support

For questions and support:
- Open GitHub issue
- Join community channel
- Check documentation
