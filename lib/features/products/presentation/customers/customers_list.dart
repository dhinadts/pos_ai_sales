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
        final firebaseService = ref.read(firebaseCustomersServiceProvider);
        await firebaseService.deleteCustomer(customerId.toString());

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
        ref.invalidate(customerListNotifierProvider);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = ref.watch(responsiveProvider);
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

                            if (responsive.isDesktop) {
                              final crossAxisCount = responsive
                                  .getCrossAxisCount(constraints.maxWidth);
                              return GridView.builder(
                                padding: EdgeInsets.only(
                                  top: responsive.height(10),
                                  bottom: responsive.height(
                                    80,
                                  ),
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
