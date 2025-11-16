import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:pos_ai_sales/features/products/domain/sales_record.dart';

class ReportPdfService {
  static Future<void> generateSalesReport(
    List<SalesRecord> sales,
    String rangeType,
  ) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd-MM-yyyy');
    final now = DateTime.now();

    // Calculate total
    double totalAmount = sales.fold(0, (sum, record) => sum + record.total);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text(
                  "Sales Report ($rangeType)",
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue700,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  "Generated on: ${dateFormat.format(now)}",
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: ["Date", "Product", "Qty", "Unit Price", "Total (₹)"],
            data: sales
                .map(
                  (s) => [
                    dateFormat.format(s.date),
                    s.productName,
                    s.qty.toString(),
                    "₹${s.unitPrice.toStringAsFixed(2)}",
                    "₹${s.total.toStringAsFixed(2)}",
                  ],
                )
                .toList(),
            border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue700),
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding: const pw.EdgeInsets.all(6),
          ),
          pw.SizedBox(height: 20),
          pw.Container(
            alignment: pw.Alignment.centerRight,
            child: pw.Row(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text(
                  "Total Amount: ",
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                pw.Text(
                  "₹${totalAmount.toStringAsFixed(2)}",
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 16,
                    color: PdfColors.green700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // Save to file
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      "${dir.path}/sales_report_${rangeType.toLowerCase()}_${now.millisecondsSinceEpoch}.pdf",
    );
    await file.writeAsBytes(await pdf.save());

    // Share and print
    await _shareAndPrintPdf(await pdf.save(), rangeType);

    debugPrint("✅ PDF generated: ${file.path}");
  }

  static Future<void> _shareAndPrintPdf(
    Uint8List pdfBytes,
    String rangeType,
  ) async {
    try {
      // Share PDF (this will include print option)
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename:
            'sales_report_${rangeType.toLowerCase()}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
      );
    } catch (e) {
      debugPrint("Error sharing/printing PDF: $e");
      // Fallback: just save without sharing
    }
  }

  // Direct print method (optional)
  static Future<void> printPdfDirectly(Uint8List pdfBytes) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }
}

/* import 'dart:io';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:pos_ai_sales/features/products/domain/sales_record.dart';
// import 'package:pos_ai_sales/features/sales_reports/domain/sales_record.dart';

class ReportPdfService {
  static Future<void> generateSalesReport(
    List<SalesRecord> sales,
    String rangeType,
  ) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd-MM-yyyy');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Center(
            child: pw.Text(
              "Sales Report ($rangeType)",
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: ["Date", "Product", "Total (₹)"],
            data: sales
                .map(
                  (s) => [
                    dateFormat.format(s.date),
                    s.productName,
                    s.total.toStringAsFixed(2),
                  ],
                )
                .toList(),
            border: pw.TableBorder.all(color: PdfColors.grey),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey),
            cellAlignment: pw.Alignment.centerLeft,
          ),
          pw.SizedBox(height: 12),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              "Generated on: ${dateFormat.format(DateTime.now())}",
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/sales_report_${rangeType}.pdf");
    await file.writeAsBytes(await pdf.save());
    debugPrint("✅ PDF generated: ${file.path}");
  }
}
 */

/* 
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:pos_ai_sales/features/products/presentation/sales_report/reports_home_screen.dart';
import 'package:printing/printing.dart';

import '../../domain/sales_record.dart';
import '../../domain/sales_aggregator.dart';

/// Simple PDF generation service for sales reports.
///
/// NOTE: add these dependencies to your pubspec.yaml:
///
///   pdf: ^3.10.1
///   printing: ^5.10.0
///
class ReportPdfService {
  /// Generates a PDF bytes for the given sales records and title.
  static Future<Uint8List> generatePdf({
    required String title,
    required List<SalesRecord> records,
    required ReportRange range,
  }) async {
    final doc = pw.Document();

    final aggregated = SalesAggregator.aggregate(records, range);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return [
            pw.Header(level: 0, child: pw.Text(title, style: pw.TextStyle(fontSize: 24))),
            pw.Paragraph(text: 'Generated: \${DateTime.now().toIso8601String()}'),
            pw.SizedBox(height: 12),

            // Aggregated table
            pw.Text('Summary', style: pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 8),
            pw.Table.fromTextArray(
              headers: ['Period', 'Amount'],
              data: aggregated.entries.map((e) => [e.key, e.value.toStringAsFixed(2)]).toList(),
            ),

            pw.SizedBox(height: 18),
            pw.Text('Detailed Records', style: pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 8),

            pw.Table.fromTextArray(
              headers: ['Date', 'Record'],
              data: records.map((r) => [r.date.toString(), r.toString()]).toList(),
            ),
          ];
        },
      ),
    );

    return doc.save();
  }

  /// Helper to directly share a PDF using `printing` package (opens share/print sheet).
  static Future<void> sharePdf({required Uint8List bytes, required String filename}) async {
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }
} */
