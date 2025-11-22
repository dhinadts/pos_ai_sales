import 'dart:async';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:pos_ai_sales/features/products/presentation/orders/cart_model.dart';

/// Handles Bluetooth Printer communication
class BluetoothPrinterService {
  final BlueThermalPrinter _bt = BlueThermalPrinter.instance;

  Future<List<BluetoothDevice>> getBondedDevices() async {
    try {
      return await _bt.getBondedDevices();
    } catch (e) {
      debugPrint("Error getting bonded devices: $e");
      return [];
    }
  }

  Future<bool> connect(BluetoothDevice device) async {
    try {
      await _bt.connect(device);
      return true;
    } catch (e) {
      debugPrint("Bluetooth connect error: $e");
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      await _bt.disconnect();
    } catch (e) {
      debugPrint("Disconnect error: $e");
    }
  }

  Future<void> printOrder({
    required List<CartItem> items,
    required double subtotal,
    required double tax,
    required double discount,
    required double finalTotal,
    required String customer,
    required String orderType,
    required String paymentMethod, required String orderId,
  }) async {
    try {
      bool isConnected = await _bt.isConnected ?? false;

      if (!isConnected) {
        final devices = await getBondedDevices();
        if (devices.isEmpty) {
          debugPrint("No paired printers!");
          return;
        }
        await connect(devices.first);
      }

      _bt.printCustom("POS AI SALES", 3, 1);
      _bt.printNewLine();
      _bt.printLeftRight("Customer", customer, 1);
      _bt.printLeftRight("Order Type", orderType, 1);
      _bt.printLeftRight("Payment", paymentMethod, 1);
      _bt.printNewLine();

      _bt.printCustom("ITEMS", 2, 0);
      for (var item in items) {
        _bt.printLeftRight(item.name, "x${item.quantity}", 1);
        _bt.printLeftRight("Unit Price", "₹${item.price}", 0);
        _bt.printLeftRight("Total", "₹${item.total}", 0);
        _bt.printNewLine();
      }

      _bt.printCustom("----------------------------", 1, 1);

      _bt.printLeftRight("Subtotal", "₹$subtotal", 1);
      _bt.printLeftRight("Tax", "₹$tax", 1);
      _bt.printLeftRight("Discount", "₹$discount", 1);
      _bt.printLeftRight("Final Total", "₹$finalTotal", 2);

      _bt.printNewLine();
      _bt.printCustom("Thank You!", 2, 1);
      _bt.printNewLine();
    } catch (e) {
      debugPrint("Bluetooth print error: $e");
    }
  }
}
class PrinterManager {
  final BluetoothPrinterService _printerService = BluetoothPrinterService();

  Future<void> printCartOrder({
    required List<CartItem> items,
    required double subtotal,
    required double tax,
    required double discount,
    required double finalTotal,
    required String customer,
    required String orderType,
    required String paymentMethod,
    required String orderId
  }) async {
    try {
      await _printerService.printOrder(
        items: items,
        subtotal: subtotal,
        tax: tax,
        discount: discount,
        finalTotal: finalTotal,
        customer: customer,
        orderType: orderType,
        paymentMethod: paymentMethod,
        orderId: orderId,
      );
    } catch (e) {
      debugPrint("Print error: $e");
    }
  }

  Future<bool> connectToFirstAvailablePrinter() async {
    try {
      final devices = await _printerService.getBondedDevices();
      if (devices.isNotEmpty) {
        return await _printerService.connect(devices.first);
      }
      return false;
    } catch (e) {
      debugPrint("Printer connect error: $e");
      return false;
    }
  }
}
