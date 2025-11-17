import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_ai_sales/core/models/supplier.dart';

class FirebaseSuppliersService {
  final _db = FirebaseFirestore.instance;
  final collection = "suppliers";

  Future<void> addSupplier(Supplier supplier) async {
    await _db
        .collection(collection)
        .doc(supplier.supplierId.toString())
        .set(supplier.toMap());
  }

  Future<List<Supplier>> getSuppliers() async {
    final snapshot = await _db.collection(collection).orderBy("name").get();
    return snapshot.docs.map((e) => Supplier.fromMap(e.data())).toList();
  }

  Future<void> updateSupplier(Supplier supplier) async {
    await _db
        .collection(collection)
        .doc(supplier.supplierId.toString())
        .update(supplier.toMap());
  }

  Future<void> deleteSupplier(String supplierId) async {
    await _db.collection(collection).doc(supplierId).delete();
  }

  Future<List<Supplier>> loadAll() async {
    return await getSuppliers();
  }
}

final firebaseCustomersServiceProvider = Provider<FirebaseSuppliersService>((
  ref,
) {
  return FirebaseSuppliersService();
});
final customerListProviderFirebase = FutureProvider<List<Supplier>>((
  ref,
) async {
  final service = ref.read(firebaseCustomersServiceProvider);
  return await service.getSuppliers();
});
