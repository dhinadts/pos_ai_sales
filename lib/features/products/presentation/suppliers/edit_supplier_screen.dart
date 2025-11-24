import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_ai_sales/core/db/suppliers/sqflite_riverpod_suppliers.dart';
import 'package:pos_ai_sales/core/models/supplier.dart';
import 'package:pos_ai_sales/features/products/presentation/Widgets/text_box.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_value.dart';
import 'package:go_router/go_router.dart';

class AddSupplierScreen extends ConsumerStatefulWidget {
  final UuidValue supplierId;
  final String mode;
  const AddSupplierScreen({
    super.key,
    required this.supplierId,
    required this.mode,
  });

  @override
  ConsumerState<AddSupplierScreen> createState() => _AddSupplierScreenState();
}

class _AddSupplierScreenState extends ConsumerState<AddSupplierScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameCtrl = TextEditingController();
  late TextEditingController personCtrl = TextEditingController();
  late TextEditingController phoneCtrl = TextEditingController();
  late TextEditingController emailCtrl = TextEditingController();
  late TextEditingController addressCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController();
    personCtrl = TextEditingController();
    phoneCtrl = TextEditingController();
    emailCtrl = TextEditingController();
    addressCtrl = TextEditingController();

    if (widget.mode == "edit") {
      _loadSupplier();
    }
  }

  Future<void> _loadSupplier() async {
    debugPrint('=== DEBUG: _loadSupplier() started ===');
    debugPrint('📱 Platform: ${kIsWeb ? 'Web' : 'Mobile'}');
    debugPrint('🔑 Supplier ID: "${widget.supplierId}"');
    debugPrint('🔑 Mode: "${widget.mode}"');

    if (widget.supplierId == 'new' || widget.mode == 'add') {
      debugPrint('🆕 Creating new customer - clearing form');
      if (mounted) {
        setState(() {
          nameCtrl.clear();
          personCtrl.clear();
          phoneCtrl.clear();
          emailCtrl.clear();
          addressCtrl.clear();
        });
      }
      debugPrint('=== DEBUG: _loadSupplier() completed (new customer) ===');
      return;
    }

    try {
      debugPrint('🌐 Loading from Firebase...');
      final customer = await ref
          .read(firebaseSuppliersServiceProvider)
          .byId(widget.supplierId.toString());

      if (customer != null && mounted) {
        debugPrint('✅ Firebase customer loaded: ${customer.name}');
        debugPrint('📝 Supplier details:');
        debugPrint('   - Phone: ${customer.phone}');
        debugPrint('   - Email: ${customer.email}');
        debugPrint('   - Address: ${customer.address}');

        setState(() {
          nameCtrl.text = customer.name;
          personCtrl.text = customer.contactName ?? '';
          phoneCtrl.text = customer.phone ?? '';
          emailCtrl.text = customer.email ?? '';
          addressCtrl.text = customer.address ?? '';
        });
        debugPrint('✅ Text controllers updated');
      } else {
        debugPrint('❌ Supplier not found in Firebase');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Supplier not found')),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ ERROR loading customer from Firebase: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading customer: $e')),
        );
      }
    }

    debugPrint('=== DEBUG: _loadSupplier() completed ===');
  }

  Future<void> _save() async {
    final firebase = ref.read(firebaseSuppliersServiceProvider);

    if (nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Supplier name is required')),
      );
      return;
    }

    final id = (widget.mode == "edit") ? widget.supplierId : Uuid().v4();

    final customer = Supplier(
      supplierId: UuidValue(id.toString()),
      name: nameCtrl.text.trim(),
      contactName: personCtrl.text.trim(),
      phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
      email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
      address: addressCtrl.text.trim().isEmpty ? null : addressCtrl.text.trim(),
      imagePath: null,
      lastModified: DateTime.now(),
    );

    try {
      debugPrint('💾 Saving customer to Firebase...');
      debugPrint('   - Mode: ${widget.mode}');
      debugPrint('   - ID: $id');
      debugPrint('   - Name: ${customer.name}');

      if (widget.mode == "edit") {
        await firebase.updateSupplier(customer);
        debugPrint('✅ Supplier updated in Firebase');
      } else {
        await firebase.addSupplier(customer);
        debugPrint('✅ Supplier added to Firebase');
      }

      ref.invalidate(supplierListProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.mode == "edit"
                ? 'Supplier updated successfully'
                : 'Supplier added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      if (mounted) {
        context.go('/suppliers');
      }
    } catch (e) {
      debugPrint('❌ ERROR saving customer: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save Supplier: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.go('/suppliers');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.mode == "add" ? "Add Suppliers" : "Edit Suppliers",
          ),
          backgroundColor: const Color(0xff00B4F0),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => context.go('/suppliers'),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Supplier Name"),
              const SizedBox(height: 8),
              EditableFieldBox(value: "Supplier Name", controller: nameCtrl),
              const SizedBox(height: 16),
              const Text("Supplier Contact Person"),
              const SizedBox(height: 8),
              EditableFieldBox(
                value: "Supplier Contact Person",
                controller: personCtrl,
              ),
              const SizedBox(height: 16),
              const Text("Supplier Cell"),
              const SizedBox(height: 8),
              EditableFieldBox(value: "Supplier Cell", controller: phoneCtrl),
              const SizedBox(height: 16),
              const Text("Supplier Email"),
              const SizedBox(height: 8),
              EditableFieldBox(value: "Supplier Email", controller: emailCtrl),
              const SizedBox(height: 16),
              const Text("Supplier Address"),
              const SizedBox(height: 8),
              EditableFieldBox(
                value: "Supplier Address",
                controller: addressCtrl,
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff00B4F0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _save,
                  child: Text(
                    widget.mode == "add" ? "Add Supplier" : "Edit Supplier",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
