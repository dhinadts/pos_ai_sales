
import 'dart:io';
import '../domain/sales_record.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

class ExcelImportService {
  /// Prompts user to pick an Excel or CSV file and parses it into SalesRecord list.
  Future<List<SalesRecord>> importFromDevice() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['xlsx', 'csv']);
    if (result == null || result.files.isEmpty) return [];
    final filePath = result.files.single.path;
    if (filePath == null) return [];
    final file = File(filePath);
    if (filePath.endsWith('.csv')) {
      return _parseCsv(file);
    } else if (filePath.endsWith('.xlsx')) {
      return _parseXlsx(file);
    } else {
      throw FormatException('Unsupported file type');
    }
  }

  List<SalesRecord> _parseCsv(File file) {
    final text = file.readAsStringSync();
    final rows = const CsvToListConverter().convert(text);
    return _rowsToRecords(rows);
  }

  List<SalesRecord> _parseXlsx(File file) {
    final bytes = file.readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);
    // use first sheet
    final sheet = excel.sheets[excel.sheets.keys.first]!;
    final rows = <List<dynamic>>[];
    for (final row in sheet.rows) {
      rows.add(row.map((e) => e?.value).toList());
    }
    return _rowsToRecords(rows);
  }

  final DateFormat dateFormat = DateFormat('dd-MM-yyyy');

  DateTime _parseDate(String? raw) {
    if (raw == null) throw FormatException('Empty date');
    raw = raw.trim();
    // expected DD-MM-YYYY per user
    try {
      return dateFormat.parseStrict(raw);
    } catch (_) {
      // try common alternatives
      try {
        return DateTime.parse(raw);
      } catch (e) {
        throw FormatException('Unrecognized date: $raw');
      }
    }
  }

  List<SalesRecord> _rowsToRecords(List<List<dynamic>> rows) {
    if (rows.isEmpty) return [];
    // locate header row (assume first row is header)
    final header = rows.first.map((c) => c.toString().trim()).toList();
    final idxDate = header.indexWhere((h) => h.toLowerCase().contains('date'));
    final idxCode = header.indexWhere((h) => h.toLowerCase().contains('code'));
    final idxProduct = header.indexWhere((h) => h.toLowerCase().contains('product'));
    final idxQty = header.indexWhere((h) => h.toLowerCase().contains('qty'));
    final idxUnit = header.indexWhere((h) => h.toLowerCase().contains('unit'));
    final idxTotal = header.indexWhere((h) => h.toLowerCase().contains('total'));

    final out = <SalesRecord>[];
    for (int i = 1; i < rows.length; i++) {
      final r = rows[i];
      if (r.every((cell) => cell == null || cell.toString().trim().isEmpty)) {
        continue; // skip empty
      }
      try {
        final rawDate = r[idxDate]?.toString().trim();
        final date = _parseDate(rawDate);
        final code = idxCode >= 0 ? r[idxCode]?.toString() ?? '' : '';
        final product = idxProduct >= 0 ? r[idxProduct]?.toString() ?? '' : '';
        final qty = idxQty >= 0 ? int.tryParse(r[idxQty].toString()) ?? 0 : 0;
        final unitPrice = idxUnit >= 0 ? double.tryParse(r[idxUnit].toString()) ?? 0.0 : 0.0;
        final total = idxTotal >= 0 ? double.tryParse(r[idxTotal].toString()) ?? (qty * unitPrice) : (qty * unitPrice);

        out.add(SalesRecord(
          date: date,
          code: code,
          productName: product,
          qty: qty,
          unitPrice: unitPrice,
          total: total,
        ));
      } catch (e) {
        // skip row if parsing fails
        continue;
      }
    }
    return out;
  }
}
// Duplicate code removed. Only the ExcelImportService class remains above.