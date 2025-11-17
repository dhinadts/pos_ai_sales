import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_ai_sales/core/models/customer.dart';

class FirebaseCustomersService {
  final _db = FirebaseFirestore.instance;
  final String collection = "customers";

  /// Add customer
  Future<void> addCustomer(Customer customer) async {
    final docId = customer.customerId.toString(); // ensure it is a string

    await _db.collection(collection).doc(docId).set({
      ...customer.toFirebaseMap(),
      "createdAt": FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<Customer> byId(String id) async {
    try {
      final snapshot = await _db
          .collection(collection)
          .where("customerId", isEqualTo: id)
          .limit(1) // Limit to 1 result for efficiency
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception('Customer with id $id not found');
      }

      final doc = snapshot.docs.first;
      final data = doc.data(); // as Map<String, dynamic>;

      return Customer.fromJson(data);
    } catch (e) {
      print('Error fetching customer by id $id: $e');
      rethrow;
    }
  }

  /// Update customer
  Future<void> updateCustomer(Customer customer) async {
    final docId = customer.customerId.toString();

    await _db.collection(collection).doc(docId).update({
      ...customer.toFirebaseMap(),
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  /// Soft delete support
  Future<void> deleteCustomer(String customerId) async {
    await _db.collection(collection).doc(customerId).update({
      "deleted": 1,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  /// Get all active customers
  Future<List<Customer>> getCustomers() async {
    final snapshot = await _db
        .collection(collection)
        .where("deleted", isEqualTo: 0)
        // .orderBy("name", descending: false)
        .get();

    return snapshot.docs
        .map((doc) => Customer.fromFirebaseMap(doc.data()))
        .toList();
  }

  /// Alias for loading
  Future<List<Customer>> loadAll() => getCustomers();
}

/// Service provider
final firebaseCustomersServiceProvider = Provider<FirebaseCustomersService>((
  ref,
) {
  return FirebaseCustomersService();
});

/// Customer list provider
final customerListProviderFirebase = FutureProvider<List<Customer>>((
  ref,
) async {
  final service = ref.read(firebaseCustomersServiceProvider);
  return service.getCustomers();
});
