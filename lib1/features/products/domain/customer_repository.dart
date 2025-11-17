import '../../../core/models/customer.dart';

abstract class CustomerRepository {
  Future<List<Customer>> getAllLocal();
  Future<void> addLocal(Customer c);
  Future<void> updateLocal(Customer c);
  Future<void> deleteLocal(String customerId);

  // Sync related
  Future<void> pushPendingToRemote(String customerId);
  Future<void> pullRemoteChanges(String customerId);
}
