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

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      "${dir.path}/sales_report_${rangeType.toLowerCase()}_${now.millisecondsSinceEpoch}.pdf",
    );
    await file.writeAsBytes(await pdf.save());

    await _shareAndPrintPdf(await pdf.save(), rangeType);

    debugPrint("✅ PDF generated: ${file.path}");
  }

  static Future<void> _shareAndPrintPdf(
    Uint8List pdfBytes,
    String rangeType,
  ) async {
    try {
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename:
            'sales_report_${rangeType.toLowerCase()}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
      );
    } catch (e) {
      debugPrint("Error sharing/printing PDF: $e");
    }
  }

  static Future<void> printPdfDirectly(Uint8List pdfBytes) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }
}
