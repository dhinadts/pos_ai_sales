import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_ai_sales/core/db/pos_db_service.dart';
import 'package:pos_ai_sales/core/firebase/firebase_suppliers_service.dart';
import 'package:pos_ai_sales/core/models/supplier.dart';

/// provider
final SupplierRepoProvider = Provider<SuppliersRepo>((ref) {
  return SuppliersRepo(PosDbService());
});

/// repository
class SuppliersRepo {
  final PosDbService db;
  SuppliersRepo(this.db);

  Future<int> save(Supplier c) async {
    final db = await this.db.database;
    return await db.insert('suppliers', c.toSqliteMap());
  }

  Future<List<Supplier>> all() async {
    final db = await this.db.database;
    final rows = await db.query(
      'suppliers',
      where: 'deleted = ?',
      whereArgs: [0],
    );
    return rows.map(Supplier.fromSqliteMap).toList();
  }

  Future<Supplier?> byId(String id) async {
    final db = await this.db.database;
    final rows = await db.query(
      'suppliers',
      where: 'supplierId = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return Supplier.fromSqliteMap(rows.first);
  }

  Future<int> update(Supplier c) async {
    final db = await this.db.database;
    return await db.update(
      'suppliers',
      c.toSqliteMap(),
      where: 'supplierId = ?',
      whereArgs: [c.supplierId],
    );
  }

  // SOFT DELETE → set deleted = 1
  Future<int> softDelete(String id) async {
    final db = await this.db.database;
    return await db.update(
      'suppliers',
      {'deleted': 1},
      where: 'supplierId = ?',
      whereArgs: [id.toString()],
    );
  }

  // HARD DELETE → remove row
  Future<int> hardDelete(String id) async {
    final db = await this.db.database;
    return await db.delete(
      'suppliers',
      where: 'supplierId = ?',
      whereArgs: [id.toString()],
    );
  }

  Future<void> close() async {
    final database = await db.database;
    await database.close();
  }
}

/* final supplierListProvider = FutureProvider<List<Supplier>>((ref) async {
  return ref.read(SupplierRepoProvider).all();
}); */
final supplierListProvider =
    FutureProvider.autoDispose<List<Supplier>>((ref) async {
  try {
    debugPrint('📱 Loading customers from Firebase...');

    final firebaseService = ref.read(firebaseCustomersServiceProvider);
    final customers = await firebaseService.getSuppliers();

    debugPrint('✅ Loaded ${customers.length} customers from Firebase');

    // Sort by name
    customers.sort((a, b) => a.name.compareTo(b.name));

    return customers;
  } catch (e) {
    debugPrint('❌ Error loading customers from Firebase: $e');

    // Show error in UI but return empty list to prevent crashes
    return [];
  }
});

// final customerListProvider = FutureProvider<List<Customer>>((ref) async {
//   return ref.read(customerRepoProvider).all();
// });

final firebaseSuppliersServiceProvider = Provider<FirebaseSuppliersService>((
  ref,
) {
  return FirebaseSuppliersService();
});
