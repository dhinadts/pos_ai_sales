// features/orders/presentation/orders_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_ai_sales/features/products/presentation/all_sales_transactions/order_repo.dart';

class OrdersListScreen extends ConsumerWidget {
  const OrdersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(orderProvider);

    return WillPopScope(
      onWillPop: () async {
        // Handle back button press
        context.go('/home');
        return false; // Return false to prevent back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Sales Transactions'),
          backgroundColor: Colors.cyan,
          leading: IconButton(
            onPressed: () {
              context.go('/home');
            },
            icon: Icon(Icons.arrow_back_ios),
          ),
        ),
        body: orders.isEmpty
            ? Center(child: Text('No orders found'))
            : ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: Icon(Icons.receipt, color: Colors.cyan),
                      title: Text('Order #${order.orderId}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Customer: ${order.customerName}'),
                          Text('Date: ${_formatDate(order.orderDate)}'),
                          Text(
                              'Total: ₹${order.finalTotal.toStringAsFixed(2)}'),
                        ],
                      ),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        context.go('/order-details/${order.orderId}');
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
