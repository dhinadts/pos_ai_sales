// lib/core/utilits/thermal_printer/universal_printer_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pos_ai_sales/core/utilits/thermal_printer/bluetooth_printer_service.dart';
import 'package:pos_ai_sales/features/products/presentation/orders/cart_model.dart';
// Import for web
import 'dart:convert' as convert;
import 'dart:html' as html;
import 'dart:typed_data';

abstract class PrinterService {
  Future<void> printOrder(
      {required List<CartItem> items,
      required double subtotal,
      required double tax,
      required double discount,
      required double finalTotal,
      required String customer,
      required String orderType,
      required String paymentMethod,
      required String orderId});

  Future<bool> isPrinterAvailable();
}

// Mobile implementation
class MobilePrinterService implements PrinterService {
  final BluetoothPrinterService _bluetoothService = BluetoothPrinterService();

  @override
  Future<void> printOrder(
      {required List<CartItem> items,
      required double subtotal,
      required double tax,
      required double discount,
      required double finalTotal,
      required String customer,
      required String orderType,
      required String paymentMethod,
      required String orderId}) async {
    await _bluetoothService.printOrder(
        items: items,
        subtotal: subtotal,
        tax: tax,
        discount: discount,
        finalTotal: finalTotal,
        customer: customer,
        orderType: orderType,
        paymentMethod: paymentMethod,
        orderId: orderId);
  }

  @override
  Future<bool> isPrinterAvailable() async {
    try {
      final devices = await _bluetoothService.getBondedDevices();
      return devices.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<bool> connectToFirstAvailablePrinter() async {
    return true;
  }
}

// Web implementation - Uses browser printing
class WebPrinterService implements PrinterService {
  @override
  Future<void> printOrder(
      {required List<CartItem> items,
      required double subtotal,
      required double tax,
      required double discount,
      required double finalTotal,
      required String customer,
      required String orderType,
      required String paymentMethod,
      required String orderId}) async {
    final htmlContent = _generateHtmlReceipt(
      items: items,
      subtotal: subtotal,
      tax: tax,
      discount: discount,
      finalTotal: finalTotal,
      customer: customer,
      orderType: orderType,
      paymentMethod: paymentMethod,
      // orderId: orderId,
    );

    await _printHtmlContent(htmlContent);
  }

  String _generateHtmlReceipt({
    required List<CartItem> items,
    required double subtotal,
    required double tax,
    required double discount,
    required double finalTotal,
    required String customer,
    required String orderType,
    required String paymentMethod,
  }) {
    final itemsHtml = StringBuffer();
    for (var item in items) {
      itemsHtml.write('''
        <div style="display: flex; justify-content: space-between; margin: 8px 0;">
          <div>
            <div style="font-weight: bold;">${item.name}</div>
            <div style="font-size: 12px; color: #666;">${item.unit} x ${item.quantity}</div>
          </div>
          <div style="text-align: right;">
            <div>₹${item.price.toStringAsFixed(2)}</div>
            <div style="font-weight: bold;">₹${item.total.toStringAsFixed(2)}</div>
          </div>
        </div>
      ''');
    }

    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <title>POS Receipt</title>
        <style>
          @media print {
            body { margin: 0; padding: 10px; font-family: 'Courier New', monospace; }
            .no-print { display: none; }
          }
          body { font-family: Arial, sans-serif; max-width: 300px; margin: 0 auto; padding: 20px; }
          .header { text-align: center; margin-bottom: 20px; }
          .section { margin: 15px 0; }
          .line { border-top: 1px dashed #000; margin: 10px 0; }
          .total-row { display: flex; justify-content: space-between; font-weight: bold; margin: 5px 0; }
          .item-row { display: flex; justify-content: space-between; margin: 3px 0; }
          .thank-you { text-align: center; margin-top: 20px; font-style: italic; }
          button { padding: 10px 20px; margin: 10px; cursor: pointer; }
        </style>
      </head>
      <body>
        <div class="header">
          <h2>POS AI SALES</h2>
          <p>Receipt</p>
        </div>
        
        <div class="section">
          <div class="item-row"><strong>Customer:</strong> <span>$customer</span></div>
          <div class="item-row"><strong>Order Type:</strong> <span>$orderType</span></div>
          <div class="item-row"><strong>Payment:</strong> <span>$paymentMethod</span></div>
        </div>
        
        <div class="line"></div>
        
        <div class="section">
          <h3>ITEMS</h3>
          $itemsHtml
        </div>
        
        <div class="line"></div>
        
        <div class="section">
          <div class="total-row">
            <span>Subtotal:</span>
            <span>₹${subtotal.toStringAsFixed(2)}</span>
          </div>
          <div class="total-row">
            <span>Tax (15%):</span>
            <span>₹${tax.toStringAsFixed(2)}</span>
          </div>
          <div class="total-row">
            <span>Discount:</span>
            <span>-₹${discount.toStringAsFixed(2)}</span>
          </div>
          <div class="total-row" style="border-top: 2px solid #000; padding-top: 5px;">
            <span>FINAL TOTAL:</span>
            <span>₹${finalTotal.toStringAsFixed(2)}</span>
          </div>
        </div>
        
        <div class="thank-you">
          <p>Thank you for your business!</p>
        </div>
        
        <div class="no-print" style="text-align: center; margin-top: 30px;">
          <button onclick="window.print()">Print Receipt</button>
          <button onclick="window.close()">Close</button>
        </div>
        
        <script>
          // Auto-print and close for better UX
          window.onload = function() {
            setTimeout(function() {
              window.print();
              setTimeout(function() {
                // Don't auto-close as user might want to manually print
              }, 1000);
            }, 500);
          };
        </script>
      </body>
      </html>
    ''';
  }

  Future<void> _printHtmlContent(String htmlContent) async {
    // For web, we open a new window with the receipt and let the user print
    final bytes = convert.utf8.encode(htmlContent);
    final blob = html.Blob([bytes], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final window = html.window.open(url, '_blank');

    // Clean up URL after printing
    Future.delayed(Duration(seconds: 10), () {
      html.Url.revokeObjectUrl(url);
    });
  }

  @override
  Future<bool> isPrinterAvailable() async {
    // For web, we assume printing is always available via browser
    return true;
  }
}
