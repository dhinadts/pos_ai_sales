// models/order_model.dart
class SalesOrder {
  final String orderId;
  final DateTime orderDate;
  final String customerName;
  final String orderType;
  final String paymentMethod;
  final double subtotal;
  final double taxAmount;
  final double discount;
  final double finalTotal;
  final List<OrderItem> items;
  final String status;

  SalesOrder({
    required this.orderId,
    required this.orderDate,
    required this.customerName,
    required this.orderType,
    required this.paymentMethod,
    required this.subtotal,
    required this.taxAmount,
    required this.discount,
    required this.finalTotal,
    required this.items,
    this.status = 'completed',
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'orderDate': orderDate.toIso8601String(),
      'customerName': customerName,
      'orderType': orderType,
      'paymentMethod': paymentMethod,
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'discount': discount,
      'finalTotal': finalTotal,
      'items': items.map((item) => item.toMap()).toList(),
      'status': status,
    };
  }

  factory SalesOrder.fromMap(Map<String, dynamic> map) {
    return SalesOrder(
      orderId: map['orderId'],
      orderDate: DateTime.parse(map['orderDate']),
      customerName: map['customerName'],
      orderType: map['orderType'],
      paymentMethod: map['paymentMethod'],
      subtotal: map['subtotal'],
      taxAmount: map['taxAmount'],
      discount: map['discount'],
      finalTotal: map['finalTotal'],
      items: List<OrderItem>.from(
          map['items']?.map((x) => OrderItem.fromMap(x)) ?? []),
      status: map['status'] ?? 'completed',
    );
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final String unit;
  final double price;
  final int quantity;
  final double total;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.unit,
    required this.price,
    required this.quantity,
  }) : total = price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'unit': unit,
      'price': price,
      'quantity': quantity,
      'total': total,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'],
      productName: map['productName'],
      unit: map['unit'],
      price: map['price'],
      quantity: map['quantity'],
    );
  }
}
