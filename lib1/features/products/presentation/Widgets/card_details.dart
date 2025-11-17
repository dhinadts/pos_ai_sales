import 'package:flutter/material.dart';
import 'package:pos_ai_sales/core/models/customer.dart';
import 'package:uuid/uuid.dart';

class CardItem extends StatelessWidget {
  final String? pageTitle;
  final UuidValue id;
  final Customer? customer;
  final void Function()? onEdit;
  final void Function()? onDelete;
  final String? imageUrl; // Add this parameter for image URL

  const CardItem({
    super.key,
    this.pageTitle,
    required this.id,
    required this.customer,
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
                  pageTitle == 'customer'
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
