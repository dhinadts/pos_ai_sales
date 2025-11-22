// lib/providers/printer_provider.dart
import 'package:esc_pos_printer_plus/esc_pos_printer_plus.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pos_ai_sales/features/products/presentation/sales_report/printer/thermal_printer_service.dart';

class PrinterState {
  final String? printerIp;
  final bool isConnected;
  final bool isLoading;
  final String? error;
  final String? lastPrintStatus;

  PrinterState({
    this.printerIp,
    this.isConnected = false,
    this.isLoading = false,
    this.error,
    this.lastPrintStatus,
  });

  PrinterState copyWith({
    String? printerIp,
    bool? isConnected,
    bool? isLoading,
    String? error,
    String? lastPrintStatus,
  }) {
    return PrinterState(
      printerIp: printerIp ?? this.printerIp,
      isConnected: isConnected ?? this.isConnected,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastPrintStatus: lastPrintStatus ?? this.lastPrintStatus,
    );
  }
}

class PrinterNotifier extends StateNotifier<PrinterState> {
  final ThermalPrinterService _printerService = ThermalPrinterService();

  PrinterNotifier() : super(PrinterState());

  Future<void> setPrinterIp(String ip) async {
    state = state.copyWith(printerIp: ip, error: null);
  }

  Future<void> testConnection() async {
    if (state.printerIp == null) {
      state = state.copyWith(error: 'Please set printer IP address');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _printerService.testPrinter(state.printerIp!);

      if (result == PosPrintResult.success) {
        state = state.copyWith(
          isLoading: false,
          isConnected: true,
          lastPrintStatus: 'Printer test successful',
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isConnected: false,
          error: 'Printer test failed: $result',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isConnected: false,
        error: 'Connection error: $e',
      );
    }
  }

  Future<PosPrintResult> printReceipt({
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double tax,
    required double discount,
    required double finalTotal,
    required String? customer,
    required String orderType,
    required String paymentMethod,
  }) async {
    if (state.printerIp == null) {
      throw Exception('Printer IP not set');
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _printerService.printCartOrder(
        items: items,
        subtotal: subtotal,
        tax: tax,
        discount: discount,
        finalTotal: finalTotal,
        customer: customer,
        orderType: orderType,
        paymentMethod: paymentMethod,
        printerIp: state.printerIp!,
      );

      state = state.copyWith(
        isLoading: false,
        lastPrintStatus: result == PosPrintResult.success
            ? 'Receipt printed successfully'
            : 'Print failed: $result',
      );

      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Print error: $e',
      );
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final printerProvider = StateNotifierProvider<PrinterNotifier, PrinterState>(
  (ref) => PrinterNotifier(),
);
