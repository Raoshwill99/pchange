# Decentralized Perpetual Exchange

A sophisticated decentralized perpetual futures exchange built on the Stacks blockchain using Clarity smart contracts. This platform enables Bitcoin-collateralized perpetual contracts with advanced trading features, automated funding rate mechanisms, and comprehensive risk management.

## Features

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

## Smart Contract Architecture

### Key Components

1. **Market Management**
   - Market creation and configuration
   - Price feed updates
   - Liquidity pool management
   - Asset pair registration
   - Funding rate calculations

2. **Position Management**
   - Open/close positions
   - Position size tracking
   - Collateral handling
   - Leverage validation
   - Liquidation price calculation

3. **Order Management**
   - Multiple order types support
   - Order book maintenance
   - Price level aggregation
   - Order expiration handling
   - Trigger price execution

4. **Risk Management**
   - Dynamic maintenance margin requirements
   - Automated liquidation system
   - Position health monitoring
   - Price impact limits
   - Order size restrictions

## Technical Specifications

### Order Types

1. **Market Orders**
   - Immediate execution
   - Best available price
   - Volume-based execution

2. **Limit Orders**
   - Price-specific execution
   - Order book placement
   - Partial fill support

3. **Stop-Loss Orders**
   - Downside protection
   - Trigger price activation
   - Market price execution

4. **Take-Profit Orders**
   - Profit targeting
   - Automatic execution
   - Price threshold monitoring

### Funding Rate Mechanism

1. **Rate Calculation**
   - Premium index tracking
   - Price delta analysis
   - Rate capping system
   - Regular updates

2. **Application**
   - Automated collection
   - Position-based distribution
   - Balance management
   - Rate history tracking

### Contract Functions

#### Public Functions
1. `create-perp-market`
   - Creates new perpetual markets
   - Parameters: asset-pair, initial-liquidity, max-leverage
   - Access: Contract owner only

2. `open-position`
   - Opens new trading positions
   - Parameters: asset-pair, size, collateral, leverage
   - Access: Public
   - Includes liquidation price calculation

3. `create-order`
   - Creates new trading orders
   - Parameters: asset-pair, order-type, size, price, leverage
   - Support for multiple order types
   - Price impact validation

4. `update-funding`
   - Updates funding rates
   - Parameters: asset-pair
   - Automated rate calculation
   - Regular interval updates

#### Read-Only Functions
1. `get-position`
   - Retrieves position details
   - Parameters: trader, asset-pair

2. `get-market`
   - Retrieves market details
   - Parameters: asset-pair

3. `get-order`
   - Retrieves order details
   - Parameters: order-id, trader

4. `get-order-book-level`
   - Retrieves order book depth
   - Parameters: asset-pair, price-level

### Data Structures

1. **Markets**
```clarity
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
```

2. **Orders**
```clarity
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
```

3. **Order Book**
```clarity
{
    total-size: int,
    order-count: uint
}
```

## Risk Parameters

### Trading Limits
- Maximum Leverage: 20x
- Minimum Collateral: 100 units
- Price Impact Limit: 0.2%
- Order Expiry: 144 blocks (24 hours)

### Funding Parameters
- Update Interval: 6 blocks
- Maximum Premium Rate: 0.1%
- Premium Index Tracking
- Dynamic Rate Adjustment

## Setup and Deployment

### Prerequisites
- Stacks blockchain development environment
- Clarity CLI tools
- Node.js and npm (for testing environment)

### Installation
1. Clone the repository:
```bash
git clone [repository-url]
cd perpetual-exchange
```

2. Install dependencies:
```bash
npm install
```

3. Run tests:
```bash
npm test
```

### Deployment
1. Configure deployment parameters in `settings.json`
2. Deploy contract:
```bash
clarinet contract deploy
```

## Testing

### Test Suites
1. Market Operations Tests
   - Market creation
   - Price updates
   - Funding rate calculations

2. Order Management Tests
   - Order creation
   - Order book updates
   - Order execution
   - Trigger price activation

3. Position Management Tests
   - Position opening
   - Collateral management
   - Leverage validation
   - Funding payments

4. Risk Management Tests
   - Price impact checks
   - Order size limits
   - Position health monitoring
   - Liquidation triggers

### Test Commands
```bash
npm run test:markets
npm run test:orders
npm run test:positions
npm run test:risk
```

## Security Considerations

1. **Access Control**
   - Owner-only functions
   - Oracle authorization
   - Position access restrictions

2. **Risk Management**
   - Price impact limits
   - Order size restrictions
   - Position health monitoring
   - Automated liquidations

3. **Order Security**
   - Expiration handling
   - Price validation
   - Size restrictions
   - Trigger price accuracy

4. **Rate Management**
   - Capped funding rates
   - Regular updates
   - Premium index validation
   - Rate manipulation protection

## Future Improvements

1. **Phase 4**
   - Advanced order matching
   - Insurance fund integration
   - Enhanced governance features
   - Cross-margin trading

2. **Future Enhancements**
   - Portfolio margin
   - Advanced order types
   - Multi-collateral support
   - Advanced market making

## Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Submit pull request

## License

MIT License - See LICENSE file for details

## Contact

For questions and support, please open an issue in the GitHub repository.
