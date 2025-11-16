import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_ai_sales/features/products/presentation/all_sales_transactions/sales_modal.dart';

class SalesAll extends ConsumerStatefulWidget {
  const SalesAll({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SalesAllState();
}

class _SalesAllState extends ConsumerState<SalesAll> {
  List<Transaction> filteredTransactions = sampleTransactions;
  final TextEditingController _searchController = TextEditingController();

  void _filterTransactions(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredTransactions = sampleTransactions;
      } else {
        filteredTransactions = sampleTransactions.where((transaction) {
          return transaction.customerName.toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              transaction.transactionCode.toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              transaction.paymentMethod.toLowerCase().contains(
                query.toLowerCase(),
              );
        }).toList();
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'refunded':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _filterTransactions(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('All Sales Transactions'),
          elevation: 0,
          backgroundColor: const Color(0xff00B4F0),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => context.go('/home'),
          ),
        ),
        body: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText:
                            "Search by customer, code, or payment method...",
                        suffixIcon: Icon(Icons.search, color: Colors.blue),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 1),
                          borderRadius: BorderRadius.zero,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 1),
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                    ),
                  ),
                ),
                DropdownMenu(
                  dropdownMenuEntries: [
                    DropdownMenuEntry(value: 0, label: "Today"),
                    DropdownMenuEntry(value: 1, label: "Yesterday"),
                    DropdownMenuEntry(value: 2, label: "Last Week"),
                    DropdownMenuEntry(value: 3, label: "Last Month"),
                    DropdownMenuEntry(value: 4, label: "Last Year"),
                    DropdownMenuEntry(value: 5, label: 'Custom Date'),
                  ],
                  onSelected: (value) {
                    // Implement date filtering logic here
                  },
                ),
              ],
            ),
            Expanded(
              child: filteredTransactions.isEmpty
                  ? Center(
                      child: Text(
                        'No transactions found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      itemCount: filteredTransactions.length,
                      itemBuilder: (_, index) {
                        final transaction = filteredTransactions[index];
                        return Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          elevation: 1,
                          child: ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.receipt,
                                color: Colors.blue,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              transaction.customerName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Code: ${transaction.transactionCode}'),
                                Text('Date: ${transaction.formattedDate}'),
                                Text('Items: ${transaction.itemsCount}'),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(
                                          transaction.status,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: _getStatusColor(
                                            transaction.status,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        transaction.status,
                                        style: TextStyle(
                                          color: _getStatusColor(
                                            transaction.status,
                                          ),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      '• ${transaction.paymentMethod}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                if (transaction.notes != null &&
                                    transaction.notes!.isNotEmpty)
                                  Text(
                                    'Note: ${transaction.notes}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange.shade700,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  transaction.formattedAmount,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Total',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
