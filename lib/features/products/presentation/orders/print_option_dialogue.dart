// lib/components/printer_setup_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_ai_sales/features/products/presentation/orders/printer_utility.dart';
import 'package:pos_ai_sales/features/products/presentation/sales_report/printer/thermal_printer_service_new.dart';

class PrinterSetupDialog extends ConsumerStatefulWidget {
  const PrinterSetupDialog({super.key});

  @override
  ConsumerState<PrinterSetupDialog> createState() => _PrinterSetupDialogState();
}

class _PrinterSetupDialogState extends ConsumerState<PrinterSetupDialog> {
  final _ipController = TextEditingController();
  final _portController = TextEditingController(text: '9100');

  @override
  void initState() {
    super.initState();
    final state = ref.read(printerProvider);
    _ipController.text = state.printerIp ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final printerState = ref.watch(printerProvider);
    final printerNotifier = ref.read(printerProvider.notifier);

    return AlertDialog(
      title: const Text('Printer Setup'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _ipController,
            decoration: const InputDecoration(
              labelText: 'Printer IP Address',
              hintText: '192.168.1.100',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _portController,
            decoration: const InputDecoration(
              labelText: 'Port',
              hintText: '9100',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          if (printerState.error != null)
            Text(
              printerState.error!,
              style: const TextStyle(color: Colors.red),
            ),
          if (printerState.lastPrintStatus != null)
            Text(
              printerState.lastPrintStatus!,
              style: TextStyle(
                color: printerState.isConnected ? Colors.green : Colors.orange,
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            await printerNotifier.setPrinterIp(_ipController.text.trim());
          },
          child: const Text('Save IP'),
        ),
        ElevatedButton(
          onPressed: printerState.isLoading
              ? null
              : () async {
                  await printerNotifier.setPrinterIp(_ipController.text.trim());
                  await printerNotifier.testConnection();
                },
          child: printerState.isLoading
              ? const CircularProgressIndicator()
              : const Text('Test Connection'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }
}

class PrintOptionsDialog extends ConsumerWidget {
  final List<Map<String, dynamic>> items;
  final double subtotal;
  final double tax;
  final double discount;
  final double finalTotal;
  final String? customer;
  final String orderType;
  final String paymentMethod;

  const PrintOptionsDialog({
    super.key,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.finalTotal,
    required this.customer,
    required this.orderType,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('Print Receipt'),
      content: const Text('Choose how you want to generate the receipt:'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        // Thermal Print Button
        ElevatedButton.icon(
          onPressed: () async {
            Navigator.pop(context);
            await _printThermalReceipt(context);
          },
          icon: const Icon(Icons.print),
          label: const Text('Print Thermal'),
        ),
        // PDF Download Button
        ElevatedButton.icon(
          onPressed: () async {
            Navigator.pop(context);
            await _downloadPdfReceipt(context);
          },
          icon: const Icon(Icons.download),
          label: const Text('Download PDF'),
        ),
        // Both Button
        ElevatedButton.icon(
          onPressed: () async {
            Navigator.pop(context);
            await _printBothReceipts(context);
          },
          icon: const Icon(Icons.print),
          label: const Text('Print Both'),
        ),
      ],
    );
  }

  Future<void> _printThermalReceipt(BuildContext context) async {
    try {
      await PrinterUtil.printCartOrder(
        items: items,
        subtotal: subtotal,
        tax: tax,
        discount: discount,
        finalTotal: finalTotal,
        customer: customer,
        orderType: orderType,
        paymentMethod: paymentMethod,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receipt printed successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Print failed: $e')),
        );
      }
    }
  }

  Future<void> _downloadPdfReceipt(BuildContext context) async {
    try {
      await PrinterUtil.downloadAndOpenPdf(
        items: items,
        subtotal: subtotal,
        tax: tax,
        discount: discount,
        finalTotal: finalTotal,
        customer: customer,
        orderType: orderType,
        paymentMethod: paymentMethod,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF downloaded successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF download failed: $e')),
        );
      }
    }
  }

  Future<void> _printBothReceipts(BuildContext context) async {
    try {
      // Print thermal first
      await PrinterUtil.printCartOrder(
        items: items,
        subtotal: subtotal,
        tax: tax,
        discount: discount,
        finalTotal: finalTotal,
        customer: customer,
        orderType: orderType,
        paymentMethod: paymentMethod,
      );

      // Then download PDF
      await PrinterUtil.downloadAndOpenPdf(
        items: items,
        subtotal: subtotal,
        tax: tax,
        discount: discount,
        finalTotal: finalTotal,
        customer: customer,
        orderType: orderType,
        paymentMethod: paymentMethod,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receipt printed and PDF downloaded!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Operation failed: $e')),
        );
      }
    }
  }
}
