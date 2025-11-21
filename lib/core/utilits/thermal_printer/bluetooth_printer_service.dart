import 'dart:async';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:pos_ai_sales/features/products/domain/sales_record.dart';

/// SERVICE: Handles Bluetooth Printer
class BluetoothPrinterService {
  final BlueThermalPrinter _bt = BlueThermalPrinter.instance;

  /// 🔵 Get all paired Bluetooth Printers
  Future<List<BluetoothDevice>> getBondedDevices() async {
    try {
      return await _bt.getBondedDevices();
    } catch (e) {
      debugPrint("Error getting bonded devices: $e");
      return [];
    }
  }

  /// 🔵 Connect to selected device
  Future<bool> connect(BluetoothDevice device) async {
    try {
      await _bt.connect(device);
      return true;
    } catch (e) {
      debugPrint("Bluetooth connect error: $e");
      return false;
    }
  }

  /// 🔵 Disconnect device
  Future<void> disconnect() async {
    try {
      await _bt.disconnect();
    } catch (e) {
      debugPrint("Bluetooth disconnect error: $e");
    }
  }

  /// 🔵 Print Single Sales Record
  Future<void> printSalesRecord(SalesRecord record) async {
    try {
      bool isConnected = await _bt.isConnected ?? false;

      if (!isConnected) {
        final devices = await getBondedDevices();
        if (devices.isEmpty) {
          debugPrint("No paired printers found!");
          return;
        }
        await connect(devices.first);
      }

      _bt.printCustom("SALES REPORT", 3, 1);
      _bt.printLeftRight("Product", record.productName ?? "", 1);
      _bt.printLeftRight("Qty", record.qty?.toString() ?? "1", 1);
      _bt.printLeftRight("Amount", "₹${record.total}", 1);
      _bt.printLeftRight("Date", record.date.toString(), 1);
      _bt.printLeftRight("Category", record.category ?? "", 1);
      _bt.printNewLine();
      _bt.printCustom("Thank You!", 2, 1);
    } catch (e) {
      debugPrint("Bluetooth print error: $e");
    }
  }

  /// 🔵 Print multiple items (Receipt / Order)
  Future<void> printReceipt(List<Map<String, dynamic>> items) async {
    try {
      final devices = await getBondedDevices();
      if (devices.isEmpty) {
        debugPrint("No Bluetooth printer paired!");
        return;
      }

      await connect(devices.first);

      _bt.printCustom("ORDER RECEIPT", 3, 1);
      _bt.printNewLine();

      for (var item in items) {
        _bt.printLeftRight(
          item['name'] ?? "",
          "x${item['qty']}  ₹${item['price']}",
          1,
        );
      }

      _bt.printNewLine();
      _bt.printCustom("Thank you!", 2, 1);
    } catch (e) {
      debugPrint("Receipt print error: $e");
    }
  }

  /// 🔵 Discover paired printers (blue_thermal_printer limitation)
  ///
  /// NOTE:
  /// blue_thermal_printer does NOT support scanning.
  /// So the only available option is to return bonded devices.
  Stream<List<BluetoothDevice>> discoverPrinters() async* {
    List<BluetoothDevice> devices = await getBondedDevices();
    yield devices;
  }

  /// 🔵 Connect wrapper used by PrinterManager
  Future<bool> connectToPrinter(BluetoothDevice device) async {
    return await connect(device);
  }
}

/// MANAGER: High-Level API
class PrinterManager {
  final BluetoothPrinterService _printerService = BluetoothPrinterService();

  /// Print list of items as a receipt
  Future<void> printOrderReceipt(List<Map<String, dynamic>> orderItems) async {
    try {
      await _printerService.printReceipt(orderItems);
    } catch (e) {
      debugPrint('Print error: $e');
      rethrow;
    }
  }

  /// Discover & connect to first available paired printer
  Future<bool> connectToFirstAvailablePrinter() async {
    try {
      final printers = await _printerService.getBondedDevices();
      if (printers.isNotEmpty) {
        return await _printerService.connect(printers.first);
      }
      return false;
    } catch (e) {
      debugPrint("Connection error: $e");
      return false;
    }
  }
}
