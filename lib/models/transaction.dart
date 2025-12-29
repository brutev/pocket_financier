class TransactionModel {
  final int? id;
  final DateTime date;
  final double amount;
  final String type; // 'debit' or 'credit'
  final String description;
  final String category; // Food, Shopping, Bills, Rent, Fuel, Other

  TransactionModel({
    this.id,
    required this.date,
    required this.amount,
    required this.type,
    required this.description,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'amount': amount,
      'type': type,
      'description': description,
      'category': category,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      date: DateTime.parse(map['date']),
      amount: map['amount'],
      type: map['type'],
      description: map['description'],
      category: map['category'],
    );
  }
}