import 'package:flutter/material.dart';

enum FieldType { string, integer, decimal }

class EditableFieldBox extends StatefulWidget {
  final String value;
  final int maxLines;
  final TextEditingController controller;
  final VoidCallback? onEdit;

  /// NEW: Type of field (String / Int / Double)
  final FieldType fieldType;

  /// NEW: Optional custom validator
  final String? Function(String?)? validator;

  const EditableFieldBox({
    super.key,
    required this.value,
    required this.controller,
    this.maxLines = 1,
    this.onEdit,
    this.fieldType = FieldType.string,
    this.validator,
  });

  @override
  State<EditableFieldBox> createState() => _EditableFieldBoxState();
}

class _EditableFieldBoxState extends State<EditableFieldBox> {
  String? errorText;

  /// Built-in validator
  String? _defaultValidator(String? text) {
    if (text == null || text.trim().isEmpty) {
      return "This field cannot be empty";
    }

    switch (widget.fieldType) {
      case FieldType.integer:
        if (int.tryParse(text) == null) {
          return "Enter a valid integer";
        }
        break;

      case FieldType.decimal:
        if (double.tryParse(text) == null) {
          return "Enter a valid number";
        }
        break;

      case FieldType.string:
      default:
        if (text.trim().isEmpty) {
          return "Invalid text";
        }
    }

    return null; // valid
  }

  void validate() {
    final validator = widget.validator ?? _defaultValidator;

    setState(() {
      errorText = validator(widget.controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: errorText == null ? const Color(0xff00B4F0) : Colors.red,
              width: 2,
            ),
          ),
          padding: const EdgeInsets.only(left: 14, right: 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  maxLines: widget.maxLines,
                  decoration: InputDecoration(
                    hintText: widget.value,
                    border: InputBorder.none,
                  ),
                  onChanged: (_) => validate(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Color(0xff00B4F0)),
                onPressed: () {
                  validate();
                  if (errorText == null && widget.onEdit != null) {
                    widget.onEdit!();
                  }
                },
              ),
            ],
          ),
        ),

        // Error message
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 6, top: 4),
            child: Text(
              errorText!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
