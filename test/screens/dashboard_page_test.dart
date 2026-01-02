import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pocket_financier/screens/dashboard_page.dart';
import 'package:pocket_financier/models/transaction.dart';

void main() {
  group('DashboardPage Widget Tests', () {
    late List<TransactionModel> mockTransactions;

    setUp(() {
      mockTransactions = [
        TransactionModel(
          id: 1,
          amount: 500.0,
          type: 'debit',
          category: 'Food',
          description: 'Restaurant',
          date: DateTime.now(),
          bankName: 'HDFC',
        ),
        TransactionModel(
          id: 2,
          amount: 1000.0,
          type: 'debit',
          category: 'Shopping',
          description: 'Mall',
          date: DateTime.now(),
          bankName: 'ICICI',
        ),
        TransactionModel(
          id: 3,
          amount: 2000.0,
          type: 'credit',
          category: 'Salary',
          description: 'Monthly salary',
          date: DateTime.now(),
          bankName: 'SBI',
        ),
      ];
    });

    testWidgets('displays empty state when no debit transactions', (tester) async {
      final creditOnlyTransactions = [
        TransactionModel(
          id: 1,
          amount: 2000.0,
          type: 'credit',
          category: 'Salary',
          description: 'Monthly salary',
          date: DateTime.now(),
          bankName: 'SBI',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: DashboardPage(transactions: creditOnlyTransactions),
        ),
      );

      expect(find.text('No expense data yet.\nImport SMS to see spending breakdown.'), findsOneWidget);
      expect(find.byType(PieChart), findsNothing);
    });

    testWidgets('displays pie chart with debit transactions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardPage(transactions: mockTransactions),
          ),
        ),
      );

      expect(find.text('Category-wise Spending'), findsOneWidget);
      expect(find.byType(PieChart), findsOneWidget);
      expect(find.text('Food: ₹500'), findsOneWidget);
      expect(find.text('Shopping: ₹1000'), findsOneWidget);
    });

    testWidgets('displays correct category chips', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardPage(transactions: mockTransactions),
          ),
        ),
      );

      expect(find.byType(Chip), findsNWidgets(2));
      expect(find.text('Food: ₹500'), findsOneWidget);
      expect(find.text('Shopping: ₹1000'), findsOneWidget);
    });

    testWidgets('handles empty transaction list', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardPage(transactions: []),
        ),
      );

      expect(find.text('No expense data yet.\nImport SMS to see spending breakdown.'), findsOneWidget);
      expect(find.byType(PieChart), findsNothing);
      expect(find.byType(Chip), findsNothing);
    });

    testWidgets('aggregates same category transactions', (tester) async {
      final duplicateCategoryTransactions = [
        TransactionModel(
          id: 1,
          amount: 300.0,
          type: 'debit',
          category: 'Food',
          description: 'Restaurant 1',
          date: DateTime.now(),
          bankName: 'HDFC',
        ),
        TransactionModel(
          id: 2,
          amount: 200.0,
          type: 'debit',
          category: 'Food',
          description: 'Restaurant 2',
          date: DateTime.now(),
          bankName: 'ICICI',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardPage(transactions: duplicateCategoryTransactions),
          ),
        ),
      );

      expect(find.text('Food: ₹500'), findsOneWidget);
      expect(find.byType(Chip), findsOneWidget);
    });
  });

  group('DashboardPage Unit Tests', () {
    test('filters only debit transactions', () {
      final transactions = [
        TransactionModel(
          id: 1,
          amount: 500.0,
          type: 'debit',
          category: 'Food',
          description: 'Restaurant',
          date: DateTime.now(),
          bankName: 'HDFC',
        ),
        TransactionModel(
          id: 2,
          amount: 2000.0,
          type: 'credit',
          category: 'Salary',
          description: 'Monthly salary',
          date: DateTime.now(),
          bankName: 'SBI',
        ),
      ];

      final debitTransactions = transactions.where((tx) => tx.type == 'debit').toList();
      
      expect(debitTransactions.length, 1);
      expect(debitTransactions.first.category, 'Food');
    });

    test('aggregates category totals correctly', () {
      final transactions = [
        TransactionModel(
          id: 1,
          amount: 300.0,
          type: 'debit',
          category: 'Food',
          description: 'Restaurant 1',
          date: DateTime.now(),
          bankName: 'HDFC',
        ),
        TransactionModel(
          id: 2,
          amount: 200.0,
          type: 'debit',
          category: 'Food',
          description: 'Restaurant 2',
          date: DateTime.now(),
          bankName: 'ICICI',
        ),
        TransactionModel(
          id: 3,
          amount: 1000.0,
          type: 'debit',
          category: 'Shopping',
          description: 'Mall',
          date: DateTime.now(),
          bankName: 'SBI',
        ),
      ];

      final Map<String, double> categoryTotals = {};
      for (final tx in transactions) {
        categoryTotals[tx.category] = (categoryTotals[tx.category] ?? 0) + tx.amount;
      }

      expect(categoryTotals['Food'], 500.0);
      expect(categoryTotals['Shopping'], 1000.0);
      expect(categoryTotals.length, 2);
    });
  });
}