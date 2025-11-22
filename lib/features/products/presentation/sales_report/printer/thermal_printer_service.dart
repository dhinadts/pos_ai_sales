// lib/services/thermal_printer_service.dart
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:esc_pos_printer_plus/esc_pos_printer_plus.dart';
import 'package:flutter/foundation.dart';

class ThermalPrinterService {
  final PaperSize paper = PaperSize.mm58;

  static Future<void> printReceipt({
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double tax,
    required double discount,
    required double finalTotal,
    required String? customer,
    required String orderType,
    required String paymentMethod,
  }) async {
    printReceipt(
      items: items,
      subtotal: subtotal,
      tax: tax,
      discount: discount,
      finalTotal: finalTotal,
      customer: customer,
      orderType: orderType,
      paymentMethod: paymentMethod,
    );
  }

  Future<PosPrintResult> printCartOrder({
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double tax,
    required double discount,
    required double finalTotal,
    required String? customer,
    required String orderType,
    required String paymentMethod,
    required String printerIp,
    int port = 9100,
  }) async {
    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(paper, profile);

    final res = await printer.connect(printerIp, port: port);

    if (res == PosPrintResult.success) {
      final generator = Generator(paper, profile);
      final bytes = _buildReceiptBytes(
        generator,
        items: items,
        subtotal: subtotal,
        tax: tax,
        discount: discount,
        finalTotal: finalTotal,
        customer: customer,
        orderType: orderType,
        paymentMethod: paymentMethod,
      );

      printer.rawBytes(bytes);
      printer.disconnect();
      debugPrint('Receipt printed successfully');
    } else {
      debugPrint('Failed to connect to printer: $res');
    }

    return res;
  }

  List<int> _buildReceiptBytes(
    Generator generator, {
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double tax,
    required double discount,
    required double finalTotal,
    required String? customer,
    required String orderType,
    required String paymentMethod,
  }) {
    List<int> bytes = [];

    // Header
    bytes += generator.text('YOUR STORE NAME',
        styles: PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.text('Store Address Line 1',
        styles: PosStyles(align: PosAlign.center));
    bytes += generator.text('Phone: +91 XXXXXXXXXX',
        styles: PosStyles(align: PosAlign.center));
    bytes += generator.hr();

    // Order Info
    bytes +=
        generator.text('Date: ${DateTime.now().toString().substring(0, 16)}');
    bytes += generator.text('Order Type: $orderType');
    if (customer != null && customer.isNotEmpty) {
      bytes += generator.text('Customer: $customer');
    }
    bytes += generator.hr();

    // Items Header
    bytes += generator.text('ITEMS',
        styles: PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.hr(ch: '-');

    // Items List
    for (final item in items) {
      final name = item['name'] ?? 'Unknown';
      final quantity = item['quantity'] ?? 1;
      final price = item['price'] ?? 0.0;
      final total = (quantity * price);

      // Item name (truncate if too long)
      final truncatedName =
          name.length > 20 ? '${name.substring(0, 20)}...' : name;
      bytes += generator.text(truncatedName);

      // Quantity and price
      bytes += generator.text(
        '${quantity}x @ ₹${price.toStringAsFixed(2)} = ₹${total.toStringAsFixed(2)}',
        styles: PosStyles(align: PosAlign.right),
      );

      bytes += generator.emptyLines(1);
    }

    bytes += generator.hr();

    // Totals
    bytes += generator.row([
      PosColumn(text: 'Subtotal:', width: 6),
      PosColumn(
          text: '₹${subtotal.toStringAsFixed(2)}',
          width: 6,
          styles: PosStyles(align: PosAlign.right)),
    ]);

    if (tax > 0) {
      bytes += generator.row([
        PosColumn(text: 'Tax:', width: 6),
        PosColumn(
            text: '₹${tax.toStringAsFixed(2)}',
            width: 6,
            styles: PosStyles(align: PosAlign.right)),
      ]);
    }

    if (discount > 0) {
      bytes += generator.row([
        PosColumn(text: 'Discount:', width: 6),
        PosColumn(
            text: '-₹${discount.toStringAsFixed(2)}',
            width: 6,
            styles: PosStyles(align: PosAlign.right)),
      ]);
    }

    bytes += generator.hr();

    // Final Total
    bytes += generator.row([
      PosColumn(text: 'TOTAL:', width: 6, styles: PosStyles(bold: true)),
      PosColumn(
          text: '₹${finalTotal.toStringAsFixed(2)}',
          width: 6,
          styles: PosStyles(align: PosAlign.right, bold: true)),
    ]);

    bytes += generator.emptyLines(1);

    // Payment Method
    bytes += generator.text('Payment: $paymentMethod',
        styles: PosStyles(align: PosAlign.center));

    bytes += generator.emptyLines(2);

    // Footer
    bytes += generator.text('Thank you for shopping!',
        styles: PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.text('Please visit again',
        styles: PosStyles(align: PosAlign.center));

    bytes += generator.emptyLines(3);
    bytes += generator.cut();

    return bytes;
  }

  // Test printer connection
  Future<PosPrintResult> testPrinter(String printerIp,
      {int port = 9100}) async {
    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(paper, profile);

    final res = await printer.connect(printerIp, port: port);

    if (res == PosPrintResult.success) {
      final generator = Generator(paper, profile);
      final bytes = _buildTestBytes(generator);
      printer.rawBytes(bytes);
      printer.disconnect();
    }

    return res;
  }

  List<int> _buildTestBytes(Generator generator) {
    List<int> bytes = [];
    bytes += generator.text('TEST RECEIPT',
        styles: PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.hr();
    bytes += generator.text('Printer Test Successful');
    bytes += generator.text('Date: ${DateTime.now()}');
    bytes += generator.hr();
    bytes += generator.text('This is a test print',
        styles: PosStyles(align: PosAlign.center));
    bytes += generator.emptyLines(3);
    bytes += generator.cut();
    return bytes;
  }
}

/* import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:esc_pos_printer_plus/esc_pos_printer_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:pos_ai_sales/features/products/domain/sales_record.dart';

class ThermalPrinterService {
  final PaperSize paper = PaperSize.mm58;

  Future<PosPrintResult> printOverNetwork(SalesRecord record, String ip,
      {int port = 9100}) async {
    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(paper, profile);
    final generator = Generator(paper, profile);

    final res = await printer.connect(ip, port: port);

    if (res == PosPrintResult.success) {
      final bytes = _buildBytes(generator, record);
      printer.rawBytes(bytes);
      printer.disconnect();
    } else {
      debugPrint('Failed to connect to network printer: $res');
    }

    return res;
  }

  List<int> _buildBytes(Generator generator, SalesRecord record) {
    List<int> bytes = [];
    bytes += generator.text('SALES REPORT',
        styles: PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.emptyLines(1);
    bytes += generator.text('Product: ${record.productName}');
    bytes += generator.text('Qty: ${record.qty ?? 1}');
    bytes += generator.text('Amount: ₹${record.total}');
    bytes += generator.text('Date: ${record.date}');
    bytes += generator.text('Category: ${record.category}');
    bytes += generator.hr();
    bytes +=
        generator.text('Thank you!', styles: PosStyles(align: PosAlign.center));
    bytes += generator.cut();
    return bytes;
  }
}
 */
