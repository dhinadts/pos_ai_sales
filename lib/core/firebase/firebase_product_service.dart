import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_ai_sales/core/models/product.dart';


class FirebaseProductsService {
  final _db = FirebaseFirestore.instance;
  final collection = "Products";

  Future<void> addProduct(Product product) async {
    await _db
        .collection(collection)
        .doc(product.productId.toString())
        .set(product.toFirebaseMap());
  }

  Future<List<Product>> getProducts() async {
    final snapshot = await _db
        .collection(collection)
        .where("deleted", isEqualTo: 0)
        .orderBy("name")
        .get();

    return snapshot.docs
        .map((doc) => Product.fromFirebaseMap(doc.data()))
        .toList();
  }

  Future<void> updateProduct(Product product) async {
    await _db
        .collection(collection)
        .doc(product.productId.toString())
        .update(product.toFirebaseMap());
  }

  Future<void> deleteProduct(String productId) async {
    await _db.collection(collection).doc(productId).delete();
  }

  Future<List<Product>> loadAll() async {
    return await getProducts();
  }
}

final firebaseProductsServiceProvider = Provider<FirebaseProductsService>((
  ref,
) {
  return FirebaseProductsService();
});
final ProductListProviderFirebase = FutureProvider<List<Product>>((
  ref,
) async {
  final service = ref.read(firebaseProductsServiceProvider);
  return await service.getProducts();
});
