import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ProductCard extends StatelessWidget {
  final UuidValue id;
  final String name;
  final String code;
  final String category;
  final double sellPrice;
  final int stock;
  final String? imagePath;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProductCard({
    super.key,
    required this.id,
    required this.name,
    required this.code,
    required this.category,
    required this.sellPrice,
    required this.stock,
    this.imagePath,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final shortId = name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name.toUpperCase();
    final hasImage = (imagePath != null && imagePath!.isNotEmpty);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: hasImage
                    ? Colors.transparent
                    : Colors.blue.shade100,
                backgroundImage: hasImage ? FileImage(File(imagePath!)) : null,
                child: !hasImage
                    ? Text(
                        shortId,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text("Code : $code"),
                    Text("Category : $category"),
                    Text("Price : ₹ $sellPrice"),
                    Text("Stock : $stock"),
                  ],
                ),
              ),
              Column(
                children: [
/*                   IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: onEdit,
                  ),
 */                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
