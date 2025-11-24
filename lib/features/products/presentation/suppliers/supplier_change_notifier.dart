import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pos_ai_sales/core/db/suppliers/sqflite_riverpod_suppliers.dart';
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
        final firebaseService = ref.read(firebaseSuppliersServiceProvider);
        firebaseList = await firebaseService.getSuppliers();
      } else {
        final firebaseService = ref.read(firebaseSuppliersServiceProvider);

        firebaseList = await firebaseService.getSuppliers();
      }

      final mergedMap = <String, Supplier>{};

      for (final supplier in localList) {
        mergedMap[supplier.supplierId.toString()] = supplier;
      }

      for (final supplier in firebaseList) {
        mergedMap[supplier.supplierId.toString()] = supplier;
      }

      final mergedList = mergedMap.values.toList();

      mergedList.sort((a, b) => a.name.compareTo(b.name));

      state = AsyncValue.data(mergedList);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void addSupplier(Supplier newSupplier) {
    final currentList = state.value ?? [];
    state = AsyncValue.data([newSupplier, ...currentList]);
  }

  void updateSupplier(Supplier updatedSupplier) {
    final currentList = state.value ?? [];
    final newList = currentList.map((supplier) {
      return supplier.supplierId == updatedSupplier.supplierId
          ? updatedSupplier
          : supplier;
    }).toList();

    state = AsyncValue.data(newList);
  }

  void removeSupplier(String supplierId) {
    final currentList = state.value ?? [];
    final newList = currentList
        .where((supplier) => supplier.supplierId.toString() != supplierId)
        .toList();

    state = AsyncValue.data(newList);
  }

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

  Future<void> refresh() async {
    await _loadSuppliers();
  }

  void searchSuppliers(String query) {
    if (query.isEmpty) {
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
