import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_ai_sales/core/firebase/firebase_product_service.dart';
import 'package:pos_ai_sales/core/utilits/responsive_design.dart';
import 'package:pos_ai_sales/features/products/presentation/Widgets/product_card.dart';
import 'package:pos_ai_sales/features/products/presentation/products/product_change_notifier.dart';
import 'package:uuid/uuid.dart';
import 'package:pos_ai_sales/core/models/product.dart';

class ProductListPage extends ConsumerWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = ref.watch(responsiveProvider);
    final productsAsync = ref.watch(productsListNotifierProvider);

    return WillPopScope(
      onWillPop: () async {
        context.go('/home');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xff00B4F0),
          title: const Text('All Products'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => context.go('/home'),
          ),
        ),
        body: Container(
          color: Colors.white,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search here...",
                    suffixIcon: const Icon(Icons.search, color: Colors.blue),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 1),
                      borderRadius: BorderRadius.zero,
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 1),
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onChanged: (query) {
                    // Add search functionality
                    ref
                        .read(productsListNotifierProvider.notifier)
                        .searchProducts(query);
                  },
                ),
              ),
              Expanded(
                child: productsAsync.when(
                  data: (products) {
                    if (products.isEmpty) {
                      return const Center(
                        child: Text('No products found'),
                      );
                    }
                    return ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ProductCard(
                          id: product.productId,
                          name: product.name,
                          code: product.code,
                          category: product.category,
                          sellPrice: product.sellPrice,
                          stock: product.stock,
                          imagePath: product.imagePath,
                          onEdit: () => context.go(
                              '/products/edit/${product.productId}?mode=edit'),
                          onDelete: () async {
                            await _deleteProduct(
                                ref, product.productId.toString());
                          },
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: $error'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              ref.refresh(productsListNotifierProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            final newId = const Uuid().v4();
            context.go('/products/edit/$newId?mode=add');
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> _deleteProduct(WidgetRef ref, String productId) async {
    final confirmed = await showDialog<bool>(
      context: ref.context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Remove from UI immediately
        ref
            .read(productsListNotifierProvider.notifier)
            .removeProduct(productId);

        // Delete from Firebase
        final firebaseService = ref.read(firebaseProductsServiceProvider);
        await firebaseService.deleteProduct(productId);

        ScaffoldMessenger.of(ref.context).showSnackBar(
          const SnackBar(content: Text('Product deleted successfully')),
        );
      } catch (e) {
        // Refresh if deletion failed
        ref.read(productsListNotifierProvider.notifier).refresh();
        ScaffoldMessenger.of(ref.context).showSnackBar(
          SnackBar(content: Text('Failed to delete product: $e')),
        );
      }
    }
  }
}
