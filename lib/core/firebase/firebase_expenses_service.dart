import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_ai_sales/core/firebase/firebase_customers_service.dart';
import 'package:pos_ai_sales/core/models/expense.dart';

class FirebaseExpensesService {
  final _db = FirebaseFirestore.instance;
  final collection = "expenses";

  /// ADD
  Future<void> addExpense(Expense expense) async {
    await _db
        .collection(collection)
        .doc(expense.expenseId.toString()) // must be string
        .set(expense.toFirebaseMap());
  }

  /// GET ALL (latest first)
  Future<List<Expense>> getExpenses() async {
    final snapshot = await _db
        .collection(collection)
        .orderBy("date", descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Expense.fromFirebaseMap(doc.data()))
        .toList();
  }

  /// UPDATE
  Future<void> updateExpense(Expense expense) async {
    await _db
        .collection(collection)
        .doc(expense.expenseId.toString())
        .update(expense.toFirebaseMap());
  }

  /// DELETE
  Future<void> deleteExpense(String expenseId) async {
    await _db.collection(collection).doc(expenseId).delete();
  }

  Future<List<Expense>> loadAll() async {
    return await getExpenses();
  }
}

final firebaseExpensesServiceProvider = Provider<FirebaseExpensesService>((
  ref,
) {
  return FirebaseExpensesService();
});
final customerListProviderFirebase = FutureProvider<List<Expense>>((ref) async {
  final service = ref.read(firebaseExpensesServiceProvider);
  return await service.getExpenses();
});
