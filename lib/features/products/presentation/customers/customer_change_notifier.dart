import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pos_ai_sales/core/db/customer/sqlite_service_riverpod.dart';
import 'package:pos_ai_sales/core/models/customer.dart';

class CustomerListNotifier extends StateNotifier<AsyncValue<List<Customer>>> {
  final Ref ref;

  CustomerListNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    state = const AsyncValue.loading();
    try {
      List<Customer> firebaseList = [];
      List<Customer> localList = [];

      if (kIsWeb) {
        final firebaseService = ref.read(firebaseCustomersServiceProvider);
        firebaseList = await firebaseService.getCustomers();
      } else {
        final firebaseService = ref.read(firebaseCustomersServiceProvider);

        firebaseList = await firebaseService.getCustomers();
      }

      final mergedMap = <String, Customer>{};

      for (final customer in localList) {
        mergedMap[customer.customerId.toString()] = customer;
      }

      for (final customer in firebaseList) {
        mergedMap[customer.customerId.toString()] = customer;
      }

      final mergedList = mergedMap.values.toList();

      mergedList.sort((a, b) => a.name.compareTo(b.name));

      state = AsyncValue.data(mergedList);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void addCustomer(Customer newCustomer) {
    final currentList = state.value ?? [];
    state = AsyncValue.data([newCustomer, ...currentList]);
  }

  void updateCustomer(Customer updatedCustomer) {
    final currentList = state.value ?? [];
    final newList = currentList.map((customer) {
      return customer.customerId == updatedCustomer.customerId
          ? updatedCustomer
          : customer;
    }).toList();

    state = AsyncValue.data(newList);
  }

  void removeCustomer(String customerId) {
    final currentList = state.value ?? [];
    final newList = currentList
        .where((customer) => customer.customerId.toString() != customerId)
        .toList();

    state = AsyncValue.data(newList);
  }

  void deleteCustomer(String customerId) {
    final currentList = state.value ?? [];
    final newList = currentList.map((customer) {
      if (customer.customerId.toString() == customerId) {
        return customer.copyWith(deleted: 1);
      }
      return customer;
    }).toList();

    state = AsyncValue.data(newList);
  }

  Future<void> refresh() async {
    await _loadCustomers();
  }

  void searchCustomers(String query) {
    if (query.isEmpty) {
      _loadCustomers();
      return;
    }

    final currentList = state.value ?? [];
    final filteredList = currentList.where((customer) {
      return customer.name.toLowerCase().contains(query.toLowerCase()) ||
          customer.phone?.toLowerCase().contains(query.toLowerCase()) == true ||
          customer.email?.toLowerCase().contains(query.toLowerCase()) == true;
    }).toList();

    state = AsyncValue.data(filteredList);
  }
}

final customerListNotifierProvider = StateNotifierProvider.autoDispose<
    CustomerListNotifier,
    AsyncValue<List<Customer>>>((ref) => CustomerListNotifier(ref));
