// lib/utils/printer_util.dart
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_ai_sales/features/products/presentation/orders/pdf_service.dart';
import 'package:pos_ai_sales/features/products/presentation/sales_report/printer/thermal_printer_service.dart';
import 'package:pos_ai_sales/features/products/presentation/sales_report/printer/thermal_printer_service_new.dart';

class PrinterUtil {
  static Future<void> printThermalReceipt({
    required WidgetRef ref,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double tax,
    required double discount,
    required double finalTotal,
    required String? customer,
    required String orderType,
    required String paymentMethod,
  }) async {
    final printerNotifier = ref.read(printerProvider.notifier);

    await printerNotifier.printReceipt(
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

  static Future<File> generateReceiptPdf({
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double tax,
    required double discount,
    required double finalTotal,
    required String? customer,
    required String orderType,
    required String paymentMethod,
  }) async {
    return await PdfService.generateReceiptPdf(
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

  static Future<void> downloadAndOpenPdf({
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double tax,
    required double discount,
    required double finalTotal,
    required String? customer,
    required String orderType,
    required String paymentMethod,
  }) async {
    final pdfFile = await generateReceiptPdf(
      items: items,
      subtotal: subtotal,
      tax: tax,
      discount: discount,
      finalTotal: finalTotal,
      customer: customer,
      orderType: orderType,
      paymentMethod: paymentMethod,
    );

    await PdfService.openPdf(pdfFile);
  }
  // lib/utils/printer_util.dart

  static Future<void> printCartOrder({
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double tax,
    required double discount,
    required double finalTotal,
    required String? customer,
    required String orderType,
    required String paymentMethod,
  }) async {
    try {
      // Direct call to thermal printer service (no ref needed in dialogs)
      await ThermalPrinterService.printReceipt(
        items: items,
        subtotal: subtotal,
        tax: tax,
        discount: discount,
        finalTotal: finalTotal,
        customer: customer,
        orderType: orderType,
        paymentMethod: paymentMethod,
      );
    } catch (e) {
      rethrow;
    }
  }
}
