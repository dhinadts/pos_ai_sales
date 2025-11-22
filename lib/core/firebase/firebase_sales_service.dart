import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "/features/products/presentation/all_sales_transactions/sales_modal.dart"
    as t;

class FirebaseSalesTransactionsService {
  final _db = FirebaseFirestore.instance;
  final collection = "sales";

  Future<void> addSale(t.Transaction sale) async {
    await _db
        .collection(collection)
        .doc(sale.transactionId.toString())
        .set(sale.toMap());
  }

  Future<List<t.Transaction>> getAllSales() async {
    final snapshot = await _db
        .collection(collection)
        .orderBy("orderDate", descending: true)
        .get();
    return snapshot.docs.map((e) => t.Transaction.fromMap(e.data())).toList();
  }

  Future<void> deleteSale(String saleId) async {
    await _db.collection(collection).doc(saleId).delete();
  }

  Future<List<t.Transaction>> loadAll() async {
    return await getAllSales();
  }
}

final firebaseSalesTransactionsProvider =
    Provider<FirebaseSalesTransactionsService>((ref) {
      return FirebaseSalesTransactionsService();
    });
final firebaseSalesTransactionsProviderFirebase = FutureProvider<List<t.Transaction>>((
  ref,
) async {
  final service = ref.read(firebaseSalesTransactionsProvider);
  return await service.getAllSales();
});
