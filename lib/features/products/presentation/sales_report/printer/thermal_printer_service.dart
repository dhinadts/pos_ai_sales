import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
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
