// ignore_for_file: unnecessary_type_check

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_ai_sales/core/utilits/responsive_design.dart';
import 'package:pos_ai_sales/features/products/presentation/orders/product_card_oreder.dart';
import 'package:pos_ai_sales/features/products/presentation/products/product_change_notifier.dart';
import 'cart_provider.dart';
import 'cart_screen.dart';

class OrderScreen extends ConsumerStatefulWidget {
  const OrderScreen({super.key});

  @override
  ConsumerState<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen> {
  final TextEditingController searchCtrl = TextEditingController();

/*   final List<Map<String, dynamic>> products = [
    {
      "id": "1",
      "name": "Dano Milk",
      "unit": "500 g",
      "price": 250.0,
      "stock": 10,
    },
    {
      "id": "2",
      "name": "Adata Pendrive",
      "unit": "1 Pcs",
      "price": 600.0,
      "stock": 5,
    },
  ];
 */
  @override
  Widget build(BuildContext context) {
    final responsive = ref.watch(responsiveProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(responsiveProvider.notifier).updateFromContext(context);
    });
    final cart = ref.watch(cartProvider);
    final productsAsync = ref.watch(productsListNotifierProvider);

    return WillPopScope(
      onWillPop: () async {
        context.go('/home');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.cyan,
          title: Text(
            "POS Order",
            style: TextStyle(fontSize: responsive.text(20)),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => context.go('/home'),
          ),
          actions: [
            Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.shopping_cart_outlined,
                      size: responsive.text(28)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CartScreen()),
                    );
                  },
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: cart.isEmpty
                      ? SizedBox()
                      : Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            ref
                                .read(cartProvider.notifier)
                                .cartCount
                                .toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: responsive.text(12),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          // Update responsive values
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(responsiveProvider.notifier).updateFromContext(context);
          });
          return Center(
              child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: responsive.isDesktop ? 1400 : 800,
                  ),
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.width(16),
                        vertical: responsive.height(16),
                      ),
                      child: Column(
                        children: [
                          // SEARCH BAR
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: responsive.width(15)),
                            height: responsive.height(50),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: searchCtrl,
                              style: TextStyle(fontSize: responsive.text(16)),
                              decoration: InputDecoration(
                                hintText: "Search Here...",
                                border: InputBorder.none,
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),

                          SizedBox(height: responsive.height(20)),

                          // PRODUCT GRID (responsive)
                          Expanded(
                            child: productsAsync.when(
                              loading: () =>
                                  Center(child: CircularProgressIndicator()),
                              error: (err, _) =>
                                  Center(child: Text("Error: $err")),
                              data: (products) {
                                if (products.isEmpty) {
                                  return Center(
                                      child: Text("No products found"));
                                }

                                return GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount:
                                        responsive.isDesktop ? 4 : 2,
                                    childAspectRatio:
                                        responsive.isDesktop ? 1.3 : 0.9,
                                  ),
                                  itemCount: products.length,
                                  itemBuilder: (_, index) {
                                    final product = products[index];

                                    // Ensure all values are properly converted to the right types
                                    return ProductCard(
                                      product: {
                                        "id": product.productId
                                            .toString(), // Ensure it's a string
                                        "name": product.name.toString(),
                                        "unit": product.weight.toString() ?? '',
                                        "price": product.sellPrice is double
                                            ? product.sellPrice
                                            : product.sellPrice is int
                                                ? (product.sellPrice as int)
                                                    .toDouble()
                                                : double.tryParse(product
                                                        .sellPrice
                                                        .toString()) ??
                                                    0.0,
                                        "stock": product.stock is int
                                            ? product.stock
                                            : int.tryParse(
                                                    product.stock.toString()) ??
                                                0,
                                        "imageUrl":
                                            product.imagePath?.toString() ?? ''
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ))));
        }),
      ),
    );
  }
}
