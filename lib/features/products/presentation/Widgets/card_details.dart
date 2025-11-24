import 'package:flutter/material.dart';
import 'package:pos_ai_sales/core/utilits/responsive_design.dart';
import 'package:uuid/uuid.dart';

import 'package:pos_ai_sales/core/models/customer.dart';
import 'package:pos_ai_sales/core/models/supplier.dart';
import 'package:pos_ai_sales/core/models/expense.dart';

class CardItem extends StatelessWidget {
  final String pageTitle;
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
                  if (pageTitle == "customer" || pageTitle == "supplier")
                    IconButton(
                      icon: const Icon(Icons.phone, color: Colors.green),
                      onPressed: () {},
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ),
            Column(children: details.map((e) => buildInfoRow(e)).toList()),
          ],
        ),
      ),
    );
  }
}
