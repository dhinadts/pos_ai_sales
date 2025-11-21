import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_ai_sales/core/db/customer/sqlite_service_riverpod.dart';
import 'package:pos_ai_sales/core/utilits/responsive_design.dart';
import 'package:pos_ai_sales/features/products/presentation/Widgets/card_details.dart';
import 'package:pos_ai_sales/features/products/presentation/customers/customer_change_notifier.dart';
import 'package:uuid/uuid.dart';

class CustomersList extends ConsumerWidget {
  const CustomersList({super.key});
  Future<void> _deleteCustomer(WidgetRef ref, BuildContext context,
      UuidValue customerId, String customerName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text('Are you sure you want to delete $customerName?'),
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

    if (confirmed == true) {
      try {
        // Delete from Firebase
        final firebaseService = ref.read(firebaseCustomersServiceProvider);
        await firebaseService.deleteCustomer(customerId.toString());

        // Refresh the list
        ref.invalidate(customerListNotifierProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Customer deleted successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete customer: $e')),
          );
        }
        // Refresh if deletion failed
        ref.invalidate(customerListNotifierProvider);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = ref.watch(responsiveProvider);
    // final customersAsync = ref.watch(customerListProvider);
    final customersAsync = ref.watch(customerListNotifierProvider);

    return WillPopScope(
      onWillPop: () async {
        context.go('/home');
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xffF7F9FB),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xff00B4F0),
          title: Text(
            'All Customers',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: responsive.text(20),
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: responsive.height(24),
            ),
            onPressed: () => context.go('/home'),
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            // Update responsive values
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(responsiveProvider.notifier).updateFromContext(context);
            });

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: responsive.isDesktop ? 1400 : 800,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.width(16),
                    vertical: responsive.height(16),
                  ),
                  child: Column(
                    children: [
                      // ---------------- SEARCH BAR ----------------
                      Container(
                        height: responsive.height(50),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Search customers...",
                            hintStyle: TextStyle(fontSize: responsive.text(16)),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.blue,
                              size: responsive.height(24),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: responsive.width(16),
                              vertical: responsive.height(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.blue,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.blue,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: responsive.height(20)),

                      // ---------------- CUSTOMER LIST ----------------
                      Expanded(
                        child: customersAsync.when(
                          data: (customers) {
                            if (customers.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.people_outline,
                                      size: responsive.height(64),
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: responsive.height(16)),
                                    Text(
                                      'No customers found',
                                      style: TextStyle(
                                        fontSize: responsive.text(18),
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: responsive.height(8)),
                                    Text(
                                      'Add your first customer to get started',
                                      style: TextStyle(
                                        fontSize: responsive.text(14),
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            // Responsive grid/list based on screen size
                            if (responsive.isDesktop) {
                              // Desktop - Adaptive columns
                              final crossAxisCount = responsive
                                  .getCrossAxisCount(constraints.maxWidth);
                              return GridView.builder(
                                padding: EdgeInsets.only(
                                  top: responsive.height(10),
                                  bottom: responsive.height(
                                    80,
                                  ), // Space for FAB
                                ),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: responsive.width(3),
                                  mainAxisSpacing: responsive.height(3),
                                  childAspectRatio: responsive
                                      .getAspectRatio(constraints.maxWidth),
                                ),
                                itemCount: customers.length,
                                itemBuilder: (context, index) {
                                  final customer = customers[index];
                                  return CardItem(
                                    customer: customer,
                                    onEdit: () => context.go(
                                      '/customers/edit/${customer.customerId}?mode=edit',
                                    ),
                                    onDelete: () => _deleteCustomer(
                                        ref,
                                        context,
                                        customer.customerId,
                                        customer.name),
                                    responsive: responsive,
                                    pageTitle: 'customer',
                                    id: customer.customerId,
                                  );
                                },
                              );
                            } else if (responsive.isTablet) {
                              // Tablet - 2 columns or list based on orientation
                              final isLandscape =
                                  MediaQuery.of(context).orientation ==
                                      Orientation.landscape;
                              final crossAxisCount = isLandscape ? 3 : 2;

                              return GridView.builder(
                                padding: EdgeInsets.only(
                                  top: responsive.height(10),
                                  bottom: responsive.height(80),
                                ),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: responsive.width(12),
                                  mainAxisSpacing: responsive.height(12),
                                  childAspectRatio: isLandscape ? 1.4 : 1.2,
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
                                      onDelete: () => _deleteCustomer(
                                          ref,
                                          context,
                                          customer.customerId,
                                          customer.name));
                                },
                              );
                            } else {
                              // Mobile - List view
                              return ListView.builder(
                                padding: EdgeInsets.only(
                                  top: responsive.height(10),
                                  bottom: responsive.height(80),
                                ),
                                itemCount: customers.length,
                                itemBuilder: (context, index) {
                                  final customer = customers[index];
                                  return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: responsive.height(12),
                                      ),
                                      child: CardItem(
                                        pageTitle: 'customer',
                                        id: customer.customerId,
                                        customer: customer,
                                        onEdit: () => context.go(
                                          '/customers/edit/${customer.customerId}?mode=edit',
                                        ),
                                        onDelete: () => _deleteCustomer(
                                            ref,
                                            context,
                                            customer.customerId,
                                            customer.name),
                                        responsive: responsive,
                                      ));
                                },
                              );
                            }
                          },
                          loading: () => Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                const Color(0xff00B4F0),
                              ),
                            ),
                          ),
                          error: (err, stack) => Center(
                            child: Padding(
                              padding: EdgeInsets.all(responsive.width(16)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: responsive.height(48),
                                    color: Colors.red,
                                  ),
                                  SizedBox(height: responsive.height(16)),
                                  Text(
                                    'Error loading customers',
                                    style: TextStyle(
                                      fontSize: responsive.text(16),
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: responsive.height(8)),
                                  Text(
                                    'Please try again later',
                                    style: TextStyle(
                                      fontSize: responsive.text(14),
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        floatingActionButton: Container(
          margin: EdgeInsets.only(
            bottom: responsive.height(16),
            right: responsive.width(16),
          ),
          child: FloatingActionButton.extended(
            onPressed: () => context.go('/customers/edit/new?mode=add'),
            icon: Icon(Icons.add, size: responsive.height(24)),
            label: Text(
              'Add Customer',
              style: TextStyle(
                fontSize: responsive.text(16),
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: const Color(0xff00B4F0),
            foregroundColor: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}


/* import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_ai_sales/core/db/customer/sqlite_service_riverpod.dart';
import 'package:pos_ai_sales/core/utilits/responsive_design.dart';
import 'package:pos_ai_sales/features/products/presentation/Widgets/card_details.dart';

class CustomersList extends ConsumerWidget {
  const CustomersList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = ref.watch(responsiveProvider);
    final customersAsync = ref.watch(customerListProvider);

    final isWeb = responsive.isDesktop || responsive.isTablet;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Update responsive values on every layout build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(responsiveProvider.notifier).updateFromContext(context);
        });
        // ref.read(responsiveProvider.notifier).updateFromContext(context);

        return WillPopScope(
          onWillPop: () async {
            context.go('/home');
            return false;
          },
          child: Scaffold(
            backgroundColor: const Color(0xffF7F9FB),

            appBar: AppBar(
              elevation: 0,
              backgroundColor: const Color(0xff00B4F0),
              title: Text(
                'All Customers',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: responsive.text(20),
                ),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => context.go('/home'),
              ),
            ),

            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Padding(
                  padding: EdgeInsets.all(responsive.width(16)),
                  child: Column(
                    children: [
                      // ---------------- SEARCH BAR ----------------
                      TextField(
                        decoration: InputDecoration(
                          hintText: "Search customers...",
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.blue,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: responsive.height(14),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.blue),
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

                      SizedBox(height: responsive.height(20)),

                      // ---------------- CUSTOMER LIST ----------------
                      Expanded(
                        child: customersAsync.when(
                          data: (customers) {
                            if (customers.isEmpty) {
                              return Center(
                                child: Text(
                                  'No customers found.',
                                  style: TextStyle(
                                    fontSize: responsive.text(18),
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            }

                            // -------- WEB VIEW (GRID) --------
                            if (isWeb) {
                              return GridView.builder(
                                padding: EdgeInsets.only(
                                  top: responsive.height(10),
                                ),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          constraints.maxWidth > 1300 ? 4 : 3,
                                      crossAxisSpacing: responsive.width(16),
                                      mainAxisSpacing: responsive.height(20),
                                      childAspectRatio: 1.25,
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
                                    onDelete: () => _deleteCustomer(
                                      ref, 
                                      context, 
                                      customer.customerId, 
                                      customer.name
                                    ),
                                    responsive: responsive,
                                    pageTitle: 'customer',
                                    id: customer.customerId,
                                  );
                                }, context.go(
                                      '/customers/edit/${customer.customerId}?mode=delete',
                                    ),
                                  );
                                },
                              );
                            }

                            // -------- MOBILE VIEW (LIST) --------
                            return ListView.builder(
                              padding: EdgeInsets.only(
                                top: responsive.height(10),
                              ),
                              itemCount: customers.length,
                              itemBuilder: (context, index) {
                                final customer = customers[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: CardItem(
                                    pageTitle: 'customer',
                                    id: customer.customerId,
                                    customer: customer,
                                    onEdit: () => context.go(
                                      '/customers/edit/${customer.customerId}?mode=edit',
                                    ),
                                    onDelete: () => _deleteCustomer(
                                      ref, 
                                      context, 
                                      customer.customerId, 
                                      customer.name
                                    ),
                                    responsive: responsive,
                                    pageTitle: 'customer',
                                    id: customer.customerId,
                                  );
                                }, context.go(
                                      '/customers/edit/${customer.customerId}?mode=delete',
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (err, stack) => Center(
                            child: Text('Error loading customers: $err'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => context.go('/customers/edit/new?mode=add'),
              icon: const Icon(Icons.add),
              label: const Text('Add Customer'),
              backgroundColor: const Color(0xff00B4F0),
            ),
          ),
        );
      },
    );
  }
}
 */


/* import 'package:flutter/material.dart';
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
                                onDelete: () => _deleteCustomer(
                                      ref, 
                                      context, 
                                      customer.customerId, 
                                      customer.name
                                    ),
                                    responsive: responsive,
                                    pageTitle: 'customer',
                                    id: customer.customerId,
                                  );
                                }, context.go(
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
                                onDelete: () => _deleteCustomer(
                                      ref, 
                                      context, 
                                      customer.customerId, 
                                      customer.name
                                    ),
                                    responsive: responsive,
                                    pageTitle: 'customer',
                                    id: customer.customerId,
                                  );
                                }, context.go(
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
 */

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
                          onDelete: () => _deleteCustomer(
                                      ref, 
                                      context, 
                                      customer.customerId, 
                                      customer.name
                                    ),
                                    responsive: responsive,
                                    pageTitle: 'customer',
                                    id: customer.customerId,
                                  );
                                }, context.go(
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