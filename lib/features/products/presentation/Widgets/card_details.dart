/* import 'package:flutter/material.dart';
import 'package:pos_ai_sales/core/models/customer.dart';

class CustomerCardItem extends StatelessWidget {
  final Customer customer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ResponsiveDesign responsive;

  const CustomerCardItem({
    super.key,
    required this.customer,
    required this.onEdit,
    required this.onDelete,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(responsive.getWidth(12)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with avatar and actions
              Row(
                children: [
                  // Avatar
                  Container(
                    width: responsive.getWidth(44),
                    height: responsive.getWidth(44),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xff00B4F0).withOpacity(0.1),
                    ),
                    child: customer.imagePath != null
                        ? ClipOval(
                            child: Image.network(
                              customer.imagePath!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Text(
                                    customer.name.isNotEmpty ? customer.name[0].toUpperCase() : "?",
                                    style: TextStyle(
                                      fontSize: responsive.getTextSize(16),
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xff00B4F0),
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : Center(
                            child: Text(
                              customer.name.isNotEmpty ? customer.name[0].toUpperCase() : "?",
                              style: TextStyle(
                                fontSize: responsive.getTextSize(16),
                                fontWeight: FontWeight.bold,
                                color: const Color(0xff00B4F0),
                              ),
                            ),
                          ),
                  ),
                  
                  SizedBox(width: responsive.getWidth(12)),
                  
                  // Customer name
                  Expanded(
                    child: Text(
                      customer.name,
                      style: TextStyle(
                        fontSize: responsive.getTextSize(16),
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  // Action buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Call button
                      IconButton(
                        onPressed: customer.phone != null && customer.phone!.isNotEmpty
                            ? () {
                                // Implement call functionality
                              }
                            : null,
                        icon: Icon(
                          Icons.phone,
                          size: responsive.getIconSize(20),
                          color: customer.phone != null && customer.phone!.isNotEmpty
                              ? Colors.green
                              : Colors.grey,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      
                      SizedBox(width: responsive.getWidth(8)),
                      
                      // Delete button
                      IconButton(
                        onPressed: onDelete,
                        icon: Icon(
                          Icons.delete_outline,
                          size: responsive.getIconSize(20),
                          color: Colors.red,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
              
              SizedBox(height: responsive.getHeight(12)),
              
              // Customer details
              _buildDetailRow(
                Icons.phone,
                customer.phone ?? 'Not provided',
                responsive,
              ),
              
              SizedBox(height: responsive.getHeight(8)),
              
              _buildDetailRow(
                Icons.email,
                customer.email ?? 'Not provided',
                responsive,
              ),
              
              SizedBox(height: responsive.getHeight(8)),
              
              _buildDetailRow(
                Icons.location_on,
                customer.address ?? 'Not provided',
                responsive,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, ResponsiveDesign responsive, {int maxLines = 1}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: responsive.getIconSize(16),
          color: Colors.grey,
        ),
        SizedBox(width: responsive.getWidth(8)),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: responsive.getTextSize(14),
              color: Colors.grey[700],
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
 */
import 'package:flutter/material.dart';
import 'package:pos_ai_sales/core/utilits/responsive_design.dart';
import 'package:uuid/uuid.dart';

import 'package:pos_ai_sales/core/models/customer.dart';
import 'package:pos_ai_sales/core/models/supplier.dart';
import 'package:pos_ai_sales/core/models/expense.dart';

class CardItem extends StatelessWidget {
  final String pageTitle; // "customer", "supplier", "expense"
  final UuidValue id;
  final Customer? customer;
  final Supplier? supplier;
  final Expense? expense;
  final ResponsiveInfo? responsive;

  final void Function()? onEdit;
  final void Function()? onDelete;

  const CardItem({
    super.key,
    required this.pageTitle,
    required this.id,
    this.customer,
    this.supplier,
    this.expense,
    this.onEdit,
    this.onDelete,
    this.responsive,
  });

  // -------------------------
  // Get Title & Image & Fields
  // -------------------------

  String getTitle() {
    if (pageTitle == "customer") return customer?.name ?? "Unknown Customer";
    if (pageTitle == "supplier") return supplier?.name ?? "Unknown Supplier";
    if (pageTitle == "expense") return expense?.name ?? "Unknown Expense";
    return "";
  }

  String? getImage() {
    if (pageTitle == "customer") return customer?.imagePath;
    if (pageTitle == "supplier") return supplier?.imagePath;
    return null;
  }

  List<String> getDetails() {
    if (pageTitle == "customer") {
      return [
        customer?.phone ?? "Phone: N/A",
        customer?.email ?? "Email: N/A",
        customer?.address ?? "Address: N/A",
      ];
    }

    if (pageTitle == "supplier") {
      return [
        supplier?.phone ?? "Phone: N/A",
        supplier?.email ?? "Email: N/A",
        supplier?.address ?? "Address: N/A",
      ];
    }

    if (pageTitle == "expense") {
      return [
        "Amount: ₹${expense?.amount.toString() ?? '0'}",
        "Category: ${expense?.name ?? 'N/A'}",
        "Date: ${expense?.date ?? 'N/A'}",
        expense?.note ?? "No description",
      ];
    }

    return [];
  }

  // -------------------------
  // UI Builders
  // -------------------------

  Widget buildInfoRow(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!)),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String title = getTitle();
    final String? image = getImage();
    final List<String> details = getDetails();

    return InkWell(
      key: Key(id.uuid),
      onTap: onEdit,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            // ---------------- Header ----------------
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.blue,
                    backgroundImage: image != null ? NetworkImage(image) : null,
                    child: image == null
                        ? Text(
                            title.isNotEmpty ? title[0].toUpperCase() : "?",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ),

                  // Phone Icon for customer/supplier only
                  if (pageTitle == "customer" || pageTitle == "supplier")
                    IconButton(
                      icon: const Icon(Icons.phone, color: Colors.green),
                      onPressed: () {
                        // Implement call function here
                      },
                    ),

                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ),

            // ---------------- Body Details ----------------
            Column(children: details.map((e) => buildInfoRow(e)).toList()),
          ],
        ),
      ),
    );
  }
}



/* import 'package:flutter/material.dart';
import 'package:pos_ai_sales/core/models/customer.dart';
import 'package:pos_ai_sales/core/models/expense.dart';
import 'package:pos_ai_sales/core/models/supplier.dart';
import 'package:uuid/uuid.dart';

class CardItem extends StatelessWidget {
  final String? pageTitle;
  final UuidValue id;
  final Customer? customer;
  final Supplier? supplier;
  final Expense? expence;
  final void Function()? onEdit;
  final void Function()? onDelete;
  final String? imageUrl; // Add this parameter for image URL

  const CardItem({
    super.key,
    this.pageTitle,
    required this.id,
    this.customer,
    this.supplier,
    this.expence,
    this.onEdit,
    this.onDelete,
    this.imageUrl, // Add this parameter
  });

  Widget _buildCustomerInfo() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                // Larger CircleAvatar with image
                CircleAvatar(
                  radius: 20, // Increased from 12 to 20
                  backgroundColor: Colors.blue,
                  backgroundImage: imageUrl != null
                      ? NetworkImage(customer!.imagePath!)
                      : null,
                  child: imageUrl == null
                      ? Text(
                          customer!.name.isNotEmpty
                              ? customer!.name[0].toUpperCase()
                              : '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16, // Increased font size
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                // const SizedBox(width: 12),
                // const Icon(Icons.person, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${customer!.name} ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info rows
                      _buildInfoRow(customer!.name),
                      _buildInfoRow(customer!.phone ?? 'N/A'),
                      _buildInfoRow(customer!.email ?? 'N/A'),
                      _buildInfoRow(customer!.address ?? 'N/A'),
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  pageTitle == 'customer' || pageTitle == 'supplier'
                      ? IconButton(
                          icon: const Icon(Icons.phone, color: Colors.green),
                          onPressed: () => {},
                        )
                      : const SizedBox.shrink(),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onEdit?.call(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: _buildCustomerInfo(),
      ),
    );
  }
}
 */