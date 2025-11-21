import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pos_ai_sales/core/db/suppliers/sqflite_riverpod_suppliers.dart';
// import 'package:pos_ai_sales/core/db/Supplier/sqlite_service_riverpod.dart';
import 'package:pos_ai_sales/core/models/supplier.dart';

class SupplierListNotifier extends StateNotifier<AsyncValue<List<Supplier>>> {
  final Ref ref;

  SupplierListNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadSuppliers();
  }

  Future<void> _loadSuppliers() async {
    state = const AsyncValue.loading();
    try {
      List<Supplier> firebaseList = [];
      List<Supplier> localList = [];

      if (kIsWeb) {
        // For web, only use Firebase
        final firebaseService = ref.read(firebaseSuppliersServiceProvider);
        firebaseList = await firebaseService.getSuppliers();
      } else {
        // For mobile, fetch from both SQLite and Firebase
        // final localService = ref.read(SupplierRepoProvider);
        final firebaseService = ref.read(firebaseSuppliersServiceProvider);

        // localList = await localService.all();
        firebaseList = await firebaseService.getSuppliers();
      }

      // Merge without duplicates (using supplierId)
      final mergedMap = <String, Supplier>{};

      for (final supplier in localList) {
        mergedMap[supplier.supplierId.toString()] = supplier;
      }

      for (final supplier in firebaseList) {
        mergedMap[supplier.supplierId.toString()] = supplier;
      }

      final mergedList = mergedMap.values.toList();

      // Sort by name (optional)
      mergedList.sort((a, b) => a.name.compareTo(b.name));

      state = AsyncValue.data(mergedList);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Add new Supplier and update state immediately
  void addSupplier(Supplier newSupplier) {
    final currentList = state.value ?? [];
    state = AsyncValue.data([newSupplier, ...currentList]);
  }

  // Update existing Supplier
  void updateSupplier(Supplier updatedSupplier) {
    final currentList = state.value ?? [];
    final newList = currentList.map((supplier) {
      return supplier.supplierId == updatedSupplier.supplierId
          ? updatedSupplier
          : supplier;
    }).toList();

    state = AsyncValue.data(newList);
  }

  // Remove Supplier
  void removeSupplier(String supplierId) {
    final currentList = state.value ?? [];
    final newList = currentList
        .where((supplier) => supplier.supplierId.toString() != supplierId)
        .toList();

    state = AsyncValue.data(newList);
  }

  // Mark Supplier as deleted (soft delete)
  void deleteSupplier(String supplierId) {
    final currentList = state.value ?? [];
    final newList = currentList.map((supplier) {
      if (supplier.supplierId.toString() == supplierId) {
        return supplier.copyWith(deleted: true);
      }
      return supplier;
    }).toList();

    state = AsyncValue.data(newList);
  }

  // Refresh the list from sources
  Future<void> refresh() async {
    await _loadSuppliers();
  }

  // Search Suppliers
  void searchSuppliers(String query) {
    if (query.isEmpty) {
      // If search is empty, reload original list
      _loadSuppliers();
      return;
    }

    final currentList = state.value ?? [];
    final filteredList = currentList.where((supplier) {
      return supplier.name.toLowerCase().contains(query.toLowerCase()) ||
          supplier.phone?.toLowerCase().contains(query.toLowerCase()) == true ||
          supplier.email?.toLowerCase().contains(query.toLowerCase()) == true;
    }).toList();

    state = AsyncValue.data(filteredList);
  }
}

final supplierListNotifierProvider = StateNotifierProvider.autoDispose<
    SupplierListNotifier,
    AsyncValue<List<Supplier>>>((ref) => SupplierListNotifier(ref));
