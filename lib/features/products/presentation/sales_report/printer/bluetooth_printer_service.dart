import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:pos_ai_sales/features/products/domain/sales_record.dart';

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
