import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('financial_notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE categories (
        id \$idType,
        name \$textType,
        type \$textType
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id \$idType,
        title \$textType,
        amount \$realType,
        date \$textType,
        category_id \$integerType,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');
    
    // Insert default categories
    await db.insert('categories', {'name': 'Gaji', 'type': 'income'});
    await db.insert('categories', {'name': 'Makanan', 'type': 'expense'});
    await db.insert('categories', {'name': 'Transportasi', 'type': 'expense'});
  }

  // --- Category CRUD ---
  Future<int> insertCategory(CategoryModel category) async {
    final db = await instance.database;
    return await db.insert('categories', category.toMap());
  }

  Future<List<CategoryModel>> getAllCategories() async {
    final db = await instance.database;
    final maps = await db.query('categories');
    return maps.map((map) => CategoryModel.fromMap(map)).toList();
  }

  Future<int> deleteCategory(int id) async {
    final db = await instance.database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // --- Transaction CRUD ---
  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await instance.database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await instance.database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<List<Map<String, dynamic>>> getAllTransactionsWithCategory() async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT t.*, c.name as category_name, c.type as category_type
      FROM transactions t
      JOIN categories c ON t.category_id = c.id
      ORDER BY t.date DESC
    ''');
  }

  Future<int> deleteTransaction(int id) async {
    final db = await instance.database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}
