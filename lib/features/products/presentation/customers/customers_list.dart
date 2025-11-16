import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_ai_sales/core/db/customer/sqlite_service_riverpod.dart';
import 'package:pos_ai_sales/features/products/presentation/Widgets/card_details.dart';

class CustomersList extends ConsumerWidget {
  const CustomersList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customerListProvider);
    final isWeb = MediaQuery.of(context).size.width > 600;

    return WillPopScope(
      onWillPop: () async {
        context.go('/home'); // go to home
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xffF7F9FB),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xff00B4F0),
          title: const Text(
            'All Customers',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => context.go('/home'),
          ),
        ),

        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 🔍 Search Bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Search customers...",
                      prefixIcon: const Icon(Icons.search, color: Colors.blue),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 1.2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 🧾 Customer List
                  Expanded(
                    child: customersAsync.when(
                      data: (customers) {
                        if (customers.isEmpty) {
                          return const Center(
                            child: Text(
                              'No customers found.',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }

                        // 💡 Grid on web, List on mobile
                        if (isWeb) {
                          return GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 1.3,
                                ),
                            itemCount: customers.length,
                            itemBuilder: (context, index) {
                              final customer = customers[index];
                              return CardItem(
                                pageTitle: 'customer',
                                id: customer.customerId,
                                customer: customer,
                                onEdit: () => context.go(
                                  '/customers/edit/${customer.customerId}?mode=edit',
                                ),
                                onDelete: () => context.go(
                                  '/customers/edit/${customer.customerId}?mode=delete',
                                ),
                              );
                            },
                          );
                        } else {
                          return ListView.builder(
                            itemCount: customers.length,
                            itemBuilder: (context, index) {
                              final customer = customers[index];
                              return CardItem(
                                pageTitle: 'customer',
                                id: customer.customerId,
                                customer: customer,
                                onEdit: () => context.go(
                                  '/customers/edit/${customer.customerId}?mode=edit',
                                ),
                                onDelete: () => context.go(
                                  '/customers/edit/${customer.customerId}?mode=delete',
                                ),
                              );
                            },
                          );
                        }
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) =>
                          Center(child: Text('Error loading customers: $err')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ➕ Add button styled for web
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.go('/customers/edit/new?mode=add'),
          icon: const Icon(Icons.add),
          label: const Text('Add Customer'),
          backgroundColor: const Color(0xff00B4F0),
        ),
      ),
    );
  }
}


/* import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_ai_sales/core/db/customer/sqlite_service_riverpod.dart';
import 'package:pos_ai_sales/core/models/customer.dart';
import 'package:pos_ai_sales/features/products/presentation/Widgets/card_details.dart';
import 'package:uuid/uuid.dart';

class CustomersList extends ConsumerWidget {
  const CustomersList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customerListProvider);
    return WillPopScope(
      onWillPop: () async {
        context.go('/home'); // go to home
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xff00B4F0),

          title: const Text('All Customers'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => context.go('/home'),
          ),
        ),

        body: Container(
          color: Colors.white,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(12),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search here...",
                    suffixIcon: Icon(Icons.search, color: Colors.blue),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 1),
                      borderRadius: BorderRadius.zero,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 1),
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: customersAsync.when(
                  data: (customers) {
                    if (customers.isEmpty) {
                      return Center(child: Text('No customers found.'));
                    }
                    return ListView.builder(
                      itemCount: customers.length,
                      itemBuilder: (context, index) {
                        Customer customer = customers[index];
                        return CardItem(
                          pageTitle: 'customer',
                          id: customer.customerId,
                          customer: customer,
                          onEdit: () => context.go(
                            '/customers/edit/${customer.customerId}?mode=edit',
                          ),
                          onDelete: () => context.go(
                            '/customers/edit/${customer.customerId}?mode=delete',
                          ),
                        );
                      },
                    );
                  },
                  loading: () => Center(child: CircularProgressIndicator()),
                  error: (err, stack) =>
                      Center(child: Text('Error loading customers: $err')),
                ),
              ),
            ],
          ),
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () => context.go('/customers/edit/14?mode=add'), // ✅ fixed
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
 */