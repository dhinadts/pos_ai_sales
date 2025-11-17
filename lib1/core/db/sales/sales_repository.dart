// lib/core/db/sales/sales_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../pos_db_service.dart';
import 'package:uuid/uuid_value.dart';

final salesRepoProvider = Provider<SalesRepository>((ref) {
  return SalesRepository(PosDbService());
});

class SalesRepository {
  final PosDbService _db;
  SalesRepository(this._db);

  Future<void> insertSale(Map<String, dynamic> data) async {
    final db = await _db.database;
    await db.insert("sales", data);
  }

  Future<List<Map<String, dynamic>>> getSales() async {
    final db = await _db.database;
    return await db.query("sales");
  }

  Future<Map<String, dynamic>?> getSaleById(String id) async {
    final db = await _db.database;
    final r = await db.query("sales", where: "saleId = ?", whereArgs: [id]);
    return r.isNotEmpty ? r.first : null;
  }

  Future<void> updateSale(UuidValue id, Map<String, dynamic> data) async {
    final db = await _db.database;
    await db.update(
      "sales",
      data,
      where: "saleId = ?",
      whereArgs: [id.toString()],
    );
  }

  Future<void> deleteSale(String id) async {
    final db = await _db.database;
    await db.delete("sales", where: "saleId = ?", whereArgs: [id]);
  }
}
