import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pos_ai_sales/core/db/customer/sqlite_service_riverpod.dart';
import 'package:pos_ai_sales/core/firebase/firebase_customers_service.dart'
    hide firebaseCustomersServiceProvider;
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
        // For web, only use Firebase
        final firebaseService = ref.read(firebaseCustomersServiceProvider);
        firebaseList = await firebaseService.getCustomers();
      } else {
        // For mobile, fetch from both SQLite and Firebase
        // final localService = ref.read(customerRepoProvider);
        final firebaseService = ref.read(firebaseCustomersServiceProvider);

        // localList = await localService.all();
        firebaseList = await firebaseService.getCustomers();
      }

      // Merge without duplicates (using customerId)
      final mergedMap = <String, Customer>{};

      for (final customer in localList) {
        mergedMap[customer.customerId.toString()] = customer;
      }

      for (final customer in firebaseList) {
        mergedMap[customer.customerId.toString()] = customer;
      }

      final mergedList = mergedMap.values.toList();

      // Sort by name (optional)
      mergedList.sort((a, b) => a.name.compareTo(b.name));

      state = AsyncValue.data(mergedList);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Add new customer and update state immediately
  void addCustomer(Customer newCustomer) {
    final currentList = state.value ?? [];
    state = AsyncValue.data([newCustomer, ...currentList]);
  }

  // Update existing customer
  void updateCustomer(Customer updatedCustomer) {
    final currentList = state.value ?? [];
    final newList = currentList.map((customer) {
      return customer.customerId == updatedCustomer.customerId
          ? updatedCustomer
          : customer;
    }).toList();

    state = AsyncValue.data(newList);
  }

  // Remove customer
  void removeCustomer(String customerId) {
    final currentList = state.value ?? [];
    final newList = currentList
        .where((customer) => customer.customerId.toString() != customerId)
        .toList();

    state = AsyncValue.data(newList);
  }

  // Mark customer as deleted (soft delete)
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

  // Refresh the list from sources
  Future<void> refresh() async {
    await _loadCustomers();
  }

  // Search customers
  void searchCustomers(String query) {
    if (query.isEmpty) {
      // If search is empty, reload original list
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
