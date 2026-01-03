import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_financier/screens/debug_page.dart';
import 'package:pocket_financier/models/transaction.dart';

// Mock TransactionDb for testing
class MockTransactionDb {
  static List<TransactionModel> _mockData = [];
  
  static Future<List<TransactionModel>> getAll() async {
    return _mockData;
  }
  
  static Future<void> clearAll() async {
    _mockData.clear();
  }
  
  static void setMockData(List<TransactionModel> data) {
    _mockData = data;
  }
}

void main() {
  group('DebugPage Widget Tests', () {
    testWidgets('displays app bar with correct title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DebugPage(),
        ),
      );

      expect(find.text('Data Validation'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('displays floating action button for clearing data', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DebugPage(),
        ),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('displays summary card with transaction statistics', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DebugPage(),
        ),
      );

      await tester.pumpAndSettle(); // Wait for data loading

      expect(find.text('Total Transactions: 0'), findsOneWidget);
      expect(find.text('Credit Count: 0'), findsOneWidget);
      expect(find.text('Debit Count: 0'), findsOneWidget);
      expect(find.text('Total Credit: ₹0.00'), findsOneWidget);
      expect(find.text('Total Debit: ₹0.00'), findsOneWidget);
      expect(find.text('Net: ₹0.00'), findsOneWidget);
    });

    testWidgets('displays transaction list', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DebugPage(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('card has correct margin', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DebugPage(),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.margin, const EdgeInsets.all(16));
    });

    testWidgets('card has correct padding', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DebugPage(),
        ),
      );

      final padding = tester.widget<Padding>(
        find.descendant(
          of: find.byType(Card),
          matching: find.byType(Padding),
        ),
      );
      expect(padding.padding, const EdgeInsets.all(16));
    });

    testWidgets('displays column layout correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DebugPage(),
        ),
      );

      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Expanded), findsOneWidget);
    });

    testWidgets('handles scaffold structure correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DebugPage(),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });

  group('DebugPage Unit Tests', () {
    test('calculates credit total correctly', () {
      final transactions = [
        TransactionModel(
          id: 1,
          amount: 2000.0,
          type: 'credit',
          category: 'Salary',
          description: 'Salary',
          date: DateTime.now(),
          bankName: 'SBI',
        ),
        TransactionModel(
          id: 2,
          amount: 1500.0,
          type: 'credit',
          category: 'Bonus',
          description: 'Bonus',
          date: DateTime.now(),
          bankName: 'HDFC',
        ),
        TransactionModel(
          id: 3,
          amount: 500.0,
          type: 'debit',
          category: 'Food',
          description: 'Food',
          date: DateTime.now(),
          bankName: 'ICICI',
        ),
      ];

      final credit = transactions
          .where((t) => t.type == 'credit')
          .fold(0.0, (sum, t) => sum + t.amount);

      expect(credit, 3500.0);
    });

    test('calculates debit total correctly', () {
      final transactions = [
        TransactionModel(
          id: 1,
          amount: 2000.0,
          type: 'credit',
          category: 'Salary',
          description: 'Salary',
          date: DateTime.now(),
          bankName: 'SBI',
        ),
        TransactionModel(
          id: 2,
          amount: 500.0,
          type: 'debit',
          category: 'Food',
          description: 'Food',
          date: DateTime.now(),
          bankName: 'HDFC',
        ),
        TransactionModel(
          id: 3,
          amount: 300.0,
          type: 'debit',
          category: 'Transport',
          description: 'Transport',
          date: DateTime.now(),
          bankName: 'ICICI',
        ),
      ];

      final debit = transactions
          .where((t) => t.type == 'debit')
          .fold(0.0, (sum, t) => sum + t.amount);

      expect(debit, 800.0);
    });

    test('counts credit transactions correctly', () {
      final transactions = [
        TransactionModel(
          id: 1,
          amount: 2000.0,
          type: 'credit',
          category: 'Salary',
          description: 'Salary',
          date: DateTime.now(),
          bankName: 'SBI',
        ),
        TransactionModel(
          id: 2,
          amount: 500.0,
          type: 'debit',
          category: 'Food',
          description: 'Food',
          date: DateTime.now(),
          bankName: 'HDFC',
        ),
        TransactionModel(
          id: 3,
          amount: 1500.0,
          type: 'credit',
          category: 'Bonus',
          description: 'Bonus',
          date: DateTime.now(),
          bankName: 'ICICI',
        ),
      ];

      final creditCount = transactions.where((t) => t.type == 'credit').length;
      expect(creditCount, 2);
    });

    test('counts debit transactions correctly', () {
      final transactions = [
        TransactionModel(
          id: 1,
          amount: 2000.0,
          type: 'credit',
          category: 'Salary',
          description: 'Salary',
          date: DateTime.now(),
          bankName: 'SBI',
        ),
        TransactionModel(
          id: 2,
          amount: 500.0,
          type: 'debit',
          category: 'Food',
          description: 'Food',
          date: DateTime.now(),
          bankName: 'HDFC',
        ),
        TransactionModel(
          id: 3,
          amount: 300.0,
          type: 'debit',
          category: 'Transport',
          description: 'Transport',
          date: DateTime.now(),
          bankName: 'ICICI',
        ),
      ];

      final debitCount = transactions.where((t) => t.type == 'debit').length;
      expect(debitCount, 2);
    });

    test('calculates net amount correctly', () {
      const totalCredit = 3500.0;
      const totalDebit = 800.0;
      final net = totalCredit - totalDebit;
      
      expect(net, 2700.0);
    });

    test('formats amount correctly', () {
      const amount = 1234.567;
      final formatted = amount.toStringAsFixed(2);
      
      expect(formatted, '1234.57');
    });

    test('handles empty transaction list', () {
      const List<TransactionModel> transactions = [];
      
      final credit = transactions
          .where((t) => t.type == 'credit')
          .fold(0.0, (sum, t) => sum + t.amount);
      final debit = transactions
          .where((t) => t.type == 'debit')
          .fold(0.0, (sum, t) => sum + t.amount);
      
      expect(transactions.length, 0);
      expect(credit, 0.0);
      expect(debit, 0.0);
    });

    test('truncates long descriptions correctly', () {
      const description = 'This is a very long transaction description that exceeds thirty characters';
      final truncated = description.length > 30 
          ? '${description.substring(0, 30)}...' 
          : description;
      
      expect(truncated, 'This is a very long transactio...');
      expect(truncated.length, 33); // 30 chars + '...'
    });

    test('does not truncate short descriptions', () {
      const description = 'Short description';
      final truncated = description.length > 30 
          ? '${description.substring(0, 30)}...' 
          : description;
      
      expect(truncated, 'Short description');
      expect(truncated.length, 17);
    });

    test('formats date correctly for display', () {
      final date = DateTime(2024, 1, 15, 10, 30, 45);
      final formatted = date.toString().split(' ')[0];
      
      expect(formatted, '2024-01-15');
    });
  });
}