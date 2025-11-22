// lib/screens/product_details_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pos_ai_sales/core/db/products/sqlite_service_riverpod.dart';
import 'package:pos_ai_sales/core/firebase/firebase_product_service.dart';
import 'package:pos_ai_sales/core/models/product.dart';
import 'package:pos_ai_sales/features/products/presentation/products/product_change_notifier.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';

class ProductEditScreen extends ConsumerStatefulWidget {
  final UuidValue? productId;
  final String? mode;
  final Product? product;

  const ProductEditScreen({
    super.key,
    this.product,
    required this.productId,
    required this.mode,
  });

  @override
  ConsumerState<ProductEditScreen> createState() => _ProductEditScreen();
}

class _ProductEditScreen extends ConsumerState<ProductEditScreen> {
  final _formKey = GlobalKey<FormState>();

  // controllers
  final TextEditingController _nameCtl = TextEditingController();
  final TextEditingController _codeCtl = TextEditingController();
  final TextEditingController _categoryCtl = TextEditingController();
  final TextEditingController _descCtl = TextEditingController();
  final TextEditingController _buyPriceCtl = TextEditingController();
  final TextEditingController _sellPriceCtl = TextEditingController();
  final TextEditingController _stockCtl = TextEditingController();
  final TextEditingController _weightCtl = TextEditingController();
  String _weightUnit = 'Pics';
  String _supplier = 'n/a';
  File? _pickedImage;

  final List<String> _units = ['Pics', 'Kg', 'g', 'L', 'ml'];
  final List<String> _suppliers = ['n/a', 'Supplier A', 'Supplier B'];
  Product? loadedProduct;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      if (widget.mode == "edit") {
        final p = await ref
            .read(firebaseProductsServiceProvider)
            .getProductById(widget.productId.toString());
        if (p != null) {
          setState(() {
            loadedProduct = p;

            _nameCtl.text = p.name;
            _codeCtl.text = p.code;
            _categoryCtl.text = p.category;
            _descCtl.text = p.description;
            _buyPriceCtl.text = p.buyPrice.toString();
            _sellPriceCtl.text = p.sellPrice.toString();
            _stockCtl.text = p.stock.toString();
            _weightCtl.text = p.weight.toString();
            _weightUnit = p.weightUnit;
            _supplier = p.supplier;
            if (p.imagePath != null && p.imagePath!.isNotEmpty) {
              _pickedImage = File(p.imagePath!);
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _codeCtl.dispose();
    _categoryCtl.dispose();
    _descCtl.dispose();
    _buyPriceCtl.dispose();
    _sellPriceCtl.dispose();
    _stockCtl.dispose();
    _weightCtl.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String label) {
    const borderRadius = 12.0;
    const turquoise = Color(0xFF00BFEA); // adjust slightly
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[700]),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: turquoise, width: 3),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: turquoise, width: 3),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? xfile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (xfile != null) {
      setState(() {
        _pickedImage = File(xfile.path);
      });
    }
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final product = Product(
        productId: widget.productId ??
            const Uuid().v4obj(), // FIX: Use v4obj() for UuidValue
        name: _nameCtl.text.trim(),
        code: _codeCtl.text.trim(),
        category: _categoryCtl.text.trim(),
        description: _descCtl.text.trim(),
        buyPrice: double.tryParse(_buyPriceCtl.text.trim()) ?? 0.0,
        sellPrice: double.tryParse(_sellPriceCtl.text.trim()) ?? 0.0,
        stock: int.tryParse(_stockCtl.text.trim()) ?? 0,
        weight: double.tryParse(_weightCtl.text.trim()) ?? 0.0,
        weightUnit: _weightUnit,
        supplier: _supplier,
        imagePath: _pickedImage?.path, // FIX: Don't use empty string if null
        lastModified: DateTime.now(),
      );

      if (widget.mode == "edit") {
        await ref.read(firebaseProductsServiceProvider).updateProduct(product);
      } else {
        await ref.read(firebaseProductsServiceProvider).addProduct(product);
      }

      // Refresh the product list
      ref.invalidate(productsListNotifierProvider);

      // Navigate back
      if (context.mounted) {
        context.go('/products');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving product: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final turquoise = Color(0xFF00BFEA);
    return WillPopScope(
      onWillPop: () async {
        context.go('/products');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.cyan,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => context.go('/products'),
          ),
          title: const Text(
            'Product Details',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Product name
                  TextFormField(
                    controller: _nameCtl,
                    decoration: _fieldDecoration('Product Name'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Enter name' : null,
                  ),
                  const SizedBox(height: 16),
                  // Code + barcode placeholder (we'll show only textfield)
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _codeCtl,
                          decoration: _fieldDecoration('Product Code'),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Enter code'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // barcode icon button placeholder
                      Container(
                        height: 56,
                        width: 56,
                        decoration: BoxDecoration(
                          border: Border.all(color: turquoise, width: 3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.qr_code,
                            color: Colors.black54,
                          ),
                          onPressed: () {
                            // TODO: implement barcode scan
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _categoryCtl,
                    decoration: _fieldDecoration('Product Category'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descCtl,
                    minLines: 4,
                    maxLines: 6,
                    decoration: _fieldDecoration('Product Description'),
                  ),
                  const SizedBox(height: 16),
                  // Prices and stock
                  TextFormField(
                    controller: _buyPriceCtl,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: _fieldDecoration('Unit Product Buy Price'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _sellPriceCtl,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: _fieldDecoration('Unit Product Sell Price'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _stockCtl,
                    keyboardType: TextInputType.number,
                    decoration: _fieldDecoration('Product Stock'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _weightCtl,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: _fieldDecoration('Product Weight'),
                  ),
                  const SizedBox(height: 12),
                  // Weight unit dropdown
                  DropdownButtonFormField<String>(
                    value: _weightUnit,
                    items: _units
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _weightUnit = v ?? _weightUnit),
                    decoration: _fieldDecoration('Select Product Weight Unit'),
                  ),
                  const SizedBox(height: 12),
                  // Supplier
                  DropdownButtonFormField<String>(
                    value: _supplier,
                    items: _suppliers
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _supplier = v ?? _supplier),
                    decoration: _fieldDecoration('Select Supplier'),
                  ),
                  const SizedBox(height: 20),
                  // Choose product image button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _pickImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: turquoise,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Choose Product Image',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Image preview placeholder
                  Container(
                    width: double.infinity,
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: _pickedImage != null
                        ? Image.file(_pickedImage!, fit: BoxFit.contain)
                        : Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.folder_open,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'No image chosen',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 22),
                  // Bottom Edit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: turquoise,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        widget.mode == 'add' ? 'Add' : 'Update',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
