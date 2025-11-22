/* import 'package:flutter/foundation.dart';
import 'package:pos_ai_sales/core/utilits/thermal_printer/bluetooth_printer_service.dart';
import 'package:pos_ai_sales/core/utilits/thermal_printer/printer_ui_mobile.dart';
import 'package:pos_ai_sales/core/utilits/thermal_printer/web_print_service.dart';

enum PrinterType { bluetooth, network, usb, browser }

class PrintManager {
  final BluetoothPrinterService _bluetoothService = BluetoothPrinterService();
  final PdfPrintService _pdfService = PdfPrintService();
  final WebPrintService _webService = WebPrintService();

  // Main print method - works on both mobile and web
  Future<void> printReceipt({
    required List<Map<String, dynamic>> items,
    PrinterType printerType = PrinterType.browser,
    String? printerAddress, // IP for network, ID for Bluetooth
  }) async {
    try {
      // Generate PDF
      final pdfBytes = await _pdfService.generateReceiptPdf(items);

      if (kIsWeb) {
        // Web printing
        _webService.printPdfDirect(pdfBytes);
      } else {
        // Mobile printing
        if (printerType == PrinterType.bluetooth && printerAddress != null) {
          // Find and connect to Bluetooth printer
          final devices = await _bluetoothService.discoverPrinters().first;
          final device = devices.firstWhere(
            (d) => d.address.toString() == printerAddress,
            orElse: () => throw Exception('Printer not found'),
          );

          await _bluetoothService.connectToPrinter(device);
          await _pdfService.printPdfToThermal(pdfBytes, _bluetoothService);
        } else {
          // Use device's default print dialog
          await _pdfService.printPdf(pdfBytes);
        }
      }
    } catch (e) {
      throw Exception('Print failed: $e');
    }
  }

  // Get available printers
  Future<List<Map<String, dynamic>>> getAvailablePrinters() async {
    if (kIsWeb) {
      return [
        {'name': 'Browser Print', 'type': 'browser', 'id': 'browser'},
      ];
    } else {
      final devices = await _bluetoothService.discoverPrinters().first;
      return devices
          .map(
            (device) => {
              'name': device.name,
              'type': 'bluetooth',
              'id': device.address.toString(),
              'device': device,
            },
          )
          .toList();
    }
  }
}
 */