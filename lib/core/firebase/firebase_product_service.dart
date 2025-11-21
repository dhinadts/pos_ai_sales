import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_ai_sales/core/models/product.dart';

class FirebaseProductsService {
  final _db = FirebaseFirestore.instance;
  final String _collectionName = 'products'; // Changed to lowercase

  /* Future<void> addProduct(Product product) async {
    await _db
        .collection(_collectionName)
        .doc(product.productId.toString())
        .set(product.toFirebaseMap());
  } */

  Future<List<Product>> getProducts() async {
    final snapshot = await _db
        .collection(_collectionName)
        .where("deleted", isEqualTo: 0)
        // .orderBy("name")
        .get();

    return snapshot.docs.map((doc) {
      // Use fromFirebaseMap for Firestore data
      return Product.fromFirebaseMap(doc.data());
    }).toList();
  }

  Future<void> addProduct(Product product) async {
    // Use toFirebaseMap for Firestore data
    await _db
        .collection(_collectionName)
        .doc(product.productId.toString())
        .set(product.toFirebaseMap());
  }

  Future<void> updateProduct(Product product) async {
    // Use toFirebaseMap for Firestore data
    await _db
        .collection(_collectionName)
        .doc(product.productId.toString())
        .update(product.toFirebaseMap());
  }

  Future<Product?> getProductById(String productId) async {
    final doc = await _db.collection(_collectionName).doc(productId).get();
    if (doc.exists) {
      return Product.fromFirebaseMap(doc.data()!);
    }
    return null;
  }

  /// Soft delete support
  Future<void> deleteProduct(String customerId) async {
    await _db.collection(_collectionName).doc(customerId).update({
      "deleted": 1,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }
}

final firebaseProductsServiceProvider =
    Provider<FirebaseProductsService>((ref) {
  return FirebaseProductsService();
});
