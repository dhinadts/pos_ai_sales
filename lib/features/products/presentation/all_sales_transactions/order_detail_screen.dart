// features/orders/presentation/order_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_ai_sales/features/products/presentation/all_sales_transactions/order_repo.dart';

class OrderDetailsScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(orderProvider.notifier).getOrderById(orderId);

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Order Not Found')),
        body: Center(child: Text('Order #$orderId not found')),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        // Handle back button press
        context.go('/home');
        return true; // Return false to prevent back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.cyan,
          title: Text('Order #$orderId'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => context.go('/orders'),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order Details',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      _buildDetailRow(
                          'Order Date:', _formatDate(order.orderDate)),
                      _buildDetailRow('Customer:', order.customerName),
                      _buildDetailRow('Order Type:', order.orderType),
                      _buildDetailRow('Payment Method:', order.paymentMethod),
                      _buildDetailRow('Status:', order.status),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Items List
              Text('Items Ordered',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Expanded(
                child: ListView.builder(
                  itemCount: order.items.length,
                  itemBuilder: (context, index) {
                    final item = order.items[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: Icon(Icons.shopping_bag),
                        title: Text(item.productName),
                        subtitle: Text('${item.unit} • ₹${item.price} each'),
                        trailing: Text(
                            'x${item.quantity} = ₹${item.total.toStringAsFixed(2)}'),
                      ),
                    );
                  },
                ),
              ),

              // Total Section
              Card(
                color: Colors.cyan[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildTotalRow('Subtotal:', order.subtotal),
                      _buildTotalRow('Tax (15%):', order.taxAmount),
                      _buildTotalRow('Discount:', -order.discount),
                      Divider(),
                      _buildTotalRow('Final Total:', order.finalTotal,
                          isBold: true),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 10),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text('₹${amount.toStringAsFixed(2)}',
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
