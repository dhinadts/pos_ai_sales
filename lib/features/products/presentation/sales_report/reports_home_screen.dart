import 'dart:io';
import 'package:csv/csv.dart';
import 'package:esc_pos_printer_plus/esc_pos_printer_plus.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pos_ai_sales/features/products/domain/sales_record.dart';
import 'package:pos_ai_sales/features/products/presentation/sales_report/pdf_web_service.dart';
import 'package:pos_ai_sales/features/products/presentation/sales_report/printer/thermal_printer_service.dart';
import 'package:pos_ai_sales/features/products/presentation/sales_report/report_chart_widget.dart';
import 'package:pos_ai_sales/features/products/presentation/sales_report/report_pdf_service.dart';

class ReportsHomeScreen extends StatefulWidget {
  const ReportsHomeScreen({super.key});

  @override
  State<ReportsHomeScreen> createState() => _ReportsHomeScreenState();
}

class _ReportsHomeScreenState extends State<ReportsHomeScreen> {
  List<SalesRecord> allSales = [];
  List<SalesRecord> filteredSales = [];
  String selectedRange = 'Daily';
  bool _isLoading = false;
  final List<Map<String, dynamic>> _productCatalog = [];

  @override
  void initState() {
    super.initState();
    _loadSampleSales();
    _initializeProductCatalog();
  }

  void _initializeProductCatalog() {
    // Sample product catalog data
    _productCatalog.addAll([
      {
        'Barcode': '8901234567890',
        'Status': 'Active',
        'Description': 'Wireless Bluetooth Headphones',
        'Category': 'Electronics',
        'Brand': 'SoundMax',
        'Unit': 'Pieces',
        'Tax': '18%',
        'Cost': 1200.00,
        'MRP': 1999.00,
        'Sale Price': 1799.00,
        'Tamil Description': 'வயர்லெஸ் ப்ளூடூத் ஹெட்ஃபோன்கள்',
      },
      {
        'Barcode': '8901234567891',
        'Status': 'Active',
        'Description': 'Cotton T-Shirt',
        'Category': 'Clothing',
        'Brand': 'FashionWear',
        'Unit': 'Pieces',
        'Tax': '12%',
        'Cost': 350.00,
        'MRP': 799.00,
        'Sale Price': 599.00,
        'Tamil Description': 'பருத்தி டி-சட்டை',
      },
      {
        'Barcode': '8901234567892',
        'Status': 'Active',
        'Description': 'Stainless Steel Water Bottle',
        'Category': 'Home & Kitchen',
        'Brand': 'AquaSafe',
        'Unit': 'Pieces',
        'Tax': '18%',
        'Cost': 280.00,
        'MRP': 599.00,
        'Sale Price': 499.00,
        'Tamil Description': 'ஸ்டெயின்லெஸ் ஸ்டீல் தண்ணீர் பாட்டில்',
      },
      {
        'Barcode': '8901234567893',
        'Status': 'Inactive',
        'Description': 'Smart Watch Series 5',
        'Category': 'Electronics',
        'Brand': 'TechGadgets',
        'Unit': 'Pieces',
        'Tax': '18%',
        'Cost': 4500.00,
        'MRP': 7999.00,
        'Sale Price': 6999.00,
        'Tamil Description': 'ஸ்மார்ட் வாட்ச் சீரிஸ் 5',
      },
      {
        'Barcode': '8901234567894',
        'Status': 'Active',
        'Description': 'Sports Running Shoes',
        'Category': 'Sports',
        'Brand': 'RunFast',
        'Unit': 'Pairs',
        'Tax': '12%',
        'Cost': 800.00,
        'MRP': 1999.00,
        'Sale Price': 1499.00,
        'Tamil Description': 'ஸ்போர்ட்ஸ் ரன்னிங் ஷூஸ்',
      },
    ]);
  }

  void _loadSampleSales() {
    final now = DateTime.now();
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      allSales = [
        SalesRecord(
          date: now.subtract(const Duration(days: 4)),
          total: 2400.50,
          productName: "Wireless Bluetooth Headphones",
          code: '8901234567890',
          qty: 2,
          unitPrice: 1200.25,
        ),
        SalesRecord(
          date: now.subtract(const Duration(days: 3)),
          total: 1800.00,
          productName: "Cotton T-Shirt",
          code: '8901234567891',
          qty: 3,
          unitPrice: 600.00,
        ),
        SalesRecord(
          date: now.subtract(const Duration(days: 2)),
          total: 2200.75,
          productName: "Stainless Steel Water Bottle",
          code: '8901234567892',
          qty: 5,
          unitPrice: 440.15,
        ),
        SalesRecord(
          date: now.subtract(const Duration(days: 1)),
          total: 2600.25,
          productName: "Smart Watch Series 5",
          code: '8901234567893',
          qty: 2,
          unitPrice: 1300.12,
        ),
        SalesRecord(
          date: now,
          total: 3000.00,
          productName: "Sports Running Shoes",
          code: '8901234567894',
          qty: 1,
          unitPrice: 3000.00,
        ),
      ];
      _applyFilter();
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _applyFilter() {
    DateTime now = DateTime.now();
    setState(() {
      filteredSales = allSales.where((s) {
        switch (selectedRange) {
          case 'Daily':
            return s.date.day == now.day &&
                s.date.month == now.month &&
                s.date.year == now.year;
          case 'Weekly':
            DateTime startOfWeek = now.subtract(
              Duration(days: now.weekday - 1),
            );
            DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
            return s.date.isAfter(
                  startOfWeek.subtract(const Duration(days: 1)),
                ) &&
                s.date.isBefore(endOfWeek.add(const Duration(days: 1)));
          case 'Monthly':
            return s.date.month == now.month && s.date.year == now.year;
          case 'Yearly':
            return s.date.year == now.year;
          default:
            return true;
        }
      }).toList();
    });
  }

  void _showProductDetails(SalesRecord sale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.inventory_2, color: Colors.blueAccent[700]),
            const SizedBox(width: 8),
            Text(
              "Product Details",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent[700],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Product Information Section
              _buildSectionHeader('Product Information'),
              _buildDetailRow('Barcode', sale.code),
              _buildDetailRow(
                'Status',
                sale.status ?? 'Active',
                isStatus: true,
              ),
              _buildDetailRow('Description', sale.productName),
              _buildDetailRow('Category', sale.category ?? 'General'),
              _buildDetailRow('Brand', sale.brand ?? 'Unknown'),
              _buildDetailRow('Unit', sale.unit ?? 'Pieces'),

              // Pricing Information Section
              _buildSectionHeader('Pricing Information'),
              _buildDetailRow('Tax Rate', sale.tax ?? '0%'),
              _buildDetailRow('Cost Price', _formatCurrency(sale.cost)),
              _buildDetailRow(
                'MRP',
                _formatCurrency(sale.mrp ?? sale.unitPrice),
              ),
              _buildDetailRow('Sale Price', _formatCurrency(sale.unitPrice)),

              // Language Descriptions
              if (sale.tamilDescription != null &&
                  sale.tamilDescription!.isNotEmpty)
                _buildDetailRow('Tamil Description', sale.tamilDescription!),

              if (sale.hindiDescription != null &&
                  sale.hindiDescription!.isNotEmpty)
                _buildDetailRow('Hindi Description', sale.hindiDescription!),

              if (sale.teluguDescription != null &&
                  sale.teluguDescription!.isNotEmpty)
                _buildDetailRow('Telugu Description', sale.teluguDescription!),

              if (sale.kannadaDescription != null &&
                  sale.kannadaDescription!.isNotEmpty)
                _buildDetailRow(
                  'Kannada Description',
                  sale.kannadaDescription!,
                ),

              if (sale.malayalamDescription != null &&
                  sale.malayalamDescription!.isNotEmpty)
                _buildDetailRow(
                  'Malayalam Description',
                  sale.malayalamDescription!,
                ),

              // Additional Fields
              if (sale.hsnCode != null && sale.hsnCode!.isNotEmpty)
                _buildDetailRow('HSN Code', sale.hsnCode!),

              if (sale.sku != null && sale.sku!.isNotEmpty)
                _buildDetailRow('SKU', sale.sku!),

              if (sale.supplier != null && sale.supplier!.isNotEmpty)
                _buildDetailRow('Supplier', sale.supplier!),

              if (sale.manufacturer != null && sale.manufacturer!.isNotEmpty)
                _buildDetailRow('Manufacturer', sale.manufacturer!),

              if (sale.expiryDate != null)
                _buildDetailRow(
                  'Expiry Date',
                  sale.expiryDate!,
                  isWarning: sale.isExpired,
                ),

              if (sale.batchNumber != null && sale.batchNumber!.isNotEmpty)
                _buildDetailRow('Batch Number', sale.batchNumber!),

              // Sales Information Section
              _buildSectionHeader('Sales Information'),
              _buildDetailRow('Quantity Sold', sale.qty.toString()),
              _buildDetailRow('Unit Price', _formatCurrency(sale.unitPrice)),
              _buildDetailRow('Total Amount', _formatCurrency(sale.total)),
              _buildDetailRow(
                'Sale Date',
                DateFormat('dd-MM-yyyy HH:mm').format(sale.date),
              ),

              // Profit Calculation
              if (sale.cost != null) _buildProfitSection(sale),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                final SalesRecord? record = sale;

                if (record == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No record selected to print.')),
                  );
                  return;
                }

                showModalBottomSheet(
                  context: context,
                  builder: (ctx) {
                    return SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: Text('Print via Bluetooth Printer'),
                          ),
                          ListTile(
                            title:
                                Text('Print via Network Thermal Printer (IP)'),
                            onTap: () async {
                              /*   Navigator.pop(ctx);

                              final thermal = ThermalPrinterService();
                              const printerIp =
                                  '192.168.1.100'; // Replace with real printer IP

                              final result = await thermal.printOverNetwork(
                                  record, printerIp);

                              if (result != PosPrintResult.success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Network print failed: $result')),
                                );
                              } */
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: const Text('PRINT')),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
          if (sale.isExpired)
            TextButton(
              onPressed: () {
                // Handle expired product action
                _showExpiredProductWarning(sale);
              },
              child: const Text('EXPIRED', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.blueAccent,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isStatus = false,
    bool isWarning = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: isStatus
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: value == 'Active'
                          ? Colors.green
                          : value == 'Inactive'
                              ? Colors.orange
                              : value == 'Discontinued'
                                  ? Colors.red
                                  : Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      value.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Text(
                    value,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: isWarning ? Colors.red : Colors.black87,
                      backgroundColor: isWarning
                          ? Colors.red.withOpacity(0.1)
                          : Colors.transparent,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfitSection(SalesRecord sale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Profit Analysis'),
        _buildDetailRowWithColor('Cost per Unit', _formatCurrency(sale.cost)),
        _buildDetailRowWithColor(
          'Profit per Unit',
          _formatCurrency(sale.profitPerUnit),
          isPositive: sale.profitPerUnit >= 0,
        ),
        _buildDetailRowWithColor(
          'Total Profit',
          _formatCurrency(sale.totalProfit),
          isPositive: sale.totalProfit >= 0,
        ),
        _buildDetailRowWithColor(
          'Profit Margin',
          '${sale.profitMargin.toStringAsFixed(2)}%',
          isPositive: sale.profitMargin >= 0,
        ),
      ],
    );
  }

  Widget _buildDetailRowWithColor(
    String label,
    String value, {
    bool isPositive = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isPositive ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '₹0.00';
    if (amount is String) {
      final parsed = double.tryParse(amount) ?? 0.0;
      return '₹${parsed.toStringAsFixed(2)}';
    }
    final value = (amount as num).toDouble();
    return '₹${value.toStringAsFixed(2)}';
  }

  void _showExpiredProductWarning(SalesRecord sale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Expired Product'),
          ],
        ),
        content: Text(
          'The product "${sale.productName}" has expired.\nExpiry Date: ${sale.expiryDate}\n\nPlease remove this product from sales.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _importFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx'],
    );

    if (result == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final file = File(result.files.single.path!);
      final extension = file.path.split('.').last.toLowerCase();

      List<SalesRecord> imported = [];
      if (extension == 'csv') {
        final content = await file.readAsString();
        final rows = const CsvToListConverter().convert(content, eol: '\n');
        for (int i = 1; i < rows.length; i++) {
          imported.add(
            SalesRecord.fromMap({
              'date': rows[i][0].toString(),
              'productName': rows[i][1].toString(),
              'total': rows[i][2].toString(),
              'qty': rows[i].length > 3 ? rows[i][3].toString() : '1',
              'unitPrice': rows[i].length > 4 ? rows[i][4].toString() : '0',
              'code': rows[i].length > 5 ? rows[i][5].toString() : '',
            }),
          );
        }
      } else if (extension == 'xlsx') {
        final bytes = await file.readAsBytes();
        final excel = Excel.decodeBytes(bytes);
        final sheet = excel.tables.values.first;
        for (int i = 1; i < sheet.rows.length; i++) {
          final row = sheet.rows[i];
          imported.add(
            SalesRecord.fromMap({
              'date': row[0]?.value.toString() ?? '',
              'productName': row[1]?.value.toString() ?? '',
              'total': row[2]?.value.toString() ?? '',
              'qty': row.length > 3 ? row[3]?.value.toString() ?? '1' : '1',
              'unitPrice':
                  row.length > 4 ? row[4]?.value.toString() ?? '0' : '0',
              'code': row.length > 5 ? row[5]?.value.toString() ?? '' : '',
            }),
          );
        }
      }

      setState(() {
        allSales = imported;
        _applyFilter();
        _isLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Imported ${imported.length} sales records."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error importing file: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _exportPdf() async {
    if (filteredSales.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No data available to export"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });
    if (kIsWeb) {
      try {
        await ReportPdfServiceWeb.generateSalesReport(
          filteredSales,
          selectedRange,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "PDF generated successfully for $selectedRange report",
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error generating PDF: $e"),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      try {
        await ReportPdfService.generateSalesReport(
          filteredSales,
          selectedRange,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "PDF generated successfully for $selectedRange report",
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error generating PDF: $e"),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.go('/home');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Sales Reports"),
          backgroundColor: Colors.cyan,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => context.go('/home'),
          ),
          /* actions: [
            IconButton(
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Icon(Icons.file_upload),
              tooltip: "Import CSV / Excel",
              onPressed: _isLoading ? null : _importFile,
            ), */
          /* IconButton(
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Icon(Icons.picture_as_pdf),
              tooltip: "Export & Print PDF",
              onPressed: _isLoading ? null : _exportPdf,
            // ), */
          // ],
        ),
        body: _isLoading
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading sales data...',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Filter Section
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Report Period",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          DropdownButton<String>(
                            value: selectedRange,
                            items: const [
                              DropdownMenuItem(
                                value: 'Daily',
                                child: Text('Daily'),
                              ),
                              DropdownMenuItem(
                                value: 'Weekly',
                                child: Text('Weekly'),
                              ),
                              DropdownMenuItem(
                                value: 'Monthly',
                                child: Text('Monthly'),
                              ),
                              DropdownMenuItem(
                                value: 'Yearly',
                                child: Text('Yearly'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  selectedRange = val;
                                });
                                _applyFilter();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Chart Section
                  ReportChartWidget(
                    salesData: allSales.map((e) => e.toMap()).toList(),
                    filterType: selectedRange.toLowerCase(),
                    chartType: 'multi_line',
                  ),

                  const SizedBox(height: 20),

                  // Sales Details Section
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Sales Details",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Total Records: ${filteredSales.length}",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Sales List
                  ...filteredSales.map((s) {
                    final dateStr = DateFormat('dd-MM-yyyy').format(s.date);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 1,
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.shopping_cart,
                            color: Colors.blueAccent,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          s.productName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text("Date: $dateStr • Qty: ${s.qty}"),
                        trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "₹${s.total.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              "₹${s.unitPrice.toStringAsFixed(2)}/unit",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        onTap: () => _showProductDetails(s),
                      ),
                    );
                  }),

                  if (filteredSales.isEmpty) ...[
                    const SizedBox(height: 40),
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No sales records found',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}



/* import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_ai_sales/features/products/domain/sales_record.dart';
import 'package:pos_ai_sales/features/products/presentation/sales_report/report_chart_widget.dart';
import 'package:pos_ai_sales/features/products/presentation/sales_report/report_pdf_service.dart';

class ReportsHomeScreen extends StatefulWidget {
  const ReportsHomeScreen({super.key});

  @override
  State<ReportsHomeScreen> createState() => _ReportsHomeScreenState();
}

class _ReportsHomeScreenState extends State<ReportsHomeScreen> {
  List<SalesRecord> allSales = [];
  List<SalesRecord> filteredSales = [];
  String selectedRange = 'Daily';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSampleSales();
  }

  void _loadSampleSales() {
    final now = DateTime.now();
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      allSales = [
        SalesRecord(
          date: now.subtract(const Duration(days: 4)),
          total: 2400.50,
          productName: "Product A",
          code: 'A001',
          qty: 2,
          unitPrice: 1200.25,
        ),
        SalesRecord(
          date: now.subtract(const Duration(days: 3)),
          total: 1800.00,
          productName: "Product B",
          code: 'B002',
          qty: 3,
          unitPrice: 600.00,
        ),
        SalesRecord(
          date: now.subtract(const Duration(days: 2)),
          total: 2200.75,
          productName: "Product C",
          code: 'C003',
          qty: 5,
          unitPrice: 440.15,
        ),
        SalesRecord(
          date: now.subtract(const Duration(days: 1)),
          total: 2600.25,
          productName: "Product D",
          code: 'D004',
          qty: 2,
          unitPrice: 1300.12,
        ),
        SalesRecord(
          date: now,
          total: 3000.00,
          productName: "Product E",
          code: 'E005',
          qty: 1,
          unitPrice: 3000.00,
        ),
      ];
      _applyFilter();
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _applyFilter() {
    DateTime now = DateTime.now();
    setState(() {
      filteredSales = allSales.where((s) {
        switch (selectedRange) {
          case 'Daily':
            return s.date.day == now.day &&
                s.date.month == now.month &&
                s.date.year == now.year;
          case 'Weekly':
            DateTime startOfWeek = now.subtract(
              Duration(days: now.weekday - 1),
            );
            DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
            return s.date.isAfter(
                  startOfWeek.subtract(const Duration(days: 1)),
                ) &&
                s.date.isBefore(endOfWeek.add(const Duration(days: 1)));
          case 'Monthly':
            return s.date.month == now.month && s.date.year == now.year;
          case 'Yearly':
            return s.date.year == now.year;
          default:
            return true;
        }
      }).toList();
    });
  }

  Future<void> _importFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx'],
    );

    if (result == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final file = File(result.files.single.path!);
      final extension = file.path.split('.').last.toLowerCase();

      List<SalesRecord> imported = [];
      if (extension == 'csv') {
        final content = await file.readAsString();
        final rows = const CsvToListConverter().convert(content, eol: '\n');
        for (int i = 1; i < rows.length; i++) {
          imported.add(
            SalesRecord.fromMap({
              'date': rows[i][0].toString(),
              'productName': rows[i][1].toString(),
              'total': rows[i][2].toString(),
              'qty': rows[i].length > 3 ? rows[i][3].toString() : '1',
              'unitPrice': rows[i].length > 4 ? rows[i][4].toString() : '0',
            }),
          );
        }
      } else if (extension == 'xlsx') {
        final bytes = await file.readAsBytes();
        final excel = Excel.decodeBytes(bytes);
        final sheet = excel.tables.values.first;
        for (int i = 1; i < sheet!.rows.length; i++) {
          final row = sheet.rows[i];
          imported.add(
            SalesRecord.fromMap({
              'date': row[0]?.value.toString() ?? '',
              'productName': row[1]?.value.toString() ?? '',
              'total': row[2]?.value.toString() ?? '',
              'qty': row.length > 3 ? row[3]?.value.toString() ?? '1' : '1',
              'unitPrice': row.length > 4
                  ? row[4]?.value.toString() ?? '0'
                  : '0',
            }),
          );
        }
      }

      setState(() {
        allSales = imported;
        _applyFilter();
        _isLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Imported ${imported.length} sales records."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error importing file: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _exportPdf() async {
    if (filteredSales.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No data available to export"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ReportPdfService.generateSalesReport(filteredSales, selectedRange);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("PDF generated successfully for $selectedRange report"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error generating PDF: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sales Reports"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : const Icon(Icons.file_upload),
            tooltip: "Import CSV / Excel",
            onPressed: _isLoading ? null : _importFile,
          ),
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : const Icon(Icons.picture_as_pdf),
            tooltip: "Export & Print PDF",
            onPressed: _isLoading ? null : _exportPdf,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading sales data...', style: TextStyle(fontSize: 16)),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Filter Section
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Report Period",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        DropdownButton<String>(
                          value: selectedRange,
                          items: const [
                            DropdownMenuItem(
                              value: 'Daily',
                              child: Text('Daily'),
                            ),
                            DropdownMenuItem(
                              value: 'Weekly',
                              child: Text('Weekly'),
                            ),
                            DropdownMenuItem(
                              value: 'Monthly',
                              child: Text('Monthly'),
                            ),
                            DropdownMenuItem(
                              value: 'Yearly',
                              child: Text('Yearly'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                selectedRange = val;
                              });
                              _applyFilter();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Chart Section
                ReportChartWidget(
                  salesData: allSales.map((e) => e.toMap()).toList(),
                  filterType: selectedRange.toLowerCase(),
                ),

                const SizedBox(height: 20),

                // Sales Details Section
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Sales Details",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Total Records: ${filteredSales.length}",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Sales List
                ...filteredSales.map((s) {
                  final dateStr = DateFormat('dd-MM-yyyy').format(s.date);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    elevation: 1,
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.shopping_cart,
                          color: Colors.blueAccent,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        s.productName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text("Date: $dateStr • Qty: ${s.qty}"),
                      trailing: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "₹${s.total.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            "₹${s.unitPrice.toStringAsFixed(2)}/unit",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                if (filteredSales.isEmpty) ...[
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No sales records found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
 */