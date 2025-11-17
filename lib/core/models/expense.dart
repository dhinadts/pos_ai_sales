// lib/models/Expense_model.dart
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class Expense {
  final UuidValue expenseId;
  final String? name;
  final String? note;
  final String? amount;
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

  Map<String, dynamic> toMap() {
    return {
      'expenseId': expenseId.toString(),
      'name': name ?? '',
      'note': note ?? '',
      'amount': amount ?? '',
      'date': date ?? '',
      'time': time ?? '',
      'lastModified': lastModified?.millisecondsSinceEpoch, // store int ✔
      'deleted': deleted,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      expenseId: map['expenseId'],
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
      'expenseId': expenseId.toString(), // REQUIRED
      'name': name ?? '',
      'note': note ?? '',
      'amount': amount ?? '',
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
}
