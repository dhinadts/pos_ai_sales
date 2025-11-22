/* import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pos_ai_sales/core/utilits/thermal_printer/printer_manager.dart';

class PrintScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const PrintScreen({super.key, required this.cartItems});

  @override
  State<PrintScreen> createState() => _PrintScreenState();
}

class _PrintScreenState extends State<PrintScreen> {
  final PrintManager _printManager = PrintManager();
  List<Map<String, dynamic>> _availablePrinters = [];
  String? _selectedPrinterId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPrinters();
  }

  Future<void> _loadPrinters() async {
    setState(() => _isLoading = true);
    try {
      _availablePrinters = await _printManager.getAvailablePrinters();
    } catch (e) {
      print('Error loading printers: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _printReceipt() async {
    setState(() => _isLoading = true);
    try {
      await _printManager.printReceipt(
        items: widget.cartItems,
        printerType: kIsWeb ? PrinterType.browser : PrinterType.bluetooth,
        printerAddress: _selectedPrinterId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receipt printed successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Print failed: $e')));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Print Receipt')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (!kIsWeb) ...[
              const Text('Select Printer:', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                DropdownButton<String>(
                  value: _selectedPrinterId,
                  hint: const Text('Choose a printer'),
                  items: _availablePrinters.map<DropdownMenuItem<String>>((
                    printer,
                  ) {
                    return DropdownMenuItem<String>(
                      value: printer['id'] as String, // Explicit cast to String
                      child: Text(
                        printer['name'] as String,
                      ), // Explicit cast to String
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => _selectedPrinterId = value),
                ),
              const SizedBox(height: 20),
            ],

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _printReceipt,
              icon: const Icon(Icons.print),
              label: Text(_isLoading ? 'Printing...' : 'Print Receipt'),
            ),

            // Preview
            Expanded(child: _buildReceiptPreview()),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptPreview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MY STORE',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text('Receipt Preview'),
            const Divider(),

            for (var item in widget.cartItems)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(child: Text(item['name'])),
                    Text('x${item['quantity']}'),
                    const SizedBox(width: 20),
                    Text('\$${item['price']}'),
                  ],
                ),
              ),

            const Divider(),
            const Text('Thank you for your business!'),
          ],
        ),
      ),
    );
  }
}
 */