import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_ai_sales/features/products/domain/sales_record.dart';

class FirebaseSalesReportService {
  final _db = FirebaseFirestore.instance;
  final collection = "sales";

  Future<List<SalesRecord>> getAllSales() async {
    final snapshot = await _db
        .collection(collection)
        .orderBy("date", descending: true)
        .get();

    return snapshot.docs.map((doc) => SalesRecord.fromMap(doc.data())).toList();
  }

  Future<List<SalesRecord>> getSalesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final snapshot = await _db
        .collection(collection)
        .where("orderDate", isGreaterThanOrEqualTo: start.toIso8601String())
        .where("orderDate", isLessThanOrEqualTo: end.toIso8601String())
        .get();

    return snapshot.docs.map((e) => SalesRecord.fromMap(e.data())).toList();
  }

  double getTotalSales(List<SalesRecord> sales) {
    return sales.fold(0.0, (sum, item) => sum + (item.total ?? 0.0));
  }

  Future<List<SalesRecord>> loadAll() async {
    return await getAllSales();
  }
}

final firebaseSalesReportProvider = Provider<FirebaseSalesReportService>((ref) {
  return FirebaseSalesReportService();
});
final customerListProviderFirebase = FutureProvider<List<SalesRecord>>((
  ref,
) async {
  final service = ref.read(firebaseSalesReportProvider);
  return await service.getAllSales();
});
