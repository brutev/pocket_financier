import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_financier/screens/transactions_page.dart';
import 'package:pocket_financier/models/transaction.dart';

void main() {
  group('TransactionsPage Widget Tests', () {
    late List<TransactionModel> mockTransactions;

    setUp(() {
      mockTransactions = [
        TransactionModel(
          id: 1,
          amount: 500.0,
          type: 'debit',
          category: 'Food',
          description: 'Restaurant payment for dinner',
          date: DateTime(2024, 1, 15),
          bankName: 'HDFC',
        ),
        TransactionModel(
          id: 2,
          amount: 2000.0,
          type: 'credit',
          category: 'Salary',
          description: 'Monthly salary credited',
          date: DateTime(2024, 1, 1),
          bankName: 'SBI',
        ),
        TransactionModel(
          id: 3,
          amount: 1200.0,
          type: 'debit',
          category: 'Shopping',
          description: 'Online shopping purchase from Amazon',
          date: DateTime(2024, 1, 10),
          bankName: 'ICICI',
        ),
      ];
    });

    testWidgets('displays empty state when no transactions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TransactionsPage(transactions: []),
        ),
      );

      expect(find.text('No transactions imported yet.\nTap refresh on Home.'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
      expect(find.byType(Card), findsNothing);
    });

    testWidgets('displays transaction list when transactions exist', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TransactionsPage(transactions: mockTransactions),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(3));
      expect(find.byType(ListTile), findsNWidgets(3));
    });

    testWidgets('displays correct transaction details', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TransactionsPage(transactions: mockTransactions),
        ),
      );

      // Check debit transaction
      expect(find.text('DEBIT ₹500.00'), findsOneWidget);
      expect(find.text('15/1/2024 • Food'), findsOneWidget);
      expect(find.text('Restaurant payment for dinner'), findsOneWidget);

      // Check credit transaction
      expect(find.text('CREDIT ₹2000.00'), findsOneWidget);
      expect(find.text('1/1/2024 • Salary'), findsOneWidget);
      expect(find.text('Monthly salary credited'), findsOneWidget);
    });

    testWidgets('displays correct colors for transaction types', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TransactionsPage(transactions: mockTransactions),
        ),
      );

      final debitText = tester.widget<Text>(find.text('DEBIT ₹500.00'));
      final creditText = tester.widget<Text>(find.text('CREDIT ₹2000.00'));

      expect(debitText.style?.color, Colors.red);
      expect(creditText.style?.color, Colors.green);
    });

    testWidgets('handles long descriptions with ellipsis', (tester) async {
      final longDescriptionTransaction = [
        TransactionModel(
          id: 1,
          amount: 500.0,
          type: 'debit',
          category: 'Food',
          description: 'This is a very long transaction description that should be truncated with ellipsis when displayed in the list tile to prevent overflow issues',
          date: DateTime(2024, 1, 15),
          bankName: 'HDFC',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: TransactionsPage(transactions: longDescriptionTransaction),
        ),
      );

      final descriptionText = tester.widget<Text>(
        find.text('This is a very long transaction description that should be truncated with ellipsis when displayed in the list tile to prevent overflow issues'),
      );
      
      expect(descriptionText.maxLines, 2);
      expect(descriptionText.overflow, TextOverflow.ellipsis);
    });

    testWidgets('displays transactions in correct order', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TransactionsPage(transactions: mockTransactions),
        ),
      );

      final listTiles = tester.widgetList<ListTile>(find.byType(ListTile));
      expect(listTiles.length, 3);

      // Verify first transaction (index 0)
      final firstTitle = (listTiles.elementAt(0).title as Text).data;
      expect(firstTitle, 'DEBIT ₹500.00');

      // Verify second transaction (index 1)
      final secondTitle = (listTiles.elementAt(1).title as Text).data;
      expect(secondTitle, 'CREDIT ₹2000.00');
    });

    testWidgets('all list tiles are three-line', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TransactionsPage(transactions: mockTransactions),
        ),
      );

      final listTiles = tester.widgetList<ListTile>(find.byType(ListTile));
      for (final tile in listTiles) {
        expect(tile.isThreeLine, true);
      }
    });

    testWidgets('cards have correct margins', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TransactionsPage(transactions: mockTransactions),
        ),
      );

      final cards = tester.widgetList<Card>(find.byType(Card));
      for (final card in cards) {
        expect(card.margin, const EdgeInsets.symmetric(horizontal: 8, vertical: 4));
      }
    });
  });

  group('TransactionsPage Unit Tests', () {
    test('transaction amount formatting', () {
      const amount = 1234.56;
      final formatted = amount.toStringAsFixed(2);
      expect(formatted, '1234.56');
    });

    test('transaction type uppercase conversion', () {
      const type = 'debit';
      final uppercase = type.toUpperCase();
      expect(uppercase, 'DEBIT');
    });

    test('date formatting', () {
      final date = DateTime(2024, 1, 15);
      final formatted = '${date.day}/${date.month}/${date.year}';
      expect(formatted, '15/1/2024');
    });

    test('empty list handling', () {
      const List<TransactionModel> transactions = [];
      expect(transactions.isEmpty, true);
      expect(transactions.length, 0);
    });

    test('transaction filtering by type', () {
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
          description: 'Salary',
          date: DateTime.now(),
          bankName: 'SBI',
        ),
      ];

      final debits = transactions.where((tx) => tx.type == 'debit').toList();
      final credits = transactions.where((tx) => tx.type == 'credit').toList();

      expect(debits.length, 1);
      expect(credits.length, 1);
      expect(debits.first.amount, 500.0);
      expect(credits.first.amount, 2000.0);
    });
  });
}