import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_ai_sales/features/products/presentation/orders/cart_model.dart';
import 'package:pos_ai_sales/features/products/presentation/orders/cart_provider.dart';

class ProductCard extends ConsumerWidget {
  final Map<String, dynamic> product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    final inCart = cart.containsKey(product["id"]);
    final qty = inCart ? cart[product["id"]]!.quantity : 0;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Icon(Icons.image, size: 60, color: Colors.grey),
            SizedBox(height: 10),
            Text(product["name"],
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(product["unit"], style: TextStyle(color: Colors.grey)),
            SizedBox(height: 5),
            Text("\$${product["price"]}",
                style: TextStyle(fontSize: 18, color: Colors.cyan)),
            Spacer(),
            inCart
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove_circle_outline),
                        onPressed: () =>
                            cartNotifier.decreaseQty(product["id"]),
                      ),
                      Text(qty.toString(), style: TextStyle(fontSize: 18)),
                      IconButton(
                        icon: Icon(Icons.add_circle_outline),
                        onPressed: () =>
                            cartNotifier.increaseQty(product["id"]),
                      ),
                    ],
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                    ),
                    onPressed: () {
                      cartNotifier.addToCart(
                        CartItem(
                          id: product["id"],
                          name: product["name"],
                          unit: product["unit"],
                          price: product["price"],
                        ),
                      );
                    },
                    child: Text("ADD TO CART"),
                  ),
          ],
        ),
      ),
    );
  }
}
