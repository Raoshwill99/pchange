# Decentralized Perpetual Exchange

A decentralized perpetual futures exchange built on the Stacks blockchain using Clarity smart contracts. This platform enables Bitcoin-collateralized perpetual contracts with advanced trading features, sophisticated liquidation mechanics, and comprehensive risk management.

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

### Market Features
- Automated market making
- Dynamic funding rate mechanism
- Flexible position management
- Real-time price feeds
- Advanced collateral management system

## Smart Contract Architecture

### Key Components

1. **Market Management**
   - Market creation and configuration
   - Price feed updates
   - Liquidity pool management
   - Asset pair registration
   - Liquidation tracking

2. **Position Management**
   - Open/close positions
   - Position size tracking
   - Collateral handling
   - Leverage validation
   - Liquidation price calculation

3. **Risk Management**
   - Dynamic maintenance margin requirements
   - Automated liquidation system
   - Position health monitoring
   - Leverage restrictions
   - Minimum collateral requirements

4. **Liquidation System**
   - Automated liquidation triggers
   - Penalty calculation and distribution
   - Liquidation statistics tracking
   - Position settlement
   - Collateral redistribution

## Technical Specifications

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

3. `update-price`
   - Updates asset price feeds
   - Parameters: asset-pair, new-price
   - Access: Authorized oracle only

4. `liquidate-position`
   - Executes position liquidation
   - Parameters: trader, asset-pair
   - Access: Public
   - Includes penalty calculation

#### Read-Only Functions
1. `get-position`
   - Retrieves position details
   - Parameters: trader, asset-pair

2. `get-market`
   - Retrieves market details
   - Parameters: asset-pair

3. `get-liquidation-stats`
   - Retrieves liquidation statistics
   - Parameters: trader

### Data Structures

1. **Markets**
```clarity
{
    liquidity: uint,
    last-price: uint,
    funding-rate: int,
    leverage-max: uint,
    maintenance-margin: uint,
    liquidation-count: uint
}
```

2. **Positions**
```clarity
{
    size: int,
    entry-price: uint,
    collateral: uint,
    leverage: uint,
    last-funding-time: uint,
    liquidation-price: uint,
    is-liquidated: bool
}
```

3. **Liquidation Statistics**
```clarity
{
    total-liquidations: uint,
    total-penalty-paid: uint
}
```

## Risk Parameters

### Liquidation System
- Maintenance Margin: 5%
- Liquidation Penalty: 10%
- Minimum Collateral: 100 units
- Dynamic Liquidation Price Calculation
- Automated Health Checks

### Position Limits
- Maximum Leverage: 20x
- Minimum Collateral Requirement
- Position Size Restrictions
- Dynamic Margin Requirements

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

The contract includes comprehensive test coverage for all major functions:

1. Market Operations Tests
   - Market creation
   - Price updates
   - Liquidity management

2. Position Management Tests
   - Position opening
   - Collateral management
   - Leverage validation

3. Liquidation System Tests
   - Liquidation triggers
   - Penalty calculations
   - Statistics tracking

4. Risk Management Tests
   - Position health monitoring
   - Margin calculations
   - Leverage checks

Run specific test suites:
```bash
npm run test:markets
npm run test:positions
npm run test:liquidations
npm run test:risk
```

## Security Considerations

1. **Access Control**
   - Owner-only functions
   - Oracle authorization
   - Position access restrictions

2. **Risk Management**
   - Dynamic liquidation system
   - Position health monitoring
   - Collateral validation

3. **Price Oracle**
   - Authenticated price feeds
   - Price manipulation protection
   - Update frequency limits

4. **Liquidation Security**
   - Atomic execution
   - Penalty distribution
   - Position settlement verification

## Future Improvements

1. **Phase 3**
   - Implement automated funding rate
   - Add advanced order types
   - Enhance liquidation mechanics
   - Add partial liquidations

2. **Phase 4**
   - Add governance features
   - Implement insurance fund
   - Enhanced market making
   - Multi-collateral support

## Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Submit pull request

## License

MIT License - See LICENSE file for details

## Contact

For questions and support, please open an issue in the GitHub repository.
