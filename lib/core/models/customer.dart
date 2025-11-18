import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_value.dart';

class Customer {
  final UuidValue customerId;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String? imagePath;
  final DateTime? lastModified;
  final int deleted;

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

  // Factory constructors
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: UuidValue(json['customerId'] as String),
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      imagePath: json['imagePath'] as String?,
      lastModified: _parseTimestamp(json['lastModified']),
      deleted: (json['deleted'] as int?) ?? 0,
    );
  }

  factory Customer.fromSqliteMap(Map<String, dynamic> m) {
    return Customer(
      customerId: UuidValue(m["customerId"] as String),
      name: m["name"] as String,
      email: m["email"] as String?,
      phone: m["phone"] as String?,
      address: m["address"] as String?,
      imagePath: m["imagePath"] as String?,
      lastModified: _parseTimestamp(m["lastModified"]),
      deleted: (m["deleted"] as int?) ?? 0,
    );
  }

  factory Customer.fromFirebaseMap(Map<String, dynamic> json) {
    return Customer(
      customerId: UuidValue(json["customerId"] as String),
      name: json["name"] as String,
      email: json["email"] as String?,
      phone: json["phone"] as String?,
      address: json["address"] as String?,
      imagePath: json["imagePath"] as String?,
      lastModified: _parseFirebaseTimestamp(json["lastModified"]),
      deleted: (json["deleted"] as int?) ?? 0,
    );
  }

  // Create a new customer (factory method)
  factory Customer.createNew({
    required String name,
    String? email,
    String? phone,
    String? address,
    String? imagePath,
  }) {
    return Customer(
      customerId: UuidValue(const Uuid().v4()), // Generate new UUID
      name: name,
      email: email,
      phone: phone,
      address: address,
      imagePath: imagePath,
      lastModified: DateTime.now(),
      deleted: 0,
    );
  }

  // Serialization methods
  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId.toString(),
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'imagePath': imagePath,
      'lastModified': lastModified?.millisecondsSinceEpoch,
      'deleted': deleted,
    };
  }

  Map<String, dynamic> toSqliteMap() {
    return {
      "customerId": customerId.toString(),
      "name": name,
      "email": email,
      "phone": phone,
      "address": address,
      "imagePath": imagePath,
      "lastModified": lastModified?.millisecondsSinceEpoch,
      "deleted": deleted,
    };
  }

  Map<String, dynamic> toFirebaseMap() {
    return {
      "customerId": customerId.toString(),
      "name": name,
      "email": email,
      "phone": phone,
      "address": address,
      "imagePath": imagePath,
      "lastModified": lastModified != null
          ? Timestamp.fromDate(lastModified!)
          : FieldValue.serverTimestamp(),
      "deleted": deleted,
    };
  }

  // Copy with method
  Customer copyWith({
    UuidValue? customerId,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? imagePath,
    DateTime? lastModified,
    int? deleted,
  }) {
    return Customer(
      customerId: customerId ?? this.customerId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      imagePath: imagePath ?? this.imagePath,
      lastModified: lastModified ?? this.lastModified,
      deleted: deleted ?? this.deleted,
    );
  }

  // Mark as deleted
  Customer markAsDeleted() {
    return copyWith(deleted: 1, lastModified: DateTime.now());
  }

  // Update last modified
  Customer touch() {
    return copyWith(lastModified: DateTime.now());
  }

  // Validation methods
  bool get isValid => name.trim().isNotEmpty;
  bool get isDeleted => deleted == 1;
  bool get hasPhone => phone != null && phone!.trim().isNotEmpty;
  bool get hasEmail => email != null && email!.trim().isNotEmpty;
  bool get hasAddress => address != null && address!.trim().isNotEmpty;

  // UI helpers
  String get formattedDate {
    if (lastModified == null) return "N/A";
    return DateFormat('dd-MM-yyyy HH:mm').format(lastModified!);
  }

  String get displayPhone => phone ?? 'No phone';
  String get displayEmail => email ?? 'No email';
  String get displayAddress => address ?? 'No address';

  String get initials {
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name[0].toUpperCase();
  }

  // Helper methods for timestamp parsing
  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        try {
          return DateFormat('dd-MM-yyyy').parse(value);
        } catch (_) {
          return null;
        }
      }
    }
    if (value is Timestamp) {
      return value.toDate();
    }
    return null;
  }

  static DateTime? _parseFirebaseTimestamp(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return null;
  }

  // Equality and comparison
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Customer &&
            runtimeType == other.runtimeType &&
            customerId == other.customerId);
  }

  @override
  int get hashCode => customerId.hashCode;

  // Comparison for sorting
  int compareTo(Customer other) {
    return name.toLowerCase().compareTo(other.name.toLowerCase());
  }

  @override
  String toString() {
    return 'Customer(customerId: $customerId, name: "$name", email: $email, phone: $phone, deleted: $deleted)';
  }
}

/* import 'package:cloud_firestore/cloud_firestore.dart';
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
  int deleted;

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
      lastModified: _parseTimestamp(json['lastModified']),
      deleted: (json['deleted'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId.toString(),
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'imagePath': imagePath,
      'lastModified': lastModified?.millisecondsSinceEpoch,
      'deleted': deleted,
    };
  }

  Customer copyWith({
    UuidValue? customerId,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? imagePath,
    DateTime? lastModified,
    int? deleted,
  }) {
    return Customer(
      customerId: customerId ?? this.customerId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      imagePath: imagePath ?? this.imagePath,
      lastModified: lastModified ?? this.lastModified,
      deleted: deleted ?? this.deleted,
    );
  }

  // SQLite map
  Map<String, dynamic> toSqliteMap() {
    return {
      "customerId": customerId.toString(),
      "name": name,
      "email": email,
      "phone": phone,
      "address": address,
      "imagePath": imagePath,
      "lastModified": lastModified?.millisecondsSinceEpoch,
      "deleted": deleted,
    };
  }

  factory Customer.fromSqliteMap(Map<String, dynamic> m) {
    return Customer(
      customerId: UuidValue(m["customerId"] as String),
      name: m["name"] as String? ?? "",
      email: m["email"] as String?,
      phone: m["phone"] as String?,
      address: m["address"] as String?,
      imagePath: m["imagePath"] as String?,
      lastModified: _parseTimestamp(m["lastModified"]),
      deleted: (m["deleted"] as int?) ?? 0,
    );
  }

  /// Helper: formatted date string (for UI)
  String get formattedDate {
    if (lastModified == null) return "N/A";
    return DateFormat('dd-MM-yyyy').format(lastModified!);
  }

  Map<String, dynamic> toFirebaseMap() {
    return {
      "customerId": customerId.toString(),
      "name": name,
      "email": email,
      "phone": phone,
      "address": address,
      "imagePath": imagePath,
      "lastModified": lastModified != null
          ? Timestamp.fromDate(lastModified!)
          : FieldValue.serverTimestamp(),
      "deleted": deleted,
    };
  }

  factory Customer.fromFirebaseMap(Map<String, dynamic> json) {
    return Customer(
      customerId: UuidValue(json["customerId"] as String),
      name: json["name"] as String? ?? "",
      email: json["email"] as String?,
      phone: json["phone"] as String?,
      address: json["address"] as String?,
      imagePath: json["imagePath"] as String?,
      lastModified: _parseFirebaseTimestamp(json["lastModified"]),
      deleted: (json["deleted"] as int?) ?? 0,
    );
  }

  // Helper methods for timestamp parsing
  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String) {
      try {
        return DateFormat('dd-MM-yyyy').parse(value);
      } catch (_) {
        return null;
      }
    }
    if (value is Timestamp) {
      return value.toDate();
    }
    return null;
  }

  static DateTime? _parseFirebaseTimestamp(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String) {
      try {
        // Try parsing ISO string first, then custom format
        return DateTime.parse(value);
      } catch (_) {
        try {
          return DateFormat('dd-MM-yyyy').parse(value);
        } catch (_) {
          return null;
        }
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Customer &&
          runtimeType == other.runtimeType &&
          customerId == other.customerId;

  @override
  int get hashCode => customerId.hashCode;

  @override
  String toString() {
    return 'Customer(customerId: $customerId, name: $name, email: $email, phone: $phone, deleted: $deleted)';
  }
}
 */
