import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart';
import 'package:untitled/models/transaction.dart';

class DatabaseHelper {
  // Singleton pattern: ensure only one instance of DatabaseHelper exists
  static final DatabaseHelper instance = DatabaseHelper._init();
  static sql.Database? _database;
  DatabaseHelper._init();
  // Getter to get the database instance; initializes if null
  Future<sql.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expenses.db');
    return _database!;
  }

  // Set up the database file path on the device
  Future<sql.Database> _initDB(String filePath) async {
    final dbPath = await sql.getDatabasesPath();
    final path = join(dbPath, filePath);

    return await sql.openDatabase(
      path,
      version: 6,
      onCreate: _createDB,

      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < newVersion) {
          await db.execute("DROP TABLE IF EXISTS goods");
          await db.execute("DROP TABLE IF EXISTS earn_src");
          await db.execute("DROP TABLE IF EXISTS transactions");
          await _createDB(db, newVersion);
        }
      },
    );
  }

  // Create the database tables : This runs only the first time the DB is created
  Future<void> _createDB(sql.Database db, int version) async {
    // Definining common types to avoid typos
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT';
    const realType = 'REAL NOT NULL';
    const intType = 'INTEGER';

    // 1. Master Table: Stores the main transaction info
    await db.execute('''
CREATE TABLE transactions ( 
  id $idType, 
  title TEXT NOT NULL,
  amount $realType,
  date TEXT NOT NULL,
  type TEXT NOT NULL,
  desc TEXT
  )
''');

    // 2. Child Table (Goods): Links to transactions via 'transaction_id'
    // FOREIGN KEY ensures that you can't have goods without a valid transaction
    // ON DELETE CASCADE means: if a transaction is deleted, its goods are also deleted

    await db.execute('''
     CREATE TABLE goods (
     id $idType,
     transaction_id TEXT NOT NULL,
     name TEXT,
     price $realType,
     quantity $intType,
     date TEXT,
     desc TEXT,
     category TEXT,
     FOREIGN KEY (transaction_id) REFERENCES transactions (id) ON DELETE CASCADE
     )
    ''');
  }
  // Strategic Method: Saves transaction and all nested lists in one go
  Future<void> createTransaction(Transaction tx) async {
    final db = await instance.database;
    // We use a 'transaction' block to ensure atomicity
    // If saving goods fails, the main transaction record won't be saved either
    await db.transaction((txn) async {
      // Step A: Insert the core transaction data
      await txn.insert('transactions', {
        'id': tx.id,
        'title': tx.title,
        'amount': tx.amount,
        'date': tx.date.toIso8601String(),
        'type': tx.type.name,
      });

      // Step B: Loop through goods list and insert each item with the parent's ID
      if (tx.goods != null) {
        for (var item in tx.goods!) {
          var goodsMap = item.toMap();
          goodsMap['transaction_id'] = tx.id;
          await txn.insert('goods', goodsMap);
        }
      }
    });
  }

  Future<Transaction?> readTransaction(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final txId = maps.first['id'] as String;

      final goodsData = await db.query(
        'goods',
        where: 'transaction_id = ?',
        whereArgs: [txId],
      );

      Map<String, dynamic> fullMap = Map<String, dynamic>.from(maps.first);
      fullMap['goods'] = goodsData;

      return Transaction.fromMap(fullMap);
    } else {
      return null;
    }
  }

  // Retrieval: Re-building the complex Transaction object from flat SQL tables
  Future<List<Transaction>> readAllTransactions() async {
    final db = await instance.database;
    const orderBy = 'date DESC';
    final result = await db.query('transactions', orderBy: orderBy);

    List<Transaction> txList = [];

    for (var row in result) {
      String txId = row['id'] as String;

      final goodsData = await db.query(
        'goods',
        where: 'transaction_id = ?',
        whereArgs: [txId],
      );


      Map<String, dynamic> fullMap = Map<String, dynamic>.from(row);
      fullMap['goods'] = goodsData;

      txList.add(Transaction.fromMap(fullMap));
    }

    return txList;
  }

  Future<void> updateTransaction(Transaction tx) async {
    final db = await instance.database;

    await db.transaction((txn) async {
      await txn.update(
        'transactions',
        {
          'title': tx.title,
          'amount': tx.amount,
          'date': tx.date.toIso8601String(),
          'type': tx.type.name,
        },
        where: 'id = ?',
        whereArgs: [tx.id],
      );

      // 2. Clear old sub-data to avoid duplicates or orphaned rows
      await txn.delete(
        'goods',
        where: 'transaction_id = ?',
        whereArgs: [tx.id],
      );
      await txn.delete(
        'earn_src',
        where: 'transaction_id = ?',
        whereArgs: [tx.id],
      );

      if (tx.goods != null) {
        for (var item in tx.goods!) {
          var goodsMap = item.toMap();
          goodsMap['transaction_id'] = tx.id;
          await txn.insert('goods', goodsMap);
        }
      }
    });
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
