// lib/core/db/orders/orders_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../pos_db_service.dart';
import 'package:uuid/uuid_value.dart';

final ordersRepoProvider = Provider<OrdersRepository>((ref) {
  return OrdersRepository(PosDbService());
});

class OrdersRepository {
  final PosDbService _db;
  OrdersRepository(this._db);

  Future<void> insertOrder(Map<String, dynamic> data) async {
    final db = await _db.database;
    await db.insert("orders", data);
  }

  Future<List<Map<String, dynamic>>> getOrders() async {
    final db = await _db.database;
    return await db.query("orders");
  }

  Future<Map<String, dynamic>?> getOrderById(String id) async {
    final db = await _db.database;
    final r = await db.query("orders", where: "orderId = ?", whereArgs: [id]);
    return r.isNotEmpty ? r.first : null;
  }

  Future<void> updateOrder(UuidValue id, Map<String, dynamic> data) async {
    final db = await _db.database;
    await db.update(
      "orders",
      data,
      where: "orderId = ?",
      whereArgs: [id.toString()],
    );
  }

  Future<void> deleteOrder(String id) async {
    final db = await _db.database;
    await db.delete("orders", where: "orderId = ?", whereArgs: [id]);
  }
}
