import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_ai_sales/core/db/suppliers/sqflite_riverpod_suppliers.dart';
import 'package:pos_ai_sales/core/models/supplier.dart';
import 'package:pos_ai_sales/features/products/presentation/Widgets/text_box.dart';
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
      _loadCustomer();
    }
  }

  Future<void> _loadCustomer() async {
    final c = await ref
        .read(SupplierRepoProvider)
        .byId(widget.supplierId.toString());
    if (c != null) {
      nameCtrl.text = c.name;
      personCtrl.text = c.contactName ?? '';
      phoneCtrl.text = c.phone ?? '';
      emailCtrl.text = c.email ?? '';
      addressCtrl.text = c.address ?? '';
    }
  }

  Future<void> _save() async {
    final repo = ref.read(SupplierRepoProvider);

    final data = Supplier(
      supplierId: widget.supplierId,
      name: nameCtrl.text,
      contactName: personCtrl.text,
      phone: phoneCtrl.text,
      email: emailCtrl.text,
      address: addressCtrl.text,
      imagePath: null,
      lastModified: DateTime.now(),
    );

    if (widget.mode == "edit") {
      await repo.update(data);
    } else {
      await repo.save(data);
    }

    ref.invalidate(supplierListProvider); // refresh list screen
    context.go('/suppliers');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
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
            // FIX: go_router pop
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
