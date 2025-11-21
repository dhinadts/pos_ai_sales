import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_ai_sales/core/utilits/responsive_design.dart';
import 'package:pos_ai_sales/features/products/presentation/orders/product_card_oreder.dart';
import 'cart_provider.dart';
import 'cart_screen.dart';

class OrderScreen extends ConsumerStatefulWidget {
  const OrderScreen({super.key});

  @override
  ConsumerState<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen> {
  final TextEditingController searchCtrl = TextEditingController();

  final List<Map<String, dynamic>> products = [
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

  @override
  Widget build(BuildContext context) {
    final responsive = ref.watch(responsiveProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(responsiveProvider.notifier).updateFromContext(context);
    });
    final cart = ref.watch(cartProvider);

    return WillPopScope(
      onWillPop: () async {
        context.go('/home');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.cyan,
          title: Text(
            "POS",
            style: TextStyle(fontSize: responsive.text(20)),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
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
        body: Padding(
          padding: EdgeInsets.all(responsive.width(12)),
          child: Column(
            children: [
              // SEARCH BAR
              Container(
                padding: EdgeInsets.symmetric(horizontal: responsive.width(15)),
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
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        responsive.getCrossAxisCount(responsive.screenWidth),
                    childAspectRatio:
                        responsive.getAspectRatio(responsive.screenWidth),
                  ),
                  itemCount: products.length,
                  itemBuilder: (_, index) {
                    return ProductCard(product: products[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
