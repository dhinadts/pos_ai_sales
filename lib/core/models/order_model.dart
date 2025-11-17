class OrderModel {
  final String orderId;
  final String customerId;
  final String customerName;
  final List<OrderItem> items;
  final double subTotal;
  final double tax;
  final double discount;
  final double totalAmount;
  final DateTime orderDate;
  final String paymentMethod;
  final String orderStatus;

  OrderModel({
    required this.orderId,
    required this.customerId,
    required this.customerName,
    required this.items,
    required this.subTotal,
    required this.tax,
    required this.discount,
    required this.totalAmount,
    required this.orderDate,
    required this.paymentMethod,
    required this.orderStatus,
  });

  // ---------------------------
  // Convert to Map for SQLite
  // ---------------------------
  Map<String, dynamic> toMap() {
    return {
      "orderId": orderId,
      "customerId": customerId,
      "customerName": customerName,
      "items": items.map((e) => e.toMap()).toList(), // Store JSON
      "subTotal": subTotal,
      "tax": tax,
      "discount": discount,
      "totalAmount": totalAmount,
      "orderDate": orderDate.toIso8601String(),
      "paymentMethod": paymentMethod,
      "orderStatus": orderStatus,
    };
  }

  // ---------------------------
  // Convert from SQLite Map
  // ---------------------------
  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map["orderId"],
      customerId: map["customerId"],
      customerName: map["customerName"],
      items: (map["items"] as List<dynamic>)
          .map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      subTotal: (map["subTotal"] as num).toDouble(),
      tax: (map["tax"] as num).toDouble(),
      discount: (map["discount"] as num).toDouble(),
      totalAmount: (map["totalAmount"] as num).toDouble(),
      orderDate: DateTime.parse(map["orderDate"]),
      paymentMethod: map["paymentMethod"],
      orderStatus: map["orderStatus"],
    );
  }

  // ---------------------------
  // Convert to Firebase (Firestore)
  // ---------------------------
  Map<String, dynamic> toFirebase() {
    return {
      "orderId": orderId,
      "customerId": customerId,
      "customerName": customerName,
      "items": items.map((e) => e.toMap()).toList(),
      "subTotal": subTotal,
      "tax": tax,
      "discount": discount,
      "totalAmount": totalAmount,
      "orderDate": orderDate,
      "paymentMethod": paymentMethod,
      "orderStatus": orderStatus,
    };
  }

  // ---------------------------
  // Convert from Firebase
  // ---------------------------
  factory OrderModel.fromFirebase(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map["orderId"],
      customerId: map["customerId"],
      customerName: map["customerName"],
      items: (map["items"] as List<dynamic>)
          .map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      subTotal: (map["subTotal"] as num).toDouble(),
      tax: (map["tax"] as num).toDouble(),
      discount: (map["discount"] as num).toDouble(),
      totalAmount: (map["totalAmount"] as num).toDouble(),
      orderDate: (map["orderDate"] as dynamic).toDate(),
      paymentMethod: map["paymentMethod"],
      orderStatus: map["orderStatus"],
    );
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double total;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
  }) : total = unitPrice * quantity;

  Map<String, dynamic> toMap() {
    return {
      "productId": productId,
      "productName": productName,
      "unitPrice": unitPrice,
      "quantity": quantity,
      "total": total,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map["productId"],
      productName: map["productName"],
      unitPrice: (map["unitPrice"] as num).toDouble(),
      quantity: map["quantity"],
    );
  }
}
