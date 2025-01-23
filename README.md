# Decentralized Perpetual Exchange

A decentralized perpetual futures exchange built on the Stacks blockchain using Clarity smart contracts. This platform enables Bitcoin-collateralized perpetual contracts with advanced trading features and built-in risk management.

## Features

### Core Functionality
- Bitcoin-collateralized perpetual contracts
- Multi-asset trading pairs support
- Configurable leverage up to 20x
- Built-in liquidation protection
- Decentralized price oracle integration

### Market Features
- Automated market making
- Dynamic funding rate mechanism
- Flexible position management
- Real-time price feeds
- Collateral management system

## Smart Contract Architecture

### Key Components

1. **Market Management**
   - Market creation and configuration
   - Price feed updates
   - Liquidity pool management
   - Asset pair registration

2. **Position Management**
   - Open/close positions
   - Position size tracking
   - Collateral handling
   - Leverage validation

3. **Risk Management**
   - Maintenance margin requirements
   - Liquidation thresholds
   - Position size limits
   - Leverage restrictions

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

3. `update-price`
   - Updates asset price feeds
   - Parameters: asset-pair, new-price
   - Access: Authorized oracle only

#### Read-Only Functions
1. `get-position`
   - Retrieves position details
   - Parameters: trader, asset-pair

2. `get-market`
   - Retrieves market details
   - Parameters: asset-pair

### Data Structures

1. **Markets**
```clarity
{
    liquidity: uint,
    last-price: uint,
    funding-rate: int,
    leverage-max: uint,
    maintenance-margin: uint
}
```

2. **Positions**
```clarity
{
    size: int,
    entry-price: uint,
    collateral: uint,
    leverage: uint,
    last-funding-time: uint
}
```

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

1. Market Creation Tests
2. Position Management Tests
3. Price Update Tests
4. Risk Management Tests

Run specific test suites:
```bash
npm run test:markets
npm run test:positions
npm run test:oracle
```

## Security Considerations

1. **Access Control**
   - Owner-only functions
   - Oracle authorization
   - Position access restrictions

2. **Risk Management**
   - Leverage limits
   - Position size restrictions
   - Liquidation thresholds

3. **Price Oracle**
   - Authenticated price feeds
   - Price manipulation protection
   - Update frequency limits

## Future Improvements

1. **Phase 2**
   - Implement advanced liquidation mechanics
   - Add multi-collateral support
   - Enhance oracle system

2. **Phase 3**
   - Implement automated funding rate
   - Add advanced order types
   - Improve risk management

3. **Phase 4**
   - Add governance features
   - Implement insurance fund
   - Enhanced market making

## Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Submit pull request

## License

MIT License - See LICENSE file for details

## Contact

For questions and support, please open an issue in the GitHub repository.
