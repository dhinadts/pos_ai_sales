import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_ai_sales/core/db/pos_db_service.dart';
import 'package:pos_ai_sales/core/models/customer.dart';

/// provider
final customerRepoProvider = Provider<CustomerRepo>((ref) {
  return CustomerRepo(PosDbService());
});

/// repository
class CustomerRepo {
  final PosDbService db;
  CustomerRepo(this.db);

  Future<int> save(Customer c) async {
    final db = await this.db.database;
    return await db.insert('customers', c.toSqliteMap());
  }

  Future<List<Customer>> all() async {
    final db = await this.db.database;
    final rows = await db.query(
      'customers',
      where: 'deleted = ?',
      whereArgs: [0],
    );
    return rows.map(Customer.fromSqliteMap).toList();
  }

  Future<Customer?> byId(String id) async {
    final db = await this.db.database;
    final rows = await db.query(
      'customers',
      where: 'customerId = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return Customer.fromSqliteMap(rows.first);
  }

  Future<int> update(Customer c) async {
    final db = await this.db.database;
    return await db.update(
      'customers',
      c.toSqliteMap(),
      where: 'customerId = ?',
      whereArgs: [c.customerId],
    );
  }

  // SOFT DELETE → set deleted = 1
  Future<int> softDelete(String id) async {
    final db = await this.db.database;
    return await db.update(
      'customers',
      {'deleted': 1},
      where: 'customerId = ?',
      whereArgs: [id.toString()],
    );
  }

  // HARD DELETE → remove row
  Future<int> hardDelete(String id) async {
    final db = await this.db.database;
    return await db.delete(
      'products',
      where: 'productId = ?',
      whereArgs: [id.toString()],
    );
  }

  Future<void> close() async {
    final database = await db.database;
    await database.close();
  }
}

final customerListProvider = FutureProvider<List<Customer>>((ref) async {
  return ref.read(customerRepoProvider).all();
});