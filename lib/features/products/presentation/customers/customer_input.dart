import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_ai_sales/core/db/customer/sqlite_service_riverpod.dart';
import 'package:pos_ai_sales/core/firebase/firebase_customers_service.dart'
    hide firebaseCustomersServiceProvider;
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
      // Show loading
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
        // Delete from Firebase
        await ref
            .read(firebaseCustomersServiceProvider)
            .deleteCustomer(customer.customerId.toString());
      } else {
        // Delete from SQLite (soft delete)
        await ref
            .read(customerRepoProvider)
            .softDelete(customer.customerId.toString());

        // Also delete from Firebase for sync
        try {
          await ref
              .read(firebaseCustomersServiceProvider)
              .deleteCustomer(customer.customerId.toString());
        } catch (e) {
          print('Firebase delete failed: $e');
          // Continue with local delete
        }
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${customer.name} deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh the customer list
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

    // Handle new customer case
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

/*   Future<void> _loadCustomer() async {
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
        debugPrint('Error loading customer: $e');
      }
    } else {
      /* final c = await ref
          .read(customerRepoProvider)
          .byId(widget.customerId.toString());
      debugPrint('=== DEBUG: _loadCustomer() started ===');
      debugPrint('📱 Platform: ${kIsWeb ? 'Web' : 'Mobile'}');
      debugPrint('🔑 Customer ID: "${widget.customerId}"');
      debugPrint('🔑 Customer ID type: ${widget.customerId.runtimeType}');
      if (c != null) {
        nameCtrl.text = c.name;
        phoneCtrl.text = c.phone ?? '';
        emailCtrl.text = c.email ?? '';
        addressCtrl.text = c.address ?? '';
      }
    } */
      try {
        // Debug: Check if customerRepoProvider is working
        final repo = ref.read(customerRepoProvider);
        debugPrint('✅ CustomerRepo provider accessed');

        // Debug: Check all customers first
        debugPrint('📋 Checking all customers in database...');
        final allCustomers = await repo.all();
        debugPrint('📊 Total customers in database: ${allCustomers.length}');

        for (int i = 0; i < allCustomers.length; i++) {
          final customer = allCustomers[i];
          debugPrint(
            '  $i. ID: "${customer.customerId}" -> Name: "${customer.name}"',
          );
          debugPrint('     Type: ${customer.customerId.runtimeType}');
        }

        // Now try to get the specific customer
        debugPrint(
          '🔍 Searching for specific customer ID: "${widget.customerId}"',
        );
        final c = await repo.byId(widget.customerId.toString());

        debugPrint('🎯 Query result: $c');

        if (c != null) {
          debugPrint('✅ Customer found: ${c.name}');
          debugPrint('📝 Customer details:');
          debugPrint('   - Phone: ${c.phone}');
          debugPrint('   - Email: ${c.email}');
          debugPrint('   - Address: ${c.address}');

          setState(() {
            nameCtrl.text = c.name;
            phoneCtrl.text = c.phone ?? '';
            emailCtrl.text = c.email ?? '';
            addressCtrl.text = c.address ?? '';
          });
          debugPrint('✅ Text controllers updated');
        } else {
          debugPrint('❌ Customer not found in database');
          debugPrint('💡 Possible issues:');
          debugPrint('   1. Customer ID mismatch');
          debugPrint('   2. Customer is soft deleted (deleted = 1)');
          debugPrint('   3. Database corruption');
          debugPrint('   4. Customer was never saved to SQLite');
        }
      } catch (e) {
        debugPrint('❌ ERROR in _loadCustomer: $e');
        debugPrint('Stack trace: ${e.toString()}');
      }
    }

    debugPrint('=== DEBUG: _loadCustomer() completed ===');
  }
 */
  Future<void> _save() async {
    final firebase = ref.read(firebaseCustomersServiceProvider);

    // Validate required fields
    if (nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer name is required')),
      );
      return;
    }

    // Generate ID only for new customer
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

      // Use Firebase for both web and mobile
      if (widget.mode == "edit") {
        await firebase.updateCustomer(customer);
        debugPrint('✅ Customer updated in Firebase');
      } else {
        await firebase.addCustomer(customer);
        debugPrint('✅ Customer added to Firebase');
      }

      // Refresh Customer List UI
      ref.invalidate(customerListProvider);

      // Show success message
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

      // Navigate back
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

/*   Future<void> _save() async {
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
 */
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
    if (widget.mode == 'delete') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleDeleteMode();
      });
    }
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
          backgroundColor: Colors.cyan,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
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
