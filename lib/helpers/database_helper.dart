import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart';
import 'package:untitled/models/transaction.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static sql.Database? _database;

  DatabaseHelper._init();

  Future<sql.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expenses.db');
    return _database!;
  }

  Future<sql.Database> _initDB(String filePath) async {
    final dbPath = await sql.getDatabasesPath();
    final path = join(dbPath, filePath);

    return await sql.openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(sql.Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';

    await db.execute('''
CREATE TABLE transactions ( 
  id $idType, 
  title $textType,
  amount $realType,
  date $textType,
  type $textType,
  category $textType
  )
''');
  }

  Future<int> create(Transaction transaction) async {
    final db = await instance.database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<Transaction?> readTransaction(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      'transactions',
      columns: ['id', 'title', 'amount', 'date', 'type', 'category'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Transaction.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Transaction>> readAllTransactions() async {
    final db = await instance.database;
    const orderBy = 'date DESC';
    final result = await db.query('transactions', orderBy: orderBy);

    return result.map((json) => Transaction.fromMap(json)).toList();
  }

  Future<int> update(Transaction transaction) async {
    final db = await instance.database;
    return db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await instance.database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
