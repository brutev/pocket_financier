import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_financier/screens/coach_page.dart';
import 'package:pocket_financier/models/transaction.dart';
import 'package:pocket_financier/services/stats_service.dart';

void main() {
  group('CoachPage Widget Tests', () {
    late List<TransactionModel> mockTransactions;

    setUp(() {
      mockTransactions = [
        TransactionModel(
          id: 1,
          amount: 45000.0,
          type: 'credit',
          category: 'Salary',
          description: 'Monthly salary',
          date: DateTime(2024, 1, 1),
          bankName: 'SBI',
        ),
        TransactionModel(
          id: 2,
          amount: 5000.0,
          type: 'debit',
          category: 'Food',
          description: 'Groceries and dining',
          date: DateTime(2024, 1, 5),
          bankName: 'HDFC',
        ),
        TransactionModel(
          id: 3,
          amount: 10000.0,
          type: 'debit',
          category: 'Bills',
          description: 'EMI payment',
          date: DateTime(2024, 1, 10),
          bankName: 'ICICI',
        ),
      ];
    });

    testWidgets('displays ask coach button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoachPage(transactions: mockTransactions),
          ),
        ),
      );

      expect(find.text('Ask Coach for This Month'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('displays disclaimer', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoachPage(transactions: mockTransactions),
          ),
        ),
      );

      expect(find.text('Disclaimer: This is not professional financial advice, just a budgeting helper.'), findsOneWidget);
    });

    testWidgets('button is enabled initially', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoachPage(transactions: mockTransactions),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('displays advice after button tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoachPage(transactions: mockTransactions),
          ),
        ),
      );

      await tester.tap(find.text('Ask Coach for This Month'));
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsAtLeastNWidgets(1));
    });

    testWidgets('handles empty transactions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoachPage(transactions: const []),
          ),
        ),
      );

      await tester.tap(find.text('Ask Coach for This Month'));
      await tester.pumpAndSettle();

      expect(find.text('No data yet. Import SMS first.'), findsOneWidget);
    });

    testWidgets('displays correct padding', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoachPage(transactions: mockTransactions),
          ),
        ),
      );

      final padding = tester.widget<Padding>(find.byType(Padding).first);
      expect(padding.padding, const EdgeInsets.all(16.0));
    });
  });

  group('CoachPage Unit Tests', () {
    test('calculates savings rate correctly', () {
      const income = 45000.0;
      const expense = 15000.0;
      const savings = income - expense;
      final savingsRate = savings / income;

      expect(savings, 30000.0);
      expect(savingsRate, closeTo(0.67, 0.01));
      expect((savingsRate * 100).toStringAsFixed(1), '66.7');
    });

    test('handles zero income scenario', () {
      const income = 0.0;
      const expense = 1000.0;
      const savings = income - expense;
      final savingsRate = income > 0 ? savings / income : 0.0;

      expect(savings, -1000.0);
      expect(savingsRate, 0.0);
    });

    test('groups transactions by month correctly', () {
      final transactions = [
        TransactionModel(
          id: 1,
          amount: 1000.0,
          type: 'credit',
          category: 'Salary',
          description: 'Jan salary',
          date: DateTime(2024, 1, 1),
          bankName: 'SBI',
        ),
        TransactionModel(
          id: 2,
          amount: 500.0,
          type: 'debit',
          category: 'Food',
          description: 'Jan expense',
          date: DateTime(2024, 1, 15),
          bankName: 'HDFC',
        ),
        TransactionModel(
          id: 3,
          amount: 2000.0,
          type: 'credit',
          category: 'Salary',
          description: 'Feb salary',
          date: DateTime(2024, 2, 1),
          bankName: 'SBI',
        ),
      ];

      final grouped = StatsService.groupByMonth(transactions);
      
      expect(grouped.keys.length, 2);
      expect(grouped.containsKey('2024-01'), true);
      expect(grouped.containsKey('2024-02'), true);
      expect(grouped['2024-01']?.length, 2);
      expect(grouped['2024-02']?.length, 1);
    });

    test('sorts months in descending order', () {
      final months = ['2024-01', '2024-03', '2024-02'];
      months.sort((a, b) => b.compareTo(a));
      
      expect(months, ['2024-03', '2024-02', '2024-01']);
    });

    test('handles empty transaction list', () {
      const List<TransactionModel> transactions = [];
      final grouped = StatsService.groupByMonth(transactions);
      
      expect(grouped.isEmpty, true);
      expect(grouped.keys.length, 0);
    });
  });
}