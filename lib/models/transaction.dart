class TransactionModel {
  final int? id;
  final DateTime date; // SMS received date (fallback)
  final DateTime? transactionDate; // Actual transaction date from SMS text
  final double amount;
  final String type; // 'debit' or 'credit'
  final String description;
  final String category; // Food, Shopping, Bills, Rent, Fuel, Other
  
  // New fields from enhanced parsing
  final String? accountLast4;
  final String? transactionMode; // UPI, NEFT, IMPS, ATM, POS, etc.
  final double? availableBalance;
  final String? bankName;
  final String? transactionRef; // Transaction reference number
  final String? merchantName; // Payee/Merchant name
  final String? upiTransactionId; // UPI transaction ID if available

  TransactionModel({
    this.id,
    required this.date,
    this.transactionDate,
    required this.amount,
    required this.type,
    required this.description,
    required this.category,
    this.accountLast4,
    this.transactionMode,
    this.availableBalance,
    this.bankName,
    this.transactionRef,
    this.merchantName,
    this.upiTransactionId,
  });

  // Get the actual transaction date (prefer transactionDate over date)
  DateTime get effectiveDate => transactionDate ?? date;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'transactionDate': transactionDate?.toIso8601String(),
      'amount': amount,
      'type': type,
      'description': description,
      'category': category,
      'accountLast4': accountLast4,
      'transactionMode': transactionMode,
      'availableBalance': availableBalance,
      'bankName': bankName,
      'transactionRef': transactionRef,
      'merchantName': merchantName,
      'upiTransactionId': upiTransactionId,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      date: DateTime.parse(map['date']),
      transactionDate: map['transactionDate'] != null 
          ? DateTime.parse(map['transactionDate']) 
          : null,
      amount: map['amount'],
      type: map['type'],
      description: map['description'],
      category: map['category'],
      accountLast4: map['accountLast4'],
      transactionMode: map['transactionMode'],
      availableBalance: map['availableBalance'],
      bankName: map['bankName'],
      transactionRef: map['transactionRef'],
      merchantName: map['merchantName'],
      upiTransactionId: map['upiTransactionId'],
    );
  }
}