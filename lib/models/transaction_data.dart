class TransactionData {
  final bool isValid;
  final String? transactionType;
  final double? amount;
  final String? currency;
  final String? accountLast4Digits;
  final String? transactionMode;
  final double? availableBalance;
  final DateTime? transactionDate;
  final String? bankName;

  TransactionData({
    required this.isValid,
    this.transactionType,
    this.amount,
    this.currency,
    this.accountLast4Digits,
    this.transactionMode,
    this.availableBalance,
    this.transactionDate,
    this.bankName,
  });

  Map<String, dynamic> toJson() => {
    'isValid': isValid,
    'transactionType': transactionType,
    'amount': amount,
    'currency': currency,
    'accountLast4Digits': accountLast4Digits,
    'transactionMode': transactionMode,
    'availableBalance': availableBalance,
    'transactionDate': transactionDate?.toIso8601String(),
    'bankName': bankName,
  };
}