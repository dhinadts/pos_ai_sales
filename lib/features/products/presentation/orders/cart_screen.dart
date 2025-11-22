// Update your cart_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_ai_sales/core/models/customer.dart';
import 'package:pos_ai_sales/core/utilits/thermal_printer/bluetooth_printer_service.dart';
import 'package:pos_ai_sales/features/products/presentation/Widgets/common_button.dart';
import 'package:pos_ai_sales/features/products/presentation/all_sales_transactions/order_repo.dart';
import 'package:pos_ai_sales/features/products/presentation/orders/payment_dialog.dart';
import 'package:pos_ai_sales/features/products/presentation/orders/print_option_dialogue.dart';
import 'package:pos_ai_sales/features/products/presentation/orders/printer_utility.dart';
import 'cart_provider.dart';

class CartScreen extends ConsumerWidget {
  // const CartScreen({super.key});

// Update your _processOrder method in CartScreen
  Future<void> _processOrder({
    required BuildContext context,
    required WidgetRef ref,
    required String customer,
    required String orderType,
    required String paymentMethod,
    required String discount,
  }) async {
    final cartController = ref.read(cartProvider.notifier);
    final orderController = ref.read(orderProvider.notifier);
    final items = cartController.items;

    final subtotal = cartController.subtotal;
    final tax = cartController.taxAmount;
    final finalTotal = cartController.finalTotal;
    final discountValue = double.tryParse(discount) ?? 0.0;

    try {
      // Save order to database/provider
      final orderId = orderController.addOrder(
        customerName: customer,
        orderType: orderType,
        paymentMethod: paymentMethod,
        subtotal: subtotal,
        taxAmount: tax,
        discount: discountValue,
        finalTotal: finalTotal - discountValue,
        cartItems: items,
      );

      // PRINT RECEIPT with order ID
      final printer = PrinterManager();
      await printer.printCartOrder(
        items: items,
        subtotal: subtotal,
        tax: tax,
        discount: discountValue,
        finalTotal: finalTotal - discountValue,
        customer: customer,
        orderType: orderType,
        paymentMethod: paymentMethod,
        orderId: orderId, // Pass order ID to receipt
      );

      // Clear cart
      cartController.clearCart();

      // Close dialog
      if (context.mounted) {
        Navigator.of(context).pop();

        // Show success message with order ID
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order #$orderId submitted successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );

        // Optionally show order details
        _showOrderConfirmation(context, orderId, ref);
      }
    } catch (e) {
      // Handle errors
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

// Show order confirmation with details
  void _showOrderConfirmation(
      BuildContext context, String orderId, WidgetRef ref) {
    final order = ref.read(orderProvider.notifier).getOrderById(orderId);

    if (order != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Order Confirmed'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order ID: $orderId'),
              Text('Customer: ${order.customerName}'),
              Text('Total: ₹${order.finalTotal.toStringAsFixed(2)}'),
              SizedBox(height: 10),
              Text('Items:'),
              ...order.items
                  .map((item) =>
                      Text('  • ${item.productName} x${item.quantity}'))
                  .toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to order details screen
                context.go('/order-details/$orderId');
              },
              child: Text('View Details'),
            ),
          ],
        ),
      );
    }
  }

// Replace your current print call with:
  void _handlePrintReceipt(
      BuildContext context,
      List<Map<String, dynamic>> items,
      double subtotal,
      double tax,
      double discountValue,
      finalTotal,
      String customer,
      String orderType,
      String paymentMethod) {
    showDialog(
      context: context,
      builder: (context) => PrintOptionsDialog(
        items: items,
        subtotal: subtotal,
        tax: tax,
        discount: discountValue,
        finalTotal: finalTotal - discountValue,
        customer: customer,
        orderType: orderType,
        paymentMethod: paymentMethod,
      ),
    );
  }

// Or call directly for PDF only:
  void _downloadPdfOnly(
      List<Map<String, dynamic>> items,
      double subtotal,
      double tax,
      double discountValue,
      double finalTotal,
      String customer,
      String orderType,
      String paymentMethod) async {
    await PrinterUtil.downloadAndOpenPdf(
      items: items,
      subtotal: subtotal,
      tax: tax,
      discount: discountValue,
      finalTotal: finalTotal - discountValue,
      customer: customer,
      orderType: orderType,
      paymentMethod: paymentMethod,
    );
  }

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    final cartController = ref.read(cartProvider.notifier);

    if (cartController.totalPrice > 0) {
      _showSubmitDialog(
        context,
        ref,
        cartController.subtotal,
        cartController.taxAmount,
        cartController.finalTotal,
      );
    }
  }

  void _showSubmitDialog(
    BuildContext context,
    WidgetRef ref,
    double subtotal,
    double tax,
    double finalTotal,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return PaymentDialog(
          onOrderSubmit: (customer, orderType, paymentMethod, discount) {
            _processOrder(
              context: context,
              ref: ref,
              customer: customer,
              orderType: orderType,
              paymentMethod: paymentMethod,
              discount: discount,
            );
          },
        );
      },
    );
  }

  /*  Future<void> _processOrder({
    required BuildContext context,
    required WidgetRef ref,
    required String customer,
    required String orderType,
    required String paymentMethod,
    required String discount,

  }) async {
    final cartController = ref.read(cartProvider.notifier);
    final items = cartController.items;

    final subtotal = cartController.subtotal;
    final tax = cartController.taxAmount;
    final finalTotal = cartController.finalTotal;
    final discountValue = double.tryParse(discount) ?? 0.0;

    try {
      // PRINT RECEIPT
      final printer = PrinterManager();
      await printer.printCartOrder(
        items: items,
        subtotal: subtotal,
        tax: tax,
        discount: discountValue,
        finalTotal: finalTotal - discountValue,
        customer: customer,
        orderType: orderType,
        paymentMethod: paymentMethod,
      );

      // Clear cart
      cartController.clearCart();

      // Close dialog
      if (context.mounted) {
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Order submitted successfully! ${kIsWeb ? 'Receipt opened in new tab.' : ''}'),
            backgroundColor: Colors.green,
          ),
        );

        // Redirect after a delay
        Future.delayed(Duration(seconds: 2), () {
          if (context.mounted) {
            context.go('/orders');
          }
        });
      }
    } catch (e) {
      // Handle print errors
      if (context.mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Printing failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  */
  // }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartController = ref.read(cartProvider.notifier);

    return WillPopScope(
      onWillPop: () async {
        context.go('/orders');
        return false;
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isTablet = constraints.maxWidth > 600;
          final double itemFont = isTablet ? 20 : 16;
          final double priceFont = isTablet ? 22 : 18;
          final double iconSize = isTablet ? 32 : 24;
          final double cardPadding = isTablet ? 20 : 10;

          return Scaffold(
            appBar: AppBar(
                backgroundColor: Colors.cyan,
                title: Text(
                  "Product Cart",
                  style: TextStyle(fontSize: isTablet ? 26 : 20),
                ),
                centerTitle: true,
                leading: IconButton(
                    onPressed: () {
                      context.go('/orders');
                    },
                    icon: Icon(Icons.arrow_back_ios))),
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
          );
        },
      ),
    );
  }
}
