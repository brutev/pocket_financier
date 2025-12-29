import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/transaction.dart';

class TransactionDb {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'transactions.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE transactions(id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, amount REAL, type TEXT, description TEXT, category TEXT)',
        );
      },
    );
  }

  static Future<int> insert(TransactionModel tx) async {
    final db = await database;
    
    // Check for duplicate
    final existing = await db.query(
      'transactions',
      where: 'date = ? AND amount = ? AND type = ? AND description = ?',
      whereArgs: [tx.date.toIso8601String(), tx.amount, tx.type, tx.description],
    );
    
    if (existing.isNotEmpty) return 0; // Skip duplicate
    
    return await db.insert('transactions', tx.toMap());
  }

  static Future<List<TransactionModel>> getAll() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('transactions', orderBy: 'date DESC');
    return List.generate(maps.length, (i) => TransactionModel.fromMap(maps[i]));
  }

  static Future<void> clearAll() async {
    final db = await database;
    await db.delete('transactions');
  }
}