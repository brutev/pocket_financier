import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_financier/models/transaction.dart';
import 'package:pocket_financier/utils/transaction_utils.dart';

void main() {
  group('TransactionUtils', () {
    final mockTransactions = [
      TransactionModel(
        id: 1,
        amount: 5000.0,
        type: 'credit',
        category: 'Salary',
        description: 'Monthly salary',
        date: DateTime(2024, 1, 1),
      ),
      TransactionModel(
        id: 2,
        amount: 1000.0,
        type: 'debit',
        category: 'Food',
        description: 'Restaurant',
        date: DateTime(2024, 1, 5),
      ),
      TransactionModel(
        id: 3,
        amount: 500.0,
        type: 'debit',
        category: 'Shopping',
        description: 'Mall',
        date: DateTime(2024, 1, 10),
      ),
      TransactionModel(
        id: 4,
        amount: 2000.0,
        type: 'credit',
        category: 'Bonus',
        description: 'Performance bonus',
        date: DateTime(2024, 1, 15),
      ),
    ];

    test('calculateTotalCredit returns correct sum', () {
      final result = TransactionUtils.calculateTotalCredit(mockTransactions);
      expect(result, 7000.0);
    });

    test('calculateTotalDebit returns correct sum', () {
      final result = TransactionUtils.calculateTotalDebit(mockTransactions);
      expect(result, 1500.0);
    });

    test('calculateNetSavings returns correct difference', () {
      final totalCredit = 7000.0;
      final totalDebit = 1500.0;
      final result = TransactionUtils.calculateNetSavings(totalCredit, totalDebit);
      expect(result, 5500.0);
    });

    test('calculateSavingsPercentage returns correct percentage', () {
      final totalCredit = 7000.0;
      final netSavings = 5500.0;
      final result = TransactionUtils.calculateSavingsPercentage(totalCredit, netSavings);
      expect(result, closeTo(78.57, 0.01));
    });

    test('calculateSavingsPercentage returns 0 when totalCredit is 0', () {
      final result = TransactionUtils.calculateSavingsPercentage(0, 0);
      expect(result, 0.0);
    });

    test('countCreditTransactions returns correct count', () {
      final result = TransactionUtils.countCreditTransactions(mockTransactions);
      expect(result, 2);
    });

    test('countDebitTransactions returns correct count', () {
      final result = TransactionUtils.countDebitTransactions(mockTransactions);
      expect(result, 2);
    });

    test('calculateCategoryTotals returns correct breakdown', () {
      final result = TransactionUtils.calculateCategoryTotals(mockTransactions);
      expect(result['Food'], 1000.0);
      expect(result['Shopping'], 500.0);
      expect(result.containsKey('Salary'), false); // Should only include debits
    });

    test('calculateCategoryTotals returns empty map for no debit transactions', () {
      final creditOnlyTransactions = [
        TransactionModel(
          id: 1,
          amount: 5000.0,
          type: 'credit',
          category: 'Salary',
          description: 'Monthly salary',
          date: DateTime(2024, 1, 1),
        ),
      ];
      final result = TransactionUtils.calculateCategoryTotals(creditOnlyTransactions);
      expect(result.isEmpty, true);
    });
  });
}
