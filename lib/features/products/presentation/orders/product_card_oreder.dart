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
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // IMAGE
            Container(
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: product["imageUrl"] != null &&
                      product["imageUrl"].toString().isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        product["imageUrl"],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image, size: 50),
                      ),
                    )
                  : const Icon(Icons.image, size: 60, color: Colors.grey),
            ),

            const SizedBox(height: 6),

            // NAME
            Text(
              product["name"],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            // UNIT
            Text(
              product["unit"] ?? "",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 6),

            // PRICE
            Text(
              "₹${product["price"]}",
              style: const TextStyle(
                  fontSize: 18,
                  color: Colors.cyan,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            // ADD OR QTY CONTROLLER
            Expanded(
              child: SizedBox(
                height: 30,
                width: double.infinity,
                child: inCart
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () =>
                                cartNotifier.decreaseQty(product["id"]),
                          ),
                          Text(qty.toString(),
                              style: const TextStyle(fontSize: 18)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () =>
                                cartNotifier.increaseQty(product["id"]),
                          ),
                        ],
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
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
                        child: const Text("ADD TO CART",
                            style: TextStyle(color: Colors.white)),
                      ),
              ),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
