import 'package:intl/intl.dart';

class SalesRecord {
  final int? id; // local DB id
  final DateTime date;
  final String code; // always non-null
  final String productName;
  final int qty;
  final double unitPrice;
  final double total;

  // Additional product details
  final String? status;
  final String? category;
  final String? brand;
  final String? unit;
  final String? tax;
  final double? cost;
  final double? mrp;
  final String? tamilDescription;
  final String? hindiDescription;
  final String? teluguDescription;
  final String? kannadaDescription;
  final String? malayalamDescription;
  final String? hsnCode;
  final String? sku;
  final String? supplier;
  final String? manufacturer;
  final String? expiryDate;
  final String? batchNumber;

  SalesRecord({
    this.id,
    required this.date,
    this.code = '', // ✅ default to empty
    required this.productName,
    required this.qty,
    required this.unitPrice,
    required this.total,

    // Additional fields
    this.status = 'Active',
    this.category = 'General',
    this.brand = 'Unknown',
    this.unit = 'Pieces',
    this.tax = '0%',
    this.cost,
    this.mrp,
    this.tamilDescription,
    this.hindiDescription,
    this.teluguDescription,
    this.kannadaDescription,
    this.malayalamDescription,
    this.hsnCode,
    this.sku,
    this.supplier,
    this.manufacturer,
    this.expiryDate,
    this.batchNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': DateFormat('dd-MM-yyyy').format(date), // store as ISO date
      // 'date': DateFormat('yyyy-MM-dd').format(date),
      'code': code,
      'productName': productName,
      'qty': qty,
      'unitPrice': unitPrice,
      'total': total,
      'amount': total, // Add this for chart compatibility
      // Additional fields
      'status': status,
      'category': category,
      'brand': brand,
      'unit': unit,
      'tax': tax,
      'cost': cost,
      'mrp': mrp,
      'tamilDescription': tamilDescription,
      'hindiDescription': hindiDescription,
      'teluguDescription': teluguDescription,
      'kannadaDescription': kannadaDescription,
      'malayalamDescription': malayalamDescription,
      'hsnCode': hsnCode,
      'sku': sku,
      'supplier': supplier,
      'manufacturer': manufacturer,
      'expiryDate': expiryDate,
      'batchNumber': batchNumber,
    };
  }

  factory SalesRecord.fromMap(Map<String, dynamic> m) {
    // handle flexible data types
    return SalesRecord(
      id: m['id'] is int ? m['id'] : int.tryParse(m['id']?.toString() ?? ''),
      date: parseDate(m['date']),
      code: (m['code'] ?? '').toString(), // ✅ default empty if null
      productName: (m['productName'] ?? '').toString(),
      qty: (m['qty'] is int)
          ? m['qty']
          : int.tryParse(m['qty']?.toString() ?? '') ?? 0,
      unitPrice: (m['unitPrice'] is double)
          ? m['unitPrice']
          : double.tryParse(m['unitPrice']?.toString() ?? '') ?? 0.0,
      total: (m['total'] is double)
          ? m['total']
          : double.tryParse(m['total']?.toString() ?? '') ?? 0.0,

      // Additional fields with safe parsing
      status: m['status']?.toString() ?? 'Active',
      category: m['category']?.toString() ?? 'General',
      brand: m['brand']?.toString() ?? 'Unknown',
      unit: m['unit']?.toString() ?? 'Pieces',
      tax: m['tax']?.toString() ?? '0%',
      cost: (m['cost'] is double)
          ? m['cost']
          : double.tryParse(m['cost']?.toString() ?? ''),
      mrp: (m['mrp'] is double)
          ? m['mrp']
          : double.tryParse(m['mrp']?.toString() ?? ''),
      tamilDescription: m['tamilDescription']?.toString(),
      hindiDescription: m['hindiDescription']?.toString(),
      teluguDescription: m['teluguDescription']?.toString(),
      kannadaDescription: m['kannadaDescription']?.toString(),
      malayalamDescription: m['malayalamDescription']?.toString(),
      hsnCode: m['hsnCode']?.toString(),
      sku: m['sku']?.toString(),
      supplier: m['supplier']?.toString(),
      manufacturer: m['manufacturer']?.toString(),
      expiryDate: m['expiryDate']?.toString(),
      batchNumber: m['batchNumber']?.toString(),
    );
  }

  /// Helper to parse both 'dd-MM-yyyy' and 'yyyy-MM-dd'
  static DateTime parseDate(dynamic value) {
    if (value == null) return DateTime.now();

    final str = value.toString().trim();

    try {
      // yyyy-MM-dd
      if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(str)) {
        return DateFormat('yyyy-MM-dd').parse(str);
      }

      // dd-MM-yyyy
      if (RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(str)) {
        return DateFormat('dd-MM-yyyy').parse(str);
      }

      // Fallback
      return DateTime.parse(str);
    } catch (_) {
      return DateTime.now();
    }
  }

  // Helper method to calculate profit
  double get profitPerUnit {
    if (cost == null) return 0.0;
    return unitPrice - cost!;
  }

  double get totalProfit {
    return profitPerUnit * qty;
  }

  double get profitMargin {
    if (unitPrice == 0) return 0.0;
    return (profitPerUnit / unitPrice) * 100;
  }

  // Helper method to check if product is expired
  bool get isExpired {
    if (expiryDate == null) return false;
    try {
      final expiry = DateTime.parse(expiryDate!);
      return expiry.isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }
}


/* import 'package:intl/intl.dart';

class SalesRecord {
  final int? id; // local DB id
  final DateTime date;
  final String code; // always non-null
  final String productName;
  final int qty;
  final double unitPrice;
  final double total;

  SalesRecord({
    this.id,
    required this.date,
    this.code = '', // ✅ default to empty
    required this.productName,
    required this.qty,
    required this.unitPrice,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': DateFormat('yyyy-MM-dd').format(date), // store as ISO date
      'code': code,
      'productName': productName,
      'qty': qty,
      'unitPrice': unitPrice,
      'total': total,
      'amount': total, // Add this for chart compatibility
    };
  }

  factory SalesRecord.fromMap(Map<String, dynamic> m) {
    // handle flexible data types
    return SalesRecord(
      id: m['id'] is int ? m['id'] : int.tryParse(m['id']?.toString() ?? ''),
      date: parseDate(m['date']),
      code: (m['code'] ?? '').toString(), // ✅ default empty if null
      productName: (m['productName'] ?? '').toString(),
      qty: (m['qty'] is int)
          ? m['qty']
          : int.tryParse(m['qty']?.toString() ?? '') ?? 0,
      unitPrice: (m['unitPrice'] is double)
          ? m['unitPrice']
          : double.tryParse(m['unitPrice']?.toString() ?? '') ?? 0.0,
      total: (m['total'] is double)
          ? m['total']
          : double.tryParse(m['total']?.toString() ?? '') ?? 0.0,
    );
  }

  /// Helper to parse both 'dd-MM-yyyy' and 'yyyy-MM-dd'
  static DateTime parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    final str = value.toString();
    try {
      if (str.contains('-')) {
        // Try both common formats
        if (str.split('-')[0].length == 4) {
          // yyyy-MM-dd
          return DateFormat('yyyy-MM-dd').parse(str);
        } else {
          // dd-MM-yyyy
          return DateFormat('dd-MM-yyyy').parse(str);
        }
      }
      // fallback to default parse
      return DateTime.parse(str);
    } catch (_) {
      return DateTime.now();
    }
  }
}
 */