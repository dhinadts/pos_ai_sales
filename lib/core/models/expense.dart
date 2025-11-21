import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid_value.dart';

class Expense {
  final UuidValue expenseId;
  final String? name;
  final String? note;
  final double? amount;
  final String? date;
  final String? time;
  final DateTime? lastModified;
  int deleted = 0;

  Expense({
    required this.expenseId,
    this.name,
    this.note,
    this.amount,
    this.date,
    this.time,
    this.lastModified,
    this.deleted = 0,
  });

  // CopyWith method
  Expense copyWith({
    UuidValue? expenseId,
    String? name,
    String? note,
    double? amount,
    String? date,
    String? time,
    DateTime? lastModified,
    int? deleted,
  }) {
    return Expense(
      expenseId: expenseId ?? this.expenseId,
      name: name ?? this.name,
      note: note ?? this.note,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      time: time ?? this.time,
      lastModified: lastModified ?? this.lastModified,
      deleted: deleted ?? this.deleted,
    );
  }

  // ... rest of your existing methods (toMap, fromMap, etc.)

  Map<String, dynamic> toMap() {
    return {
      'expenseId': expenseId.toString(),
      'name': name ?? '',
      'note': note ?? '',
      'amount': amount ?? 0.0,
      'date': date ?? '',
      'time': time ?? '',
      'lastModified': lastModified?.millisecondsSinceEpoch,
      'deleted': deleted,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      expenseId:
          UuidValue(map['expenseId']), // FIX: Convert string to UuidValue
      name: map['name'],
      note: map['note'],
      amount: map['amount'],
      date: map['date'],
      time: map['time'],
      lastModified: map['lastModified'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastModified'])
          : null,
      deleted: map['deleted'] ?? 0,
    );
  }

  // sqlite map
  Map<String, dynamic> toSqliteMap() {
    return {
      'expenseId': expenseId.toString(),
      'name': name ?? '',
      'note': note ?? '',
      'amount': amount ?? 0.0,
      'date': date ?? '',
      'time': time ?? '',
      "lastModified": lastModified != null
          ? DateFormat('dd-MM-yyyy').format(lastModified!)
          : null,
      "deleted": deleted,
    };
  }

  factory Expense.fromSqliteMap(Map<String, dynamic> m) {
    DateTime? parsedDate;
    if (m["lastModified"] != null && m["lastModified"].toString().isNotEmpty) {
      try {
        parsedDate = DateFormat('dd-MM-yyyy').parse(m["lastModified"]);
      } catch (_) {
        parsedDate = null;
      }
    }
    return Expense(
      expenseId: UuidValue(m['expenseId']),
      name: m['name'],
      note: m['note'],
      amount: m['amount'],
      date: m['date'],
      time: m['time'],
      lastModified: parsedDate,
      deleted: m["deleted"] ?? 0,
    );
  }

  /// Helper: formatted date string (for UI)
  String get formattedDate {
    if (lastModified == null) return "N/A";
    return DateFormat('dd-MM-yyyy').format(lastModified!);
  }

  // Fix for Firebase methods
  Map<String, dynamic> toFirebaseMap() {
    return {
      "expenseId": expenseId.toString(),
      "name": name ?? '',
      "amount": amount ?? 0.0,
      "note": note ?? '',
      "date": date ?? '', // FIX: Removed incorrect Timestamp conversion
      "time": time ?? '',
      "lastModified": FieldValue.serverTimestamp(), // FIX: Use server timestamp
      "deleted": deleted,
    };
  }

  factory Expense.fromFirebaseMap(Map<String, dynamic> json) {
    return Expense(
      expenseId: UuidValue(json["expenseId"]),
      name: json["name"],
      amount: (json["amount"] as num).toDouble(),
      note: json["note"],
      date: json["date"],
      time: json["time"],
      lastModified: json["lastModified"] != null
          ? (json["lastModified"] as Timestamp).toDate()
          : null,
      deleted: json["deleted"] ?? 0,
    );
  }
}
