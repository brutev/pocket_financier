import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_financier/models/transaction.dart';

void main() {
  group('TransactionModel edge cases', () {
    test('Handles null/empty description and category', () {
      final tx = TransactionModel(
        id: 1,
        date: DateTime(2024, 1, 1),
        amount: 0.0,
        type: 'credit',
        description: '',
        category: '',
      );
      expect(tx.description, '');
      expect(tx.category, '');
    });

    test('Handles negative and zero amounts', () {
      final tx1 = TransactionModel(
        id: 2,
        date: DateTime(2024, 1, 1),
        amount: 0.0,
        type: 'debit',
        description: 'Zero',
        category: 'Test',
      );
      final tx2 = TransactionModel(
        id: 3,
        date: DateTime(2024, 1, 1),
        amount: -100.0,
        type: 'debit',
        description: 'Negative',
        category: 'Test',
      );
      expect(tx1.amount, 0.0);
      expect(tx2.amount, -100.0);
    });
  });
}
