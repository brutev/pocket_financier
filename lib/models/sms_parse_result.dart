enum ConfidenceLevel { high, medium, low, invalid }

class SmsParseResult {
  final bool isValid;
  final ConfidenceLevel confidence;
  final String? transactionType;
  final double? amount;
  final String currency;
  final String? accountLast4Digits;
  final String? transactionMode;
  final double? availableBalance;
  final DateTime? transactionDate;
  final String? bankName;
  final String extractionMethod;
  final String rawSMS;
  final String sender;
  final List<String> failureReasons;
  final List<String> warnings;

  SmsParseResult({
    required this.isValid,
    required this.confidence,
    this.transactionType,
    this.amount,
    this.currency = 'INR',
    this.accountLast4Digits,
    this.transactionMode,
    this.availableBalance,
    this.transactionDate,
    this.bankName,
    required this.extractionMethod,
    required this.rawSMS,
    required this.sender,
    this.failureReasons = const [],
    this.warnings = const [],
  });
}