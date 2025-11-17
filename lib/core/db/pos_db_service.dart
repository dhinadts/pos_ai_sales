// lib/core/db/pos_db_service.dart

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final posDbProvider = Provider((ref) => PosDbService());

class PosDbService {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    String path;

    if (kIsWeb) {
      // Web does NOT support getDatabasesPath()
      path = 'pos_app.db';
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, 'pos_app.db');
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createTables(db);
      },
    );
  }

  Future<void> _createTables(Database db) async {
    // CUSTOMERS TABLE
    await db.execute('''
      CREATE TABLE customers(
        customerId TEXT PRIMARY KEY,
        name TEXT,
        phone TEXT,
        email TEXT,
        address TEXT,
        imagePath TEXT,
        lastModified INTEGER,
        deleted INTEGER DEFAULT 0
      )
    ''');

    // PRODUCTS TABLE
    await db.execute('''
      CREATE TABLE products(
        productId TEXT PRIMARY KEY,
        name TEXT,
        code TEXT,
        category TEXT,
        description TEXT,
        buyPrice REAL,
        sellPrice REAL,
        stock INTEGER,
        weight REAL,
        weightUnit TEXT,
        supplier TEXT,
        imagePath TEXT,
        lastModified INTEGER,
        deleted INTEGER DEFAULT 0
      )
    ''');

    // SALES TABLE
    await db.execute('''
      CREATE TABLE sales(
        saleId TEXT PRIMARY KEY,
        orderId TEXT,
        productId TEXT,
        qty INTEGER,
        price REAL,
        discount REAL,
        tax REAL
      )
    ''');

    // SUPPLIERS TABLE
    await db.execute('''
      CREATE TABLE suppliers(
        supplierId TEXT PRIMARY KEY,
        name TEXT,
        contactName TEXT,
        phone TEXT,
        email TEXT,
        address TEXT,
        imagePath TEXT,
        lastModified INTEGER,
        deleted INTEGER DEFAULT 0
      )
    ''');

    // EXPENSES TABLE
    await db.execute('''
      CREATE TABLE expenses(
        expenseId TEXT PRIMARY KEY,
        name TEXT,
        note TEXT,
        amount TEXT,
        date TEXT,
        time TEXT,
        lastModified INTEGER,
        deleted INTEGER DEFAULT 0
      )
    ''');

    // ORDERS TABLE
    await db.execute('''
      CREATE TABLE orders(
        orderId TEXT PRIMARY KEY,
        customerId TEXT,
        customerName TEXT,
        items TEXT,
        subTotal REAL,
        tax REAL,
        discount REAL,
        totalAmount REAL,
        orderDate TEXT,
        paymentMethod TEXT,
        orderStatus TEXT
      )
    ''');
  }
}



/* // lib/core/db/pos_db_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final posDbProvider = Provider((ref) => PosDbService());

class PosDbService {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), 'pos_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // --------------------
        // CUSTOMERS TABLE
        // --------------------
        await db.execute('''
        CREATE TABLE customers(
          customerId TEXT PRIMARY KEY,
          name TEXT,
          phone TEXT,
          email TEXT,
          address TEXT,
          imagePath TEXT,
          lastModified INTEGER,
          deleted INTEGER DEFAULT 0
        )
        ''');

        // --------------------
        // PRODUCTS TABLE
        // --------------------
        await db.execute('''
        CREATE TABLE products(
          productId TEXT PRIMARY KEY,
          name TEXT,
          code TEXT,
          category TEXT,
          description TEXT,
          buyPrice REAL,
          sellPrice REAL,
          stock INTEGER,
          weight REAL,
          weightUnit TEXT,
          supplier TEXT,
          imagePath TEXT,
          lastModified INTEGER,
          deleted INTEGER DEFAULT 0
        )
        ''');

        /*         // --------------------
        // ORDERS TABLE
        // --------------------
        await db.execute('''
        CREATE TABLE orders(
          orderId TEXT PRIMARY KEY,
          customerId TEXT,
          orderDate INTEGER,
          status TEXT,
          totalAmount REAL
        )
        ''');
 */
        // --------------------
        // SALES TABLE
        // --------------------
        await db.execute('''
        CREATE TABLE sales(
          saleId TEXT PRIMARY KEY,
          orderId TEXT,
          productId TEXT,
          qty INTEGER,
          price REAL,
          discount REAL,
          tax REAL
        )
        ''');

        /// Suppliers Table
        await db.execute('''
        CREATE TABLE suppliers(
          supplierId TEXT PRIMARY KEY,
          name TEXT,
          contactName TEXT,
          phone TEXT,
          email TEXT,
          address TEXT,
          imagePath TEXT,
          lastModified INTEGER,
          deleted INTEGER DEFAULT 0
        )
        ''');

        /// Expenses Table
        await db.execute('''
        CREATE TABLE expenses(
          expenseId TEXT PRIMARY KEY,
          name TEXT,
          note TEXT,
          amount TEXT,
          date TEXT,
          time TEXT,
          lastModified INTEGER,
          deleted INTEGER DEFAULT 0
        )
        ''');
        await db.execute('''
          CREATE TABLE orders (
          orderId TEXT PRIMARY KEY,
          customerId TEXT,
          customerName TEXT,
          items TEXT,
          subTotal REAL,
          tax REAL,
          discount REAL,
          totalAmount REAL,
          orderDate TEXT,
          paymentMethod TEXT,
          orderStatus TEXT
        )
        ''');
      },
    );
  }
}
 */