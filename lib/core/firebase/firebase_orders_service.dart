import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_ai_sales/core/models/order_model.dart';

class FirebaseOrdersService {
  final _db = FirebaseFirestore.instance;
  final collection = "orders";

  Future<void> addOrder(OrderModel order) async {
    await _db.collection(collection).doc(order.orderId).set(order.toMap());
  }

  Future<List<OrderModel>> getAllOrders() async {
    final snapshot = await _db
        .collection(collection)
        .orderBy("orderDate", descending: true)
        .get();
    return snapshot.docs.map((e) => OrderModel.fromMap(e.data())).toList();
  }

  Future<void> updateOrder(OrderModel order) async {
    await _db.collection(collection).doc(order.orderId).update(order.toMap());
  }

  Future<void> deleteOrder(String orderId) async {
    await _db.collection(collection).doc(orderId).delete();
  }

  Future<List<OrderModel>> loadAll() async {
    return await getAllOrders();
  }
}

final firebaseOrdersServiceProvider = Provider<FirebaseOrdersService>((ref) {
  return FirebaseOrdersService();
});
final customerListProviderFirebase = FutureProvider<List<OrderModel>>((
  ref,
) async {
  final service = ref.read(firebaseOrdersServiceProvider);
  return await service.getAllOrders();
});
