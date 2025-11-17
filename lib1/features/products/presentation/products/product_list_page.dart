import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_ai_sales/core/db/products/sqlite_service_riverpod.dart';
import 'package:pos_ai_sales/features/products/presentation/Widgets/product_card.dart';
import 'package:uuid/uuid.dart';
import 'package:pos_ai_sales/core/models/product.dart';

class ProductListPage extends ConsumerWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productListProvider);
    debugPrint('Products loaded: ${products.toString()}');
    return WillPopScope(
      onWillPop: () async {
        context.go('/home'); // go to home
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
                padding: EdgeInsets.all(12),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search here...",
                    suffixIcon: Icon(Icons.search, color: Colors.blue),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 1),
                      borderRadius: BorderRadius.zero,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 1),
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: products.when(
                  data: (list) => ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      Product p = list[index]; // the product model
                      UuidValue id = p.productId; // use actual product id
                      debugPrint("Product: $p");

                      return ProductCard(
                        id: p.productId,
                        name: p.name,
                        code: p.code,
                        category: p.category,
                        sellPrice: p.sellPrice,
                        stock: p.stock,
                        imagePath: p.imagePath,
                        onEdit: () =>
                            context.go('/products/edit/$id?mode=edit'),
                        onDelete: () async {
                          await ref.read(deleteProductProvider)(id.toString());
                          ref.invalidate(productListProvider); // refresh list
                        },
                      );
                    },
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text(e.toString())),
                ),
              ),
            ],
          ),
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () {
            final UuidValue id = Uuid().v4obj();
            context.go('/products/edit/$id?mode=add');
          }, // ✅ fixed
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
