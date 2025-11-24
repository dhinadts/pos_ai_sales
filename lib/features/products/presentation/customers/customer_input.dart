import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_ai_sales/core/db/customer/sqlite_service_riverpod.dart';
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadCustomer();
      });
    }
    if (widget.mode == 'delete') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleDeleteMode();
      });
    }
  }

  void _handleDeleteMode() async {
    final customer =
        await ref.read(customerRepoProvider).byId(widget.customerId.toString());
    if (customer != null && mounted) {
      _onDeleteCustomer(customer);
    }
  }

  void _onDeleteCustomer(Customer customer) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text(
          'Are you sure you want to delete ${customer.name}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      await _performDelete(customer);
    }
  }

  Future<void> _performDelete(Customer customer) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const CircularProgressIndicator.adaptive(),
              const SizedBox(width: 16),
              Text('Deleting ${customer.name}...'),
            ],
          ),
          duration: const Duration(seconds: 5),
        ),
      );

      if (kIsWeb) {
        await ref
            .read(firebaseCustomersServiceProvider)
            .deleteCustomer(customer.customerId.toString());
      } else {
        await ref
            .read(customerRepoProvider)
            .softDelete(customer.customerId.toString());

        try {
          await ref
              .read(firebaseCustomersServiceProvider)
              .deleteCustomer(customer.customerId.toString());
        } catch (e) {
          print('Firebase delete failed: $e');
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${customer.name} deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        ref.invalidate(customerListProvider);

        context.go('/customers');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete customer: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadCustomer() async {
    debugPrint('=== DEBUG: _loadCustomer() started ===');
    debugPrint('📱 Platform: ${kIsWeb ? 'Web' : 'Mobile'}');
    debugPrint('🔑 Customer ID: "${widget.customerId}"');
    debugPrint('🔑 Mode: "${widget.mode}"');

    if (widget.customerId == 'new' || widget.mode == 'add') {
      debugPrint('🆕 Creating new customer - clearing form');
      if (mounted) {
        setState(() {
          nameCtrl.clear();
          phoneCtrl.clear();
          emailCtrl.clear();
          addressCtrl.clear();
        });
      }
      debugPrint('=== DEBUG: _loadCustomer() completed (new customer) ===');
      return;
    }

    try {
      debugPrint('🌐 Loading from Firebase...');
      final customer = await ref
          .read(firebaseCustomersServiceProvider)
          .byId(widget.customerId.toString());

      if (customer != null && mounted) {
        debugPrint('✅ Firebase customer loaded: ${customer.name}');
        debugPrint('📝 Customer details:');
        debugPrint('   - Phone: ${customer.phone}');
        debugPrint('   - Email: ${customer.email}');
        debugPrint('   - Address: ${customer.address}');

        setState(() {
          nameCtrl.text = customer.name;
          phoneCtrl.text = customer.phone ?? '';
          emailCtrl.text = customer.email ?? '';
          addressCtrl.text = customer.address ?? '';
        });
        debugPrint('✅ Text controllers updated');
      } else {
        debugPrint('❌ Customer not found in Firebase');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Customer not found')),
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

    debugPrint('=== DEBUG: _loadCustomer() completed ===');
  }

  Future<void> _save() async {
    final firebase = ref.read(firebaseCustomersServiceProvider);

    if (nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer name is required')),
      );
      return;
    }

    final id = (widget.mode == "edit") ? widget.customerId : Uuid().v4();

    final customer = Customer(
      customerId: UuidValue(id.toString()),
      name: nameCtrl.text.trim(),
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
        await firebase.updateCustomer(customer);
        debugPrint('✅ Customer updated in Firebase');
      } else {
        await firebase.addCustomer(customer);
        debugPrint('✅ Customer added to Firebase');
      }

      ref.invalidate(customerListProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.mode == "edit"
                ? 'Customer updated successfully'
                : 'Customer added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      if (mounted) {
        context.go('/customers');
      }
    } catch (e) {
      debugPrint('❌ ERROR saving customer: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save customer: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mode == 'delete') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleDeleteMode();
      });
    }
    return WillPopScope(
      onWillPop: () async {
        context.go('/customers');
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.cyan,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => context.go('/customers'),
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
