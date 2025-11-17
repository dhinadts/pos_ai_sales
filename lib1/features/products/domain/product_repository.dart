import '../../../core/models/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ProductRepository {
  Future<List<Product>> getAllLocal();
  Future<void> addLocal(Product p);
  Future<void> updateLocal(Product p);
  Future<void> deleteLocal(String id);


  // Sync related
  Future<void> pushPendingToRemote(String shopId);
  Future<void> pullRemoteChanges(String shopId);
  
  
  final FirebaseFirestore firestore;
  ProductRepository(this.firestore);

  Future<void> addProduct(Product p) async {
    await firestore.collection('products').doc(p.productId.toString()).set(p.toMap());
  }

  Stream<List<Product>> watchProducts() {
    return firestore.collection('products').snapshots().map((snap) {
      return snap.docs.map((d) => Product.fromMap(d.data())).toList();
    });
  }
}
