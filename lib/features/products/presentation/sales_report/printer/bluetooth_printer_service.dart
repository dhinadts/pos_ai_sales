import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pos_ai_sales/features/products/domain/sales_record.dart';
import 'package:pos_ai_sales/features/products/presentation/orders/cart_model.dart';
import 'package:pos_ai_sales/features/products/presentation/orders/usp_service.dart';

class BluetoothPrinterService {
  final BlueThermalPrinter _bt = BlueThermalPrinter.instance;

  Future<List<BluetoothDevice>> getBondedDevices() async {
    try {
      return await _bt.getBondedDevices();
    } catch (e) {
      return [];
    }
  }

  Future<bool> connect(BluetoothDevice device) async {
    try {
      await _bt.connect(device);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      await _bt.disconnect();
    } catch (_) {}
  }

  Future<void> printSalesRecord(SalesRecord record) async {
    try {
      final isConnected = await _bt.isConnected ?? false;
      if (!isConnected) {
        final devices = await getBondedDevices();
        if (devices.isNotEmpty) {
          await connect(devices.first);
        }
      }

      _bt.printCustom("SALES REPORT", 3, 1);
      _bt.printLeftRight("Product", record.productName ?? "", 1);
      _bt.printLeftRight("Qty", record.qty?.toString() ?? "1", 1);
      _bt.printLeftRight("Amount", "₹${record.total}", 1);
      _bt.printLeftRight("Date", record.date as String, 1);
      _bt.printLeftRight("Category", record.category ?? "", 1);
      _bt.printNewLine();
      _bt.printCustom("Thank you!", 1, 1);
    } catch (e) {
      debugPrint("Bluetooth print error: $e");
    }
  }
}

class PrinterManager {
  late final PrinterService _printerService;

  PrinterManager() {
    if (kIsWeb) {
      _printerService = WebPrinterService();
    } else {
      _printerService = MobilePrinterService();
    }
  }

  Future<void> printCartOrder(
      {required List<CartItem> items,
      required double subtotal,
      required double tax,
      required double discount,
      required double finalTotal,
      required String customer,
      required String orderType,
      required String paymentMethod,
      required String orderId}) async {
    try {
      // Check if printer is available (for mobile)
      final isAvailable = await _printerService.isPrinterAvailable();

      if (!isAvailable && !kIsWeb) {
        throw Exception(
            'No printer available. Please connect a Bluetooth printer.');
      }

      await _printerService.printOrder(
          items: items,
          subtotal: subtotal,
          tax: tax,
          discount: discount,
          finalTotal: finalTotal,
          customer: customer,
          orderType: orderType,
          paymentMethod: paymentMethod,
          orderId: orderId);
    } catch (e) {
      debugPrint("Print error: $e");
      rethrow; // Re-throw to handle in UI
    }
  }

  Future<bool> connectToFirstAvailablePrinter() async {
    if (kIsWeb) {
      // Web doesn't need Bluetooth connection
      return true;
    } else {
      try {
        final mobileService = _printerService as MobilePrinterService;
        return await mobileService.connectToFirstAvailablePrinter();
      } catch (e) {
        debugPrint("Printer connect error: $e");
        return false;
      }
    }
  }

  Future<bool> checkPrinterStatus() async {
    return await _printerService.isPrinterAvailable();
  }
}
