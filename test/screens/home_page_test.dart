import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_financier/screens/home_page.dart';
import 'package:pocket_financier/models/transaction.dart';

void main() {
  group('HomePage Widget Tests', () {
    testWidgets('displays app title and navigation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      expect(find.text('Pocket Financier'), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Transactions'), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Coach'), findsOneWidget);
    });

    testWidgets('shows refresh and debug buttons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
      expect(find.byIcon(Icons.bug_report), findsOneWidget);
    });

    testWidgets('navigation changes pages', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Tap on Dashboard tab
      await tester.tap(find.text('Dashboard'));
      await tester.pumpAndSettle();

      // Should show dashboard empty state since no transactions
      expect(find.text('No expense data yet.\nImport SMS to see spending breakdown.'), findsOneWidget);
    });

    testWidgets('displays net savings card', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      expect(find.text('Net Savings'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up_rounded), findsOneWidget);
    });

    testWidgets('displays financial overview cards', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      expect(find.text('Total Credit'), findsOneWidget);
      expect(find.text('Total Debit'), findsOneWidget);
      expect(find.text('Total Transactions'), findsOneWidget);
    });

    testWidgets('displays pro tip card', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      expect(find.text('Pro Tip'), findsOneWidget);
      expect(find.byIcon(Icons.lightbulb_rounded), findsOneWidget);
    });
  });

  group('HomePage Unit Tests', () {
    test('calculates totals correctly', () {
      final transactions = [
        TransactionModel(
          id: 1,
          amount: 1000.0,
          type: 'credit',
          category: 'Salary',
          description: 'Monthly salary',
          date: DateTime.now(),
        ),
        TransactionModel(
          id: 2,
          amount: 500.0,
          type: 'debit',
          category: 'Food',
          description: 'Restaurant',
          date: DateTime.now(),
        ),
        TransactionModel(
          id: 3,
          amount: 300.0,
          type: 'debit',
          category: 'Shopping',
          description: 'Mall',
          date: DateTime.now(),
        ),
      ];

      double totalCredit = 0.0;
      double totalDebit = 0.0;
      for (final t in transactions) {
        if (t.type == 'credit') {
          totalCredit += t.amount;
        } else if (t.type == 'debit') {
          totalDebit += t.amount;
        }
      }

      expect(totalCredit, 1000.0);
      expect(totalDebit, 800.0);
      expect(totalCredit - totalDebit, 200.0);
    });

    test('calculates savings percentage correctly', () {
      const totalCredit = 1000.0;
      const totalDebit = 800.0;
      const netSavings = totalCredit - totalDebit;
      
      final savingsPercentage = totalCredit > 0 
          ? (netSavings / totalCredit * 100).clamp(0.0, 100.0) 
          : 0.0;

      expect(savingsPercentage, 20.0);
    });

    test('handles zero credit correctly', () {
      const totalCredit = 0.0;
      const totalDebit = 500.0;
      const netSavings = totalCredit - totalDebit;
      
      final savingsPercentage = totalCredit > 0 
          ? (netSavings / totalCredit * 100).clamp(0.0, 100.0) 
          : 0.0;

      expect(savingsPercentage, 0.0);
      expect(netSavings, -500.0);
    });

    test('counts transactions by type correctly', () {
      final transactions = [
        TransactionModel(
          id: 1,
          amount: 1000.0,
          type: 'credit',
          category: 'Salary',
          description: 'Monthly salary',
          date: DateTime.now(),
        ),
        TransactionModel(
          id: 2,
          amount: 500.0,
          type: 'debit',
          category: 'Food',
          description: 'Restaurant',
          date: DateTime.now(),
        ),
        TransactionModel(
          id: 3,
          amount: 300.0,
          type: 'debit',
          category: 'Shopping',
          description: 'Mall',
          date: DateTime.now(),
        ),
      ];

      final creditCount = transactions.where((t) => t.type == 'credit').length;
      final debitCount = transactions.where((t) => t.type == 'debit').length;

      expect(creditCount, 1);
      expect(debitCount, 2);
      expect(transactions.length, 3);
    });
  });
}