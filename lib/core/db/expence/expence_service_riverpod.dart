import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_ai_sales/core/db/pos_db_service.dart';
import 'package:pos_ai_sales/core/models/expense.dart';

/// provider
final ExpenseRepoProvider = Provider<ExpenseRepo>((ref) {
  return ExpenseRepo(PosDbService());
});

/// repository
class ExpenseRepo {
  final PosDbService db;
  ExpenseRepo(this.db);

  Future<int> save(Expense c) async {
    final db = await this.db.database;
    return await db.insert('expenses', c.toSqliteMap());
  }

  Future<List<Expense>> all() async {
    final db = await this.db.database;
    final rows = await db.query(
      'expenses',
      where: 'deleted = ?',
      whereArgs: [0],
    );
    return rows.map(Expense.fromSqliteMap).toList();
  }

  Future<Expense?> byId(String id) async {
    final db = await this.db.database;
    final rows = await db.query(
      'expenses',
      where: 'expenseId = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return Expense.fromSqliteMap(rows.first);
  }

  Future<int> update(Expense c) async {
    final db = await this.db.database;
    return await db.update(
      'expenses',
      c.toSqliteMap(),
      where: 'expenseId = ?',
      whereArgs: [c.expenseId],
    );
  }

  // SOFT DELETE → set deleted = 1
  Future<int> softDelete(String id) async {
    final db = await this.db.database;
    return await db.update(
      'expenses',
      {'deleted': 1},
      where: 'expenseId = ?',
      whereArgs: [id.toString()],
    );
  }

  // HARD DELETE → remove row
  Future<int> hardDelete(String id) async {
    final db = await this.db.database;
    return await db.delete(
      'expenses',
      where: 'expenseId = ?',
      whereArgs: [id.toString()],
    );
  }

  Future<void> close() async {
    final database = await db.database;
    await database.close();
  }
}

final ExpenseListProvider = FutureProvider<List<Expense>>((ref) async {
  return ref.read(ExpenseRepoProvider).all();
});
