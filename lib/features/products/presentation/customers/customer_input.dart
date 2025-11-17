import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_ai_sales/core/db/customer/sqlite_service_riverpod.dart';
import 'package:pos_ai_sales/core/firebase/firebase_customers_service.dart' hide firebaseCustomersServiceProvider;
import 'package:pos_ai_sales/core/models/customer.dart';
import 'package:pos_ai_sales/features/products/presentation/Widgets/common_button.dart';
import 'package:pos_ai_sales/features/products/presentation/Widgets/text_box.dart';
import 'package:uuid/uuid.dart';

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
    if (kIsWeb) {
      try {
        final customer = await ref
            .read(firebaseCustomersServiceProvider)
            .byId(widget.customerId.toString());
        if (mounted) {
          setState(() {
            nameCtrl.text = customer.name;
            phoneCtrl.text = customer.phone ?? '';
            emailCtrl.text = customer.email ?? '';
            addressCtrl.text = customer.address ?? '';
          });
        }
      } catch (e) {
        print('Error loading customer: $e');
      }
    } else {
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
  }

  Future<void> _save() async {
    final repo = ref.read(customerRepoProvider);
    final firebase = ref.read(firebaseCustomersServiceProvider);

    // Generate ID only for new customer
    final id = (widget.mode == "edit") ? widget.customerId : Uuid().v4();

    final data = Customer(
      customerId: UuidValue(id.toString()), // Use plain String ID
      name: nameCtrl.text,
      phone: phoneCtrl.text,
      email: emailCtrl.text,
      address: addressCtrl.text,
      imagePath: null,
      lastModified: DateTime.now(),
    );

    if (kIsWeb) {
      // --------------------
      // WEB → Firebase only
      // --------------------
      if (widget.mode == "edit") {
        await firebase.updateCustomer(data);
      } else {
        await firebase.addCustomer(data);
      }
    } else {
      // --------------------
      // MOBILE → SQLite only
      // --------------------
      if (widget.mode == "edit") {
        await repo.update(data);
      } else {
        await repo.save(data);
      }
    }

    // Refresh Customer List UI
    ref.invalidate(customerListProvider);

    // Navigate back
    context.go('/customers');
  }

  /* Future<void> _save() async {
    final repo = ref.read(customerRepoProvider);

    // Generate NEW ID only for add mode
    final id = (widget.mode == "edit")
        ? widget.customerId
        : Uuid().v4();

    final customer = Customer(
      customerId: widget.customerId,
      name: nameCtrl.text,
      phone: phoneCtrl.text,
      email: emailCtrl.text,
      address: addressCtrl.text,
      imagePath: null,
      lastModified: DateTime.now(),
    );

    if (kIsWeb) {
      // -------------------------------
      // 🔵 FIREBASE (WEB)
      // -------------------------------
      final firebase = ref.read(firebaseCustomersServiceProvider);

      if (widget.mode == "add") {
        await firebase.addCustomer(customer);
      } else {
        await firebase.updateCustomer(customer);
      }

      // refresh firebase list
      ref.invalidate(customerListProviderFirebase);
    } else {
      // -------------------------------
      // 🟢 SQLITE (MOBILE)
      // -------------------------------
      final repo = ref.read(customerRepoProvider);

      if (widget.mode == "add") {
        await repo.save(customer);
      } else {
        await repo.update(customer);
      }

      // refresh sqlite list
      ref.invalidate(customerListProviderLocal);
    }

    // refresh combined list provider (optional but safe)
    ref.invalidate(customerListProvider);

    // navigate back
    if (mounted) {
      context.go('/customers');
    }
  }
 */
  /* Future<void> _save() async {
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

 */
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
