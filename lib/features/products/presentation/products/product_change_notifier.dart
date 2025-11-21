import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pos_ai_sales/core/firebase/firebase_product_service.dart';
import 'package:pos_ai_sales/core/models/product.dart';

class ProductListNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final Ref ref;

  ProductListNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    state = const AsyncValue.loading();
    try {
      final firebaseService = ref.read(firebaseProductsServiceProvider);
      final products = await firebaseService.getProducts();

      // Sort by name
      products.sort((a, b) => a.name.compareTo(b.name));

      state = AsyncValue.data(products);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Add new product and update state immediately
  void addProduct(Product newProduct) {
    final currentList = state.value ?? [];
    state = AsyncValue.data([newProduct, ...currentList]);
  }

  // Update existing product
  void updateProduct(Product updatedProduct) {
    final currentList = state.value ?? [];
    final newList = currentList.map((product) {
      return product.productId == updatedProduct.productId
          ? updatedProduct
          : product;
    }).toList();

    state = AsyncValue.data(newList);
  }

  // Remove product
  void removeProduct(String productId) {
    final currentList = state.value ?? [];
    final newList = currentList
        .where((product) => product.productId.toString() != productId)
        .toList();

    state = AsyncValue.data(newList);
  }

  // Refresh the list from Firebase
  Future<void> refresh() async {
    await _loadProducts();
  }

  // Search products
  void searchProducts(String query) {
    if (query.isEmpty) {
      _loadProducts();
      return;
    }

    final currentList = state.value ?? [];
    final filteredList = currentList.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.code?.toLowerCase().contains(query.toLowerCase()) == true ||
          product.category?.toLowerCase().contains(query.toLowerCase()) == true;
    }).toList();

    state = AsyncValue.data(filteredList);
  }
}

final productsListNotifierProvider = StateNotifierProvider.autoDispose<
    ProductListNotifier,
    AsyncValue<List<Product>>>((ref) => ProductListNotifier(ref));
