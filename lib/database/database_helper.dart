import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('click_clack.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      return await openDatabase(
        filePath,
        version: 2,
        onCreate: _createDB,
        onUpgrade: _onUpgrade,
      );
    } else {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);

      return await openDatabase(
        path,
        version: 2,
        onCreate: _createDB,
        onUpgrade: _onUpgrade,
      );
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createUsersTable(db);
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        seller_name TEXT NOT NULL,
        seller_phone TEXT NOT NULL,
        brand TEXT NOT NULL,
        category TEXT NOT NULL,
        model_name TEXT NOT NULL,
        description TEXT NOT NULL,
        condition TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        image_path TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        items TEXT NOT NULL,
        customer_name TEXT NOT NULL,
        customer_phone TEXT NOT NULL,
        address TEXT NOT NULL,
        postal_code TEXT NOT NULL,
        shipping_type TEXT NOT NULL,
        shipping_fee REAL NOT NULL,
        total_price REAL NOT NULL,
        order_date TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    await _createUsersTable(db);
  }

  Future<void> _createUsersTable(Database db) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        email TEXT NOT NULL,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        phone TEXT NOT NULL,
        dob TEXT NOT NULL,
        age INTEGER NOT NULL,
        address TEXT NOT NULL
      )
    ''');
  }

  // Auth Methods
  Future<int> registerUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> loginUser(String username, String password) async {
    final db = await database;
    final res = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (res.isNotEmpty) {
      return User.fromMap(res.first);
    }
    return null;
  }

  Future<bool> isUsernameTaken(String username) async {
    final db = await database;
    final res = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return res.isNotEmpty;
  }

  // Product CRUD
  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(String id) async {
    final db = await database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Product?> getProduct(String id) async {
    final db = await database;
    final maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Product.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final result = await db.query('products', orderBy: 'created_at DESC');
    return result.map((json) => Product.fromMap(json)).toList();
  }

  // Order CRUD
  Future<int> insertOrder(Order order) async {
    final db = await database;
    return await db.insert('orders', order.toMap());
  }

  Future<List<Order>> getAllOrders() async {
    final db = await database;
    final result = await db.query('orders', orderBy: 'order_date DESC');
    return result.map((json) => Order.fromMap(json)).toList();
  }

  Future<void> close() async {
    final db = await database;
    if (db.isOpen) {
      await db.close();
    }
  }
}
