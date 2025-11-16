import 'package:flutter/material.dart';

class EditableFieldBox extends StatelessWidget {
  final String value;
  final int maxLines;
  final TextEditingController controller;
  final VoidCallback? onEdit;

  const EditableFieldBox({
    super.key,
    required this.value,
    required this.controller,
    this.maxLines = 1,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xff00B4F0), width: 2),
      ),
      padding: const EdgeInsets.only(left: 14, right: 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              decoration: InputDecoration(
                hintText: value,
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xff00B4F0)),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}
