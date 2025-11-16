import 'package:intl/intl.dart';
import 'package:uuid/uuid_value.dart';

class Customer {
  final UuidValue customerId;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String? imagePath;
  final DateTime? lastModified;
  int deleted = 0;

  Customer({
    required this.customerId,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.imagePath,
    this.lastModified,
    this.deleted = 0,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: UuidValue(json['customerId'] as String),
      name: json['name'] as String,
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
      'customerId': customerId,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'imagePath': imagePath,
      'lastModified': lastModified,
      'deleted': deleted,
    };
  }

  Customer copyWith({
    String? customerId,
    String? name,
    String? email,
    String? phone,
    String? address,
    int? lastModified,
    bool? deleted,
  }) {
    return Customer(
      customerId: customerId != null ? UuidValue(customerId) : this.customerId,
      name: name ?? this.name,
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
      "customerId": customerId.toString(),
      "name": name,
      "email": email,
      "phone": phone,
      "address": address,
      "lastModified": lastModified?.millisecondsSinceEpoch,
      "deleted": deleted,
      "imagePath": imagePath,
      "lastModified": lastModified != null
          ? DateFormat('dd-MM-yyyy').format(lastModified!)
          : null,
      "deleted": deleted,
    };
  }

  factory Customer.fromSqliteMap(Map<String, dynamic> m) {
    DateTime? parsedDate;
    if (m["lastModified"] != null && m["lastModified"].toString().isNotEmpty) {
      try {
        parsedDate = DateFormat('dd-MM-yyyy').parse(m["lastModified"]);
      } catch (_) {
        parsedDate = null;
      }
    }
    return Customer(
      customerId: UuidValue(m["customerId"]),
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
