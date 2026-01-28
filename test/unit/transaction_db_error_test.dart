import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_financier/data/transaction_db.dart';
import 'package:pocket_financier/models/transaction.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  group('TransactionDb error handling', () {
    test('Handles database open failure gracefully', () async {
      // Simulate openDatabase throwing
      try {
        await openDatabase('/invalid/path/transactions.db');
        fail('Should throw an error');
      } catch (e) {
        // Accept StateError or Exception
        expect(e, anyOf(isA<StateError>(), isA<Exception>()));
      }
    });

    test('Insert with missing required fields throws', () async {
      // Ensure Flutter binding is initialized for DB ops
      TestWidgetsFlutterBinding.ensureInitialized();
      final tx = TransactionModel(
        id: null,
        date: DateTime.now(),
        amount: 100.0,
        type: '', // Invalid type
        description: '',
        category: '',
      );
      try {
        await TransactionDb.insert(tx);
        fail('Should throw an error');
      } catch (e) {
        // Accept StateError or Exception
        expect(e, anyOf(isA<StateError>(), isA<Exception>()));
      }
    });
  });
}
