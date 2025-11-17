import 'package:intl/intl.dart';
import 'package:uuid/uuid_value.dart';

class Supplier {
  final UuidValue supplierId;
  final String name;
  final String? contactName;
  final String? email;
  final String? phone;
  final String? address;
  final String? imagePath;
  final DateTime? lastModified;
  int deleted = 0;

  Supplier({
    required this.supplierId,
    required this.name,
    this.contactName,
    this.email,
    this.phone,
    this.address,
    this.imagePath,
    this.lastModified,
    this.deleted = 0,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      supplierId: UuidValue(json['supplierId'] as String),
      name: json['name'] as String,
      contactName: json['contactName'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      imagePath: json['imagePath'] as String?,
      lastModified: DateTime.fromMillisecondsSinceEpoch(
        json['lastModified'] as int,
      ),
      deleted: json['deleted'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplierId': supplierId,
      'contactName': contactName,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'imagePath': imagePath,
      'lastModified': lastModified,
      'deleted': deleted,
    };
  }

  Supplier copyWith({
    String? supplierId,
    String? name,
    String? contactName,
    String? email,
    String? phone,
    String? address,
    int? lastModified,
    bool? deleted,
  }) {
    return Supplier(
      supplierId: supplierId != null ? UuidValue(supplierId) : this.supplierId,
      name: name ?? this.name,
      contactName: contactName ?? this.contactName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      imagePath: imagePath ?? this.imagePath,
      lastModified: lastModified != null
          ? DateTime.fromMillisecondsSinceEpoch(lastModified)
          : this.lastModified,
      deleted: this.deleted,
    );
  }

  // sqlite map
  Map<String, dynamic> toSqliteMap() {
    return {
      "supplierId": supplierId.toString(),
      "name": name,
      "contactName": contactName,
      "email": email,
      "phone": phone,
      "address": address,

      "lastModified": lastModified != null
          ? DateFormat('dd-MM-yyyy').format(lastModified!)
          : null,
      "deleted": deleted,
    };
  }

  factory Supplier.fromSqliteMap(Map<String, dynamic> m) {
    DateTime? parsedDate;
    if (m["lastModified"] != null && m["lastModified"].toString().isNotEmpty) {
      try {
        parsedDate = DateFormat('dd-MM-yyyy').parse(m["lastModified"]);
      } catch (_) {
        parsedDate = null;
      }
    }
    return Supplier(
      supplierId: UuidValue(m["supplierId"]),
      contactName: m['contactName'] ?? '',
      name: m["name"] ?? "",
      email: m["email"] ?? "",
      phone: m["phone"] ?? "",
      address: m["address"] ?? "",

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
