import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid_value.dart';

class ProductsSqfliteService {
  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), 'pos_app.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
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
      },
    );
  }

  // CREATE
  Future<int> insertProduct(Map<String, dynamic> data) async {
    final database = await db;
    return await database.insert('products', data);
  }

  // READ all (not deleted)
  Future<List<Map<String, dynamic>>> getProducts() async {
    final database = await db;
    return await database.query(
      'products',
      where: 'deleted = ?',
      whereArgs: [0],
    );
  }

  // READ specific product
  Future<Map<String, dynamic>?> getProductById(String id) async {
    final database = await db;
    final res = await database.query(
      'products',
      where: 'productId = ?',
      whereArgs: [id.toString()],
    );
    if (res.isNotEmpty) return res.first;
    return null;
  }

  // UPDATE
  Future<int> updateProduct(UuidValue id, Map<String, dynamic> data) async {
    final database = await db;
    return await database.update(
      'products',
      data,
      where: 'productId = ?',
      whereArgs: [id.toString()],
    );
  }

  // SOFT DELETE → set deleted = 1
  Future<int> softDelete(String id) async {
    final database = await db;
    return await database.update(
      'products',
      {'deleted': 1},
      where: 'productId = ?',
      whereArgs: [id.toString()],
    );
  }

  // HARD DELETE → remove row
  Future<int> hardDelete(String id) async {
    final database = await db;
    return await database.delete(
      'products',
      where: 'productId = ?',
      whereArgs: [id.toString()],
    );
  }

  Future<void> close() async {
    final database = _db;
    if (database != null) await database.close();
  }
}
