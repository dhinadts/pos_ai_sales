// providers/order_provider.dart
import 'package:flutter_riverpod/legacy.dart';
import 'package:pos_ai_sales/features/products/presentation/all_sales_transactions/Order_model_transaction.dart';
import 'package:pos_ai_sales/features/products/presentation/orders/cart_model.dart';

class OrderNotifier extends StateNotifier<List<SalesOrder>> {
  OrderNotifier() : super([]);

  // Generate unique order ID
  String _generateOrderId() {
    final now = DateTime.now();
    return 'ORD${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
  }

  // Add new order
  String addOrder({
    required String customerName,
    required String orderType,
    required String paymentMethod,
    required double subtotal,
    required double taxAmount,
    required double discount,
    required double finalTotal,
    required List<CartItem> cartItems,
  }) {
    final orderId = _generateOrderId();

    final orderItems = cartItems
        .map((cartItem) => OrderItem(
              productId: cartItem.id,
              productName: cartItem.name,
              unit: cartItem.unit,
              price: cartItem.price,
              quantity: cartItem.quantity,
            ))
        .toList();

    final newOrder = SalesOrder(
      orderId: orderId,
      orderDate: DateTime.now(),
      customerName: customerName,
      orderType: orderType,
      paymentMethod: paymentMethod,
      subtotal: subtotal,
      taxAmount: taxAmount,
      discount: discount,
      finalTotal: finalTotal,
      items: orderItems,
    );

    state = [newOrder, ...state];
    return orderId;
  }

  // Get order by ID
  SalesOrder? getOrderById(String orderId) {
    try {
      return state.firstWhere((order) => order.orderId == orderId);
    } catch (e) {
      return null;
    }
  }

  // Get all orders
  List<SalesOrder> getAllOrders() {
    return state;
  }

  // Get orders by date range
  List<SalesOrder> getOrdersByDateRange(DateTime start, DateTime end) {
    return state
        .where((order) =>
            order.orderDate.isAfter(start.subtract(Duration(days: 1))) &&
            order.orderDate.isBefore(end.add(Duration(days: 1))))
        .toList();
  }

  // Delete order
  void deleteOrder(String orderId) {
    state = state.where((order) => order.orderId != orderId).toList();
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, List<SalesOrder>>(
  (ref) => OrderNotifier(),
);
