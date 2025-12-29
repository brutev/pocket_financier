# Pocket Financier

A Flutter-based personal finance management app that automatically extracts and categorizes banking transactions from SMS messages.

## Features

### 📱 SMS Transaction Parsing
- Automatically reads banking SMS messages with permission
- Supports major Indian banks (HDFC, SBI, ICICI, Axis, and more)
- Advanced spam detection and filtering
- High-accuracy transaction extraction with confidence scoring

### 💰 Transaction Management
- Automatic categorization (Food, Shopping, Bills, Rent, Fuel, Other)
- Credit/Debit transaction tracking
- SQLite local database storage
- Real-time balance calculations

### 📊 Financial Dashboard
- Visual spending charts using FL Chart
- Monthly spending analysis
- Category-wise expense breakdown
- Net savings tracking

### 🤖 AI Financial Coach
- Personalized financial advice (when AI service is configured)
- Spending pattern analysis
- Budget recommendations

## Architecture

```
lib/
├── data/
│   └── transaction_db.dart          # SQLite database operations
├── models/
│   ├── transaction.dart             # Transaction data model
│   ├── transaction_data.dart        # Chart data model
│   └── sms_parse_result.dart        # SMS parsing result model
├── parsers/
│   └── banking_sms_parser.dart      # Multi-bank SMS parser
├── screens/
│   ├── home_page.dart              # Main navigation & overview
│   ├── transactions_page.dart       # Transaction list view
│   ├── dashboard_page.dart          # Charts & analytics
│   ├── coach_page.dart             # AI financial advice
│   ├── debug_page.dart             # Development tools
│   └── sms_test_page.dart          # SMS parsing tests
├── services/
│   ├── sms_service.dart            # SMS reading & processing
│   ├── sms_extractor_service.dart  # Transaction extraction
│   └── stats_service.dart          # Financial calculations
└── main.dart                       # App entry point
```

## Dependencies

- **flutter_sms_inbox**: SMS message reading
- **permission_handler**: SMS permission management
- **sqflite**: Local SQLite database
- **fl_chart**: Interactive charts and graphs
- **path_provider**: File system access
- **flutter_gemma**: AI model integration (optional)

## Supported Banks

- HDFC Bank (HDFCBK)
- State Bank of India (SBIINB)
- ICICI Bank (ICICIB)
- Axis Bank (AXISBK)
- Punjab National Bank (PNBSMS)
- Standard Chartered (SCBANK)
- Citibank (CITIBK)
- Kotak Mahindra (KOTAK)
- Yes Bank (YESBNK)
- Bank of India (BOIIND)
- Indian Bank (INDBNK)
- Union Bank (UNIONB)
- Canara Bank (CANBKS)
- Maharashtra Bank (MAHABK)
- Federal Bank (FEDBK)
- IDBI Bank (IDBIBK)
- UCO Bank (UCOBKS)
- Punjab & Sind Bank (PSBANK)

## Getting Started

### Prerequisites
- Flutter SDK (3.8.1+)
- Android device/emulator (SMS access required)
- SMS permission for transaction reading

### Installation

1. Clone the repository:
```bash
git clone https://github.com/brutev/pocket_financier.git
cd pocket_financier
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### First Run
1. Grant SMS permission when prompted
2. App will automatically import recent banking SMS
3. View transactions in the Transactions tab
4. Check spending analytics in Dashboard
5. Get AI insights in Coach (if configured)

## Privacy & Security

- All data stored locally on device
- No transaction data sent to external servers
- SMS parsing happens entirely offline
- Bank-grade spam detection and filtering
- Only processes messages from verified bank senders

## Development

### Adding New Banks
1. Add sender ID to `_bankSenders` in `banking_sms_parser.dart`
2. Implement bank-specific parsing method
3. Test with sample SMS messages

### Debugging
- Use Debug page for SMS parsing tests
- Check console logs for parsing details
- Confidence levels: High > Medium > Low > Invalid

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/new-bank`)
3. Commit changes (`git commit -am 'Add new bank support'`)
4. Push to branch (`git push origin feature/new-bank`)
5. Create Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Disclaimer

This app is for personal finance tracking only. Always verify transaction data with official bank statements. The developers are not responsible for any financial decisions made based on this app's data.
