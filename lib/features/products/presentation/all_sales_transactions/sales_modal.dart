// Transaction Model based on your Product model structure
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
// import 'package:uuid/uuid_value.dart';

class Transaction {
  UuidValue transactionId;
  String customerName;
  String transactionCode;
  DateTime transactionDate;
  double totalAmount;
  int itemsCount;
  String paymentMethod;
  String status;
  String? notes;
  int deleted = 0;

  Transaction({
    required this.transactionId,
    required this.customerName,
    required this.transactionCode,
    required this.transactionDate,
    required this.totalAmount,
    required this.itemsCount,
    required this.paymentMethod,
    required this.status,
    this.notes,
    this.deleted = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId.toString(),
      'customerName': customerName,
      'transactionCode': transactionCode,
      'transactionDate': transactionDate.millisecondsSinceEpoch,
      'totalAmount': totalAmount,
      'itemsCount': itemsCount,
      'paymentMethod': paymentMethod,
      'status': status,
      'notes': notes,
      'deleted': deleted,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      transactionId: UuidValue(map['transactionId']),
      customerName: map['customerName'] ?? '',
      transactionCode: map['transactionCode'] ?? '',
      transactionDate: DateTime.fromMillisecondsSinceEpoch(map['transactionDate']),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      itemsCount: (map['itemsCount'] ?? 0).toInt(),
      paymentMethod: map['paymentMethod'] ?? 'Cash',
      status: map['status'] ?? 'Completed',
      notes: map['notes'],
      deleted: map['deleted'] ?? 0,
    );
  }

  /// Helper: formatted date string (for UI)
  String get formattedDate {
    return DateFormat('dd-MM-yyyy HH:mm').format(transactionDate);
  }

  /// Helper: formatted amount (for UI)
  String get formattedAmount {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(totalAmount);
  }
}

// Sample transactions data
final List<Transaction> sampleTransactions = [
  Transaction(
    transactionId: Uuid().v4obj(),
    customerName: "John Smith",
    transactionCode: "TRX-001",
    transactionDate: DateTime.now().subtract(Duration(hours: 2)),
    totalAmount: 156.75,
    itemsCount: 3,
    paymentMethod: "Credit Card",
    status: "Completed",
    notes: "Regular customer",
  ),
  Transaction(
    transactionId: Uuid().v4obj(),
    customerName: "Sarah Johnson",
    transactionCode: "TRX-002",
    transactionDate: DateTime.now().subtract(Duration(hours: 5)),
    totalAmount: 89.50,
    itemsCount: 2,
    paymentMethod: "Cash",
    status: "Completed",
  ),
  Transaction(
    transactionId: Uuid().v4obj(),
    customerName: "Mike Wilson",
    transactionCode: "TRX-003",
    transactionDate: DateTime.now().subtract(Duration(days: 1)),
    totalAmount: 234.20,
    itemsCount: 5,
    paymentMethod: "Bank Transfer",
    status: "Completed",
    notes: "Bulk order",
  ),
  Transaction(
    transactionId: Uuid().v4obj(),
    customerName: "Emily Brown",
    transactionCode: "TRX-004",
    transactionDate: DateTime.now().subtract(Duration(days: 1, hours: 3)),
    totalAmount: 67.80,
    itemsCount: 1,
    paymentMethod: "Credit Card",
    status: "Refunded",
    notes: "Product return processed",
  ),
  Transaction(
    transactionId: Uuid().v4obj(),
    customerName: "David Lee",
    transactionCode: "TRX-005",
    transactionDate: DateTime.now().subtract(Duration(days: 2)),
    totalAmount: 189.90,
    itemsCount: 4,
    paymentMethod: "Cash",
    status: "Completed",
  ),
  Transaction(
    transactionId: Uuid().v4obj(),
    customerName: "Lisa Anderson",
    transactionCode: "TRX-006",
    transactionDate: DateTime.now().subtract(Duration(days: 3)),
    totalAmount: 45.25,
    itemsCount: 1,
    paymentMethod: "Credit Card",
    status: "Pending",
    notes: "Awaiting payment confirmation",
  ),
  Transaction(
    transactionId: Uuid().v4obj(),
    customerName: "Robert Taylor",
    transactionCode: "TRX-007",
    transactionDate: DateTime.now().subtract(Duration(days: 4)),
    totalAmount: 312.40,
    itemsCount: 6,
    paymentMethod: "Bank Transfer",
    status: "Completed",
  ),
  Transaction(
    transactionId: Uuid().v4obj(),
    customerName: "Maria Garcia",
    transactionCode: "TRX-008",
    transactionDate: DateTime.now().subtract(Duration(days: 5)),
    totalAmount: 78.60,
    itemsCount: 2,
    paymentMethod: "Cash",
    status: "Completed",
  ),
];
