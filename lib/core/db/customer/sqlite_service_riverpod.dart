import 'package:flutter/foundation.dart'; // This imports kIsWeb
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_ai_sales/core/db/pos_db_service.dart';
import 'package:pos_ai_sales/core/firebase/firebase_customers_service.dart';
import 'package:pos_ai_sales/core/models/customer.dart';
import 'package:sqflite/sqflite.dart';

/// Providers
final posDbServiceProvider = Provider<PosDbService>((ref) => PosDbService());

final customerRepoProvider = Provider<CustomerRepo>((ref) {
  final dbService = ref.read(posDbServiceProvider);
  return CustomerRepo(dbService);
});

final firebaseCustomersServiceProvider = Provider<FirebaseCustomersService>((
  ref,
) {
  return FirebaseCustomersService();
});

/// Repository
class CustomerRepo {
  final PosDbService dbService;

  CustomerRepo(this.dbService);

  Future<int> save(Customer c) async {
    final db = await dbService.database;
    return await db.insert(
      'customers',
      c.toSqliteMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Customer>> all() async {
    final db = await dbService.database;
    final rows = await db.query(
      'customers',
      where: 'deleted = ?',
      whereArgs: [0],
    );
    return rows.map(Customer.fromSqliteMap).toList();
  }

  Future<Customer?> byId(String id) async {
    final db = await dbService.database;
    final rows = await db.query(
      'customers',
      where: 'customerId = ? AND deleted = ?',
      whereArgs: [id, 0],
    );
    if (rows.isEmpty) return null;
    return Customer.fromSqliteMap(rows.first);
  }

  Future<int> update(Customer c) async {
    final db = await dbService.database;
    return await db.update(
      'customers',
      c.toSqliteMap(),
      where: 'customerId = ?',
      whereArgs: [
        c.customerId.toString(),
      ], // Fixed: convert UuidValue to String
    );
  }

  // SOFT DELETE → set deleted = 1
  Future<int> softDelete(String id) async {
    final db = await dbService.database;
    return await db.update(
      'customers',
      {'deleted': 1, 'lastModified': DateTime.now().millisecondsSinceEpoch},
      where: 'customerId = ?',
      whereArgs: [id],
    );
  }

  // HARD DELETE → remove row
  Future<int> hardDelete(String id) async {
    final db = await dbService.database;
    return await db.delete(
      'customers',
      where: 'customerId = ?',
      whereArgs: [id],
    );
  }

  // Search customers
  Future<List<Customer>> search(String query) async {
    if (query.isEmpty) return all();

    final db = await dbService.database;
    final rows = await db.query(
      'customers',
      where: '''
        (name LIKE ? OR email LIKE ? OR phone LIKE ?) 
        AND deleted = ?
      ''',
      whereArgs: ['%$query%', '%$query%', '%$query%', 0],
    );
    return rows.map(Customer.fromSqliteMap).toList();
  }
}

/// Firebase Customer List Provider
final customerListProviderFirebase = FutureProvider.autoDispose<List<Customer>>(
  (ref) async {
    final firebaseService = ref.read(firebaseCustomersServiceProvider);
    return await firebaseService.getCustomers();
  },
);

/// SQLite Customer List Provider
final customerListProviderLocal = FutureProvider.autoDispose<List<Customer>>((
  ref,
) async {
  if (kIsWeb) {
    // sqflite does NOT work reliably on Web, return empty list
    return [];
  }

  try {
    final repo = ref.read(customerRepoProvider);
    final customers = await repo.all();
    return customers;
  } catch (e) {
    // If SQLite fails, return empty list instead of crashing
    debugPrint('SQLite error: $e');
    return [];
  }
});

/// Combined Customer List Provider
final customerListProvider = FutureProvider.autoDispose<List<Customer>>((
  ref,
) async {
  if (kIsWeb) {
    // Web: Use Firebase only
    return await ref.watch(customerListProviderFirebase.future);
  }

  // Mobile: Try to get both, but handle failures gracefully
  try {
    final localFuture = ref.watch(customerListProviderLocal.future);
    final firebaseFuture = ref.watch(customerListProviderFirebase.future);

    final results = await Future.wait([
      localFuture,
      firebaseFuture,
    ], eagerError: false);
    final localList = results[0] as List<Customer>;
    final firebaseList = results[1] as List<Customer>;

    // Merge without duplicates using customerId
    final mergedMap = <String, Customer>{};

    for (final customer in localList) {
      mergedMap[customer.customerId.toString()] = customer;
    }

    for (final customer in firebaseList) {
      mergedMap[customer.customerId.toString()] = customer;
    }

    final mergedList = mergedMap.values.toList();

    // Sort by name (optional)
    mergedList.sort((a, b) => a.name.compareTo(b.name));

    return mergedList;
  } catch (e) {
    // If any source fails, return whatever we have
    debugPrint('Error merging customer lists: $e');

    try {
      // Try to get at least one source
      final localList = await ref.watch(customerListProviderLocal.future);
      return localList;
    } catch (_) {
      try {
        final firebaseList = await ref.watch(
          customerListProviderFirebase.future,
        );
        return firebaseList;
      } catch (_) {
        return []; // Both failed, return empty list
      }
    }
  }
});

/// Individual Customer Provider
final customerProvider = FutureProvider.autoDispose.family<Customer?, String>((
  ref,
  customerId,
) async {
  if (kIsWeb) {
    final firebaseService = ref.read(firebaseCustomersServiceProvider);
    return await firebaseService.byId(customerId);
  }

  // Mobile: Try SQLite first, then Firebase
  try {
    final repo = ref.read(customerRepoProvider);
    final localCustomer = await repo.byId(customerId);
    if (localCustomer != null) return localCustomer;
  } catch (e) {
    debugPrint('SQLite error fetching customer: $e');
  }

  // Fallback to Firebase
  try {
    final firebaseService = ref.read(firebaseCustomersServiceProvider);
    return await firebaseService.byId(customerId);
  } catch (e) {
    debugPrint('Firebase error fetching customer: $e');
    return null;
  }
});

/* import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_ai_sales/core/db/pos_db_service.dart';
import 'package:pos_ai_sales/core/firebase/firebase_customers_service.dart';
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
      'customers',
      where: 'customerId = ?',
      whereArgs: [id.toString()],
    );
  }

  Future<void> close() async {
    final database = await db.database;
    await database.close();
  }
}

/* final customerListProvider = FutureProvider<List<Customer>>((ref) async {
  return ref.read(customerRepoProvider).all();
}); */

/* final customerListProvider = FutureProvider.autoDispose<List<Customer>>((
  ref,
) async {
  final repo = ref.read(customerRepoProvider);
  final customers = await repo.all();
  return customers;
}); */
final customerListProviderLocal = FutureProvider.autoDispose<List<Customer>>((
  ref,
) async {
  if (kIsWeb) {
    // sqflite does NOT work on Web
    return [];
  }

  final repo = ref.read(customerRepoProvider);
  final customers = await repo.all();
  return customers;
});

final customerListProvider = FutureProvider.autoDispose<List<Customer>>((
  ref,
) async {
  List<Customer> firebaseList = [];
  List<Customer> localList = [];

  if (kIsWeb) {
    firebaseList = await ref.watch(customerListProviderFirebase.future);
    return firebaseList;
  }

  // Mobile → fetch both sources
  localList = await ref.watch(customerListProviderLocal.future);
  firebaseList = await ref.watch(customerListProviderFirebase.future);

  // merge without duplicates
  final merged = {...localList, ...firebaseList}.toList();
  return merged;
});

// Firebase Customer Service
final firebaseCustomersServiceProvider = Provider<FirebaseCustomersService>((
  ref,
) {
  return FirebaseCustomersService();
});

// SQLite Customer Service
final sqliteCustomersServiceProvider = Provider<CustomerRepo>((ref) {
  return CustomerRepo(PosDbService());
});
 */
