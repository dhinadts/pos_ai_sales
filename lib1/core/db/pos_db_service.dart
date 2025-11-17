// lib/core/db/pos_db_service.dart

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

        // --------------------
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
      },
    );
  }
}
