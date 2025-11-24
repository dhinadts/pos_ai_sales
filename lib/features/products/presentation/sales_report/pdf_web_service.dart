import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pos_ai_sales/features/products/domain/sales_record.dart';
import 'package:printing/printing.dart';

class ReportPdfServiceWeb {
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

    final Uint8List pdfBytes = await pdf.save();

    await _printPdfDirectly(pdfBytes);

    debugPrint("✅ PDF generation complete. Triggered browser print dialog.");
  }

  static Future<void> _printPdfDirectly(Uint8List pdfBytes) async {
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );
    } catch (e) {
      debugPrint("Error printing PDF: $e");
    }
  }
}
