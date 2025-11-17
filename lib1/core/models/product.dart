// lib/models/product_model.dart
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class Product {
  UuidValue productId;
  String name;
  String code;
  String category;
  String description;
  double buyPrice;
  double sellPrice;
  int stock;
  double weight;
  String weightUnit;
  String supplier;
  String? imagePath;
  DateTime? lastModified;
  int deleted = 0;

  Product({
    required this.productId,
    required this.name,
    required this.code,
    required this.category,
    required this.description,
    required this.buyPrice,
    required this.sellPrice,
    required this.stock,
    required this.weight,
    required this.weightUnit,
    required this.supplier,
    this.imagePath,
    this.lastModified,
    this.deleted = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId.toString(), // FIX ✔
      'name': name,
      'code': code,
      'category': category,
      'description': description,
      'buyPrice': buyPrice,
      'sellPrice': sellPrice,
      'stock': stock,
      'weight': weight,
      'weightUnit': weightUnit,
      'supplier': supplier,
      'imagePath': imagePath,
      'lastModified': lastModified?.millisecondsSinceEpoch, // store int ✔
      'deleted': deleted,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      productId: UuidValue(map['productId']), // FIX ✔
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      buyPrice: (map['buyPrice'] ?? 0).toDouble() ?? 0,
      sellPrice: (map['sellPrice'] ?? 0).toDouble() ?? 0,
      stock: (map['stock'] ?? 0).toInt() ?? 0,
      weight: (map['weight'] ?? 0).toDouble() ?? 0,
      weightUnit: map['weightUnit'] ?? '',
      supplier: map['supplier'] ?? '',
      imagePath: map['imagePath'] ?? '',
      lastModified: map['lastModified'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastModified'])
          : null,
      deleted: map['deleted'] ?? 0,
    );
  }

  // sqlite map
  Map<String, dynamic> toSqliteMap() {
    return {
      "productId": productId.toString(),
      "name": name,
      "code": code,
      "category": category,
      "description": description,
      "buyPrice": buyPrice,
      "sellPrice": sellPrice,
      "stock": stock,
      "weight": weight,
      "weightUnit": weightUnit,
      "supplier": supplier,
      "imagePath": imagePath,
      "lastModified": lastModified != null
          ? DateFormat('dd-MM-yyyy').format(lastModified!)
          : null,
      "deleted": deleted,
    };
  }

  factory Product.fromSqliteMap(Map<String, dynamic> m) {
    DateTime? parsedDate;
    if (m["lastModified"] != null && m["lastModified"].toString().isNotEmpty) {
      try {
        parsedDate = DateFormat('dd-MM-yyyy').parse(m["lastModified"]);
      } catch (_) {
        parsedDate = null;
      }
    }
    return Product(
      productId: UuidValue(m["productId"]),
      name: m["name"] ?? "",
      code: m["code"] ?? "",
      category: m["category"] ?? "",
      description: m["description"] ?? "",
      buyPrice: (m["buyPrice"] ?? 0).toDouble(),
      sellPrice: (m["sellPrice"] ?? 0).toDouble(),
      stock: (m["stock"] ?? 0),
      weight: (m["weight"] ?? 0).toDouble(),
      weightUnit: m["weightUnit"] ?? "",
      supplier: m["supplier"] ?? "",
      imagePath: m["imagePath"] ?? null,
      lastModified: parsedDate,
      deleted: m["deleted"] ?? 0,
    );
  }

  /// Helper: formatted date string (for UI)
  String get formattedDate {
    if (lastModified == null) return "N/A";
    return DateFormat('dd-MM-yyyy').format(lastModified!);
  }
}
