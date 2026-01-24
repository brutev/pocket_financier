import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_financier/models/transaction.dart';

void main() {
  group('TransactionModel', () {
    test('effectiveDate returns transactionDate if present', () {
      final tx = TransactionModel(
        id: 1,
        date: DateTime(2024, 1, 1),
        transactionDate: DateTime(2024, 1, 2),
        amount: 100.0,
        type: 'credit',
        description: 'Test',
        category: 'Test',
      );
      expect(tx.effectiveDate, DateTime(2024, 1, 2));
    });

    test('effectiveDate falls back to date if transactionDate is null', () {
      final tx = TransactionModel(
        id: 1,
        date: DateTime(2024, 1, 1),
        transactionDate: null,
        amount: 100.0,
        type: 'credit',
        description: 'Test',
        category: 'Test',
      );
      expect(tx.effectiveDate, DateTime(2024, 1, 1));
    });

    test('toMap and fromMap are consistent', () {
      final tx = TransactionModel(
        id: 1,
        date: DateTime(2024, 1, 1),
        transactionDate: DateTime(2024, 1, 2),
        amount: 100.0,
        type: 'credit',
        description: 'Test',
        category: 'Test',
      );
      final map = tx.toMap();
      final tx2 = TransactionModel.fromMap(map);
      expect(tx2.id, tx.id);
      expect(tx2.date, tx.date);
      expect(tx2.transactionDate, tx.transactionDate);
      expect(tx2.amount, tx.amount);
      expect(tx2.type, tx.type);
      expect(tx2.description, tx.description);
      expect(tx2.category, tx.category);
    });
  });
}
