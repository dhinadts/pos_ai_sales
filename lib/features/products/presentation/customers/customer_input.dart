import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_ai_sales/core/db/customer/sqlite_service_riverpod.dart';
import 'package:pos_ai_sales/core/models/customer.dart';
import 'package:pos_ai_sales/features/products/presentation/Widgets/common_button.dart';
import 'package:pos_ai_sales/features/products/presentation/Widgets/text_box.dart';
import 'package:uuid/uuid_value.dart';

class EditCustomerScreen extends ConsumerStatefulWidget {
  final UuidValue customerId;
  final String mode;

  const EditCustomerScreen({
    super.key,
    required this.customerId,
    required this.mode,
  });
  @override
  ConsumerState<EditCustomerScreen> createState() => _EditCustomerScreen();
}

class _EditCustomerScreen extends ConsumerState<EditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController addressCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController();
    phoneCtrl = TextEditingController();
    emailCtrl = TextEditingController();
    addressCtrl = TextEditingController();

    if (widget.mode == "edit") {
      _loadCustomer();
    }
  }

  Future<void> _loadCustomer() async {
    final c = await ref
        .read(customerRepoProvider)
        .byId(widget.customerId.toString());
    if (c != null) {
      nameCtrl.text = c.name;
      phoneCtrl.text = c.phone ?? '';
      emailCtrl.text = c.email ?? '';
      addressCtrl.text = c.address ?? '';
    }
  }

  Future<void> _save() async {
    final repo = ref.read(customerRepoProvider);

    final data = Customer(
      customerId: widget.customerId,
      name: nameCtrl.text,
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

    ref.invalidate(customerListProvider); // refresh list screen
    context.go('/customers');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle the back button press
        // context.pop();
        context.go('/customers');
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xff00B4F0),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => context.go('/customers'),
            // FIX: go_router pop
          ),
          title: Text(
            widget.mode == "edit" ? "Edit Customer" : "Add Customer",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),

        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text("Customer Name"),
                const SizedBox(height: 6),
                EditableFieldBox(
                  value: "Walk in Customer",
                  controller: nameCtrl,
                ),

                const SizedBox(height: 18),
                const Text("Customer Cell"),
                const SizedBox(height: 6),
                EditableFieldBox(value: "N/A", controller: phoneCtrl),

                const SizedBox(height: 18),
                const Text("Customer Email"),
                const SizedBox(height: 6),
                EditableFieldBox(value: "N/A", controller: emailCtrl),

                const SizedBox(height: 18),
                const Text("Customer Address"),
                const SizedBox(height: 6),
                EditableFieldBox(
                  value: "N/A",
                  maxLines: 5,
                  controller: addressCtrl,
                ),

                const SizedBox(height: 40),

                CommonButton(
                  title: widget.mode == "edit" ? "Update" : "Save",
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
