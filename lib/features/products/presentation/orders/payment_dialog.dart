import 'package:flutter/material.dart';

class PaymentDialog extends StatefulWidget {
  final Function(String, String, String, String) onOrderSubmit;

  const PaymentDialog({Key? key, required this.onOrderSubmit})
      : super(key: key);

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  String selectedCustomer = "Walk In Customer";
  String selectedOrderType = "PICK UP";
  String selectedPaymentMethod = "CASH";
  String selectedDiscount = "0.00";

  final List<String> customers = [
    "Walk In Customer",
    "Regular Customer",
    "VIP Customer",
    "New Customer"
  ];

  final List<String> orderTypes = [
    "PICK UP",
    "DELIVERY",
    "DINE IN",
    "TAKE AWAY"
  ];

  final List<String> paymentMethods = [
    "CASH",
    "CARD",
    "PAYPAL",
    "BANK TRANSFER",
    "DIGITAL WALLET"
  ];

  final List<String> discounts = [
    "0.00",
    "5.00",
    "10.00",
    "15.00",
    "20.00",
    "25.00",
    "Custom"
  ];

  void _showSearchableDropdown({
    required String title,
    required List<String> items,
    required String currentValue,
    required Function(String) onSelected,
  }) {
    showDialog(
      context: context,
      builder: (context) => SearchableDropdownDialog(
        title: title,
        items: items,
        currentValue: currentValue,
        onSelected: onSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = 250.00; // Replace with actual subtotal
    final taxRate = 0.15;
    final taxAmount = subtotal * taxRate;
    final discountAmount = double.tryParse(selectedDiscount) ?? 0.0;
    final finalTotal = subtotal + taxAmount - discountAmount;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      backgroundColor: Colors.white,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Center(
              child: Text(
                "Order Summary",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Customer Dropdown
            _buildDropdownSection(
              label: "Customer",
              value: selectedCustomer,
              icon: Icons.person,
              onTap: () => _showSearchableDropdown(
                title: "SELECT CUSTOMER",
                items: customers,
                currentValue: selectedCustomer,
                onSelected: (value) {
                  setState(() {
                    selectedCustomer = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 10),

            // Order Type Dropdown
            _buildDropdownSection(
              label: "Order Type",
              value: selectedOrderType,
              icon: Icons.takeout_dining,
              onTap: () => _showSearchableDropdown(
                title: "SELECT ORDER TYPE",
                items: orderTypes,
                currentValue: selectedOrderType,
                onSelected: (value) {
                  setState(() {
                    selectedOrderType = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 10),

            // Payment Method Dropdown
            _buildDropdownSection(
              label: "Payment Method",
              value: selectedPaymentMethod,
              icon: Icons.payment,
              onTap: () => _showSearchableDropdown(
                title: "SELECT PAYMENT METHOD",
                items: paymentMethods,
                currentValue: selectedPaymentMethod,
                onSelected: (value) {
                  setState(() {
                    selectedPaymentMethod = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 10),

            // Discount Dropdown
            _buildDropdownSection(
              label: "Discount",
              value: "₹$selectedDiscount",
              icon: Icons.discount,
              onTap: () => _showSearchableDropdown(
                title: "SELECT DISCOUNT",
                items: discounts,
                currentValue: selectedDiscount,
                onSelected: (value) {
                  setState(() {
                    selectedDiscount = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),

            // Divider
            const Divider(thickness: 1, color: Colors.grey),
            const SizedBox(height: 15),

            // Price Breakdown
            _buildPriceRow("Sub Total", "₹${subtotal.toStringAsFixed(2)}"),
            const SizedBox(height: 8),
            _buildPriceRow(
                "Total Tax(15%)", "₹${taxAmount.toStringAsFixed(2)}"),
            const SizedBox(height: 8),
            _buildPriceRow(
                "Discount", "-₹${discountAmount.toStringAsFixed(2)}"),
            const SizedBox(height: 15),

            // Divider
            const Divider(thickness: 1, color: Colors.grey),
            const SizedBox(height: 15),

            // Total Price
            Center(
              child: Text(
                "Total Price: ₹${finalTotal.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  widget.onOrderSubmit(
                    selectedCustomer,
                    selectedOrderType,
                    selectedPaymentMethod,
                    selectedDiscount,
                  );
                  Navigator.pop(context);
                },
                child: const Text(
                  "SUBMIT ORDER",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownSection({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[700]),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class SearchableDropdownDialog extends StatefulWidget {
  final String title;
  final List<String> items;
  final String currentValue;
  final Function(String) onSelected;

  const SearchableDropdownDialog({
    Key? key,
    required this.title,
    required this.items,
    required this.currentValue,
    required this.onSelected,
  }) : super(key: key);

  @override
  State<SearchableDropdownDialog> createState() =>
      _SearchableDropdownDialogState();
}

class _SearchableDropdownDialogState extends State<SearchableDropdownDialog> {
  late List<String> filteredItems;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;
    searchController.addListener(_filterItems);
  }

  void _filterItems() {
    final query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredItems = widget.items;
      } else {
        filteredItems = widget.items
            .where((item) => item.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Title
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Type something to search...",
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Items List
            Expanded(
              child: filteredItems.isEmpty
                  ? const Center(
                      child: Text(
                        "No items found",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return ListTile(
                          leading: widget.currentValue == item
                              ? const Icon(Icons.check, color: Colors.green)
                              : const Icon(Icons.radio_button_unchecked,
                                  color: Colors.grey),
                          title: Text(item),
                          onTap: () {
                            widget.onSelected(item);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),

            // Cancel Button
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey,
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Cancel"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
