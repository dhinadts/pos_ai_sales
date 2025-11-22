/* import 'dart:typed_data';

import 'package:pos_ai_sales/core/utilits/thermal_printer/bluetooth_printer_service.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfPrintService {
  // Generate PDF for receipt
  Future<Uint8List> generateReceiptPdf(List<Map<String, dynamic>> items) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text(
                'MY STORE',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Receipt #12345'),
              pw.Divider(),

              for (var item in items)
                pw.Row(
                  children: [
                    pw.Expanded(child: pw.Text(item['name'])),
                    pw.Text('x${item['quantity']}'),
                    pw.SizedBox(width: 20),
                    pw.Text('\$${item['price']}'),
                  ],
                ),

              pw.Divider(),
              pw.Text('Thank you for your business!'),
            ],
          );
        },
      ),
    );

    return await pdf.save();
  }

  // Print using device's print dialog
  Future<void> printPdf(Uint8List pdfBytes) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }

  // Direct print to thermal printer (convert PDF to ESC/POS)
  Future<void> printPdfToThermal(
    Uint8List pdfBytes,
    BluetoothPrinterService printerService,
  ) async {
    // Convert PDF to simple text for thermal printer
    // This is a simplified version - you might need OCR or text extraction
    final items = [
      {'name': 'Product 1', 'quantity': 2, 'price': 10.0},
      {'name': 'Product 2', 'quantity': 1, 'price': 15.0},
    ];

    await printerService.printReceipt(items);
  }
}
 */
