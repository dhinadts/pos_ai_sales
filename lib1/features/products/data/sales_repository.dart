import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../domain/sales_record.dart';

class SalesRepository {
  static final SalesRepository _instance = SalesRepository._internal();
  factory SalesRepository() => _instance;
  SalesRepository._internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final docs = await getApplicationDocumentsDirectory();
    final path = join(docs.path, 'sales_reports.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, ver) async {
        await db.execute('''
CREATE TABLE sales(
id INTEGER PRIMARY KEY AUTOINCREMENT,
date TEXT,
code TEXT,
productName TEXT,
qty INTEGER,
unitPrice REAL,
total REAL
)
''');
      },
    );
  }

  Future<int> insertRecord(SalesRecord r) async {
    final database = await db;
    return await database.insert('sales', r.toMap());
  }

  Future<int> insertBatch(List<SalesRecord> list) async {
    final database = await db;
    return await database.transaction((txn) async {
      int count = 0;
      for (final r in list) {
        await txn.insert('sales', r.toMap());
        count++;
      }
      return count;
    });
  }

  Future<List<SalesRecord>> fetchAll() async {
    final database = await db;
    final rows = await database.query('sales', orderBy: 'date ASC');
    return rows.map((r) => SalesRecord.fromMap(r)).toList();
  }

  Future<List<SalesRecord>> fetchBetween(DateTime from, DateTime to) async {
    final database = await db;
    final rows = await database.query(
      'sales',
      where: 'date >= ? AND date <= ?',
      whereArgs: [
        from.toIso8601String().split('T').first,
        to.toIso8601String().split('T').first,
      ],
      orderBy: 'date ASC',
    );
    return rows.map((r) => SalesRecord.fromMap(r)).toList();
  }

  Future<void> clearAll() async {
    final database = await db;
    await database.delete('sales');
  }

  Future<void> insertMany(List<SalesRecord> records) async {
    final database = await db;
    await database.transaction((txn) async {
      for (final r in records) {
        await txn.insert('sales', r.toMap());
      }
    });
  }
}
