import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/transaction.dart';

class TransactionDb {
  static Database? _database;
  static const int _currentVersion = 2;

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
      version: _currentVersion,
      onCreate: (db, version) {
        _createTables(db, version);
      },
      onUpgrade: (db, oldVersion, newVersion) {
        _upgradeDatabase(db, oldVersion, newVersion);
      },
    );
  }

  static void _createTables(Database db, int version) {
    db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        transactionDate TEXT,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        accountLast4 TEXT,
        transactionMode TEXT,
        availableBalance REAL,
        bankName TEXT,
        transactionRef TEXT,
        merchantName TEXT,
        upiTransactionId TEXT
      )
    ''');
  }

  static void _upgradeDatabase(Database db, int oldVersion, int newVersion) {
    if (oldVersion < 2) {
      // Migration from version 1 to 2: Add new columns
      db.execute('ALTER TABLE transactions ADD COLUMN transactionDate TEXT');
      db.execute('ALTER TABLE transactions ADD COLUMN accountLast4 TEXT');
      db.execute('ALTER TABLE transactions ADD COLUMN transactionMode TEXT');
      db.execute('ALTER TABLE transactions ADD COLUMN availableBalance REAL');
      db.execute('ALTER TABLE transactions ADD COLUMN bankName TEXT');
      db.execute('ALTER TABLE transactions ADD COLUMN transactionRef TEXT');
      db.execute('ALTER TABLE transactions ADD COLUMN merchantName TEXT');
      db.execute('ALTER TABLE transactions ADD COLUMN upiTransactionId TEXT');
    }
  }

  static Future<int> insert(TransactionModel tx) async {
    final db = await database;
    
    // Improved duplicate detection: Use transaction reference if available,
    // otherwise fall back to amount + date + type
    if (tx.transactionRef != null && tx.transactionRef!.isNotEmpty) {
      final existing = await db.query(
        'transactions',
        where: 'transactionRef = ?',
        whereArgs: [tx.transactionRef],
      );
      if (existing.isNotEmpty) return 0; // Skip duplicate
    } else {
      // Fallback: Check by amount + effective date + type
      final effectiveDate = tx.effectiveDate;
      final existing = await db.query(
        'transactions',
        where: 'amount = ? AND (transactionDate = ? OR date = ?) AND type = ?',
        whereArgs: [
          tx.amount,
          effectiveDate.toIso8601String(),
          effectiveDate.toIso8601String(),
          tx.type,
        ],
      );
      if (existing.isNotEmpty) {
        // Additional check: if amounts match within 1 minute, likely duplicate
        final existingTx = TransactionModel.fromMap(existing.first);
        final timeDiff = (tx.effectiveDate.difference(existingTx.effectiveDate).abs().inMinutes);
        if (timeDiff < 1) return 0; // Skip duplicate
      }
    }
    
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