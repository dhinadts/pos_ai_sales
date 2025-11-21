import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_ai_sales/features/products/presentation/Widgets/common_button.dart';
import 'package:pos_ai_sales/features/products/presentation/orders/payment_dialog.dart';
import 'cart_provider.dart';

class CartScreen extends ConsumerWidget {
  void _showSubmitDialog(
      BuildContext context, double subtotal, double tax, double finalTotal) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return PaymentDialog(
          onOrderSubmit: (customer, orderType, paymentMethod, discount) {
            print('Customer: $customer');
            print('Order Type: $orderType');
            print('Payment: $paymentMethod');
            print('Discount: $discount');

            _processOrder(
                context, customer, orderType, paymentMethod, discount);
          },
        );
      },
    );
  }

  void _processOrder(BuildContext context, String customer, String orderType,
      String paymentMethod, String discount) {
    Navigator.of(context).pop();
    context.go('/orders');
  }

  void _submit(BuildContext context, WidgetRef ref) {
    final cartController = ref.read(cartProvider.notifier);

    if (cartController.totalPrice > 0) {
      _showSubmitDialog(
        context,
        cartController.subtotal,
        cartController.taxAmount,
        cartController.finalTotal,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartController = ref.read(cartProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet = constraints.maxWidth > 600;
        final double itemFont = isTablet ? 20 : 16;
        final double priceFont = isTablet ? 22 : 18;
        final double iconSize = isTablet ? 32 : 24;
        final double cardPadding = isTablet ? 20 : 10;

        return WillPopScope(
          onWillPop: () async {
            context.go('/orders');
            return false;
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.cyan,
              title: Text(
                "Product Cart",
                style: TextStyle(fontSize: isTablet ? 26 : 20),
              ),
              centerTitle: true,
            ),
            body: Column(
              children: [
                Expanded(
                  child: cart.isEmpty
                      ? Center(
                          child: Text(
                            "Your cart is empty",
                            style: TextStyle(
                              fontSize: isTablet ? 24 : 18,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: cart.length,
                          itemBuilder: (_, index) {
                            final item = cart.values.toList()[index];

                            return Padding(
                              padding: EdgeInsets.all(cardPadding),
                              child: Card(
                                elevation: 3,
                                child: Padding(
                                  padding: EdgeInsets.all(isTablet ? 16 : 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.image,
                                        size: isTablet ? 80 : 50,
                                      ),
                                      SizedBox(width: isTablet ? 20 : 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.name,
                                              style: TextStyle(
                                                fontSize: itemFont,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              item.unit,
                                              style:
                                                  TextStyle(fontSize: itemFont),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              "₹${item.price}",
                                              style: TextStyle(
                                                fontSize: priceFont,
                                                color: Colors.green[700],
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.delete,
                                                color: Colors.red,
                                                size: iconSize),
                                            onPressed: () => cartController
                                                .removeItem(item.id),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.remove,
                                                    size: iconSize),
                                                onPressed: () => cartController
                                                    .decreaseQty(item.id),
                                              ),
                                              Text(
                                                item.quantity.toString(),
                                                style: TextStyle(
                                                    fontSize: itemFont),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.add,
                                                    size: iconSize),
                                                onPressed: () => cartController
                                                    .increaseQty(item.id),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),

                /// Footer Price Section
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isTablet ? 30 : 20),
                  color: Colors.cyan,
                  child: Text(
                    "Total Price: ₹${cartController.totalPrice.toStringAsFixed(2)}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isTablet ? 26 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                /// Submit Button
                Padding(
                  padding: EdgeInsets.all(isTablet ? 24 : 16),
                  child: SizedBox(
                    width: isTablet ? 400 : double.infinity,
                    child: CommonButton(
                      title: 'Submit Order',
                      onPressed: () => _submit(context, ref),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
