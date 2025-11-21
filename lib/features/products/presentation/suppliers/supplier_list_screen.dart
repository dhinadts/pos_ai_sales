import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_ai_sales/features/products/presentation/Widgets/card_details.dart';
import 'package:pos_ai_sales/features/products/presentation/suppliers/supplier_change_notifier.dart';

class SuppliersListScreen extends ConsumerWidget {
  const SuppliersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final suppliersAsync = ref.watch(supplierListProvider);
    final isWeb = MediaQuery.of(context).size.width > 600;
    // final responsive = ref.watch(responsiveProvider);
    // final customersAsync = ref.watch(customerListProvider);
    final suppliersAsync = ref.watch(supplierListNotifierProvider);
    return WillPopScope(
      onWillPop: () async {
        context.go('/home'); // go to home
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("All Suppliers"),
          backgroundColor: const Color(0xff00B4F0),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => context.go('/home'),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: const Color(0xff00B4F0),
          label: const Text('Add Supplier'),
          icon: const Icon(Icons.add),
          onPressed: () {
            context.go('/suppliers/edit/new?mode=add');
          },
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
                      hintText: "Search suppliers...",
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
                    child: suppliersAsync.when(
                      data: (suppliers) {
                        if (suppliers.isEmpty) {
                          return const Center(
                            child: Text(
                              'No suppliers found.',
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
                            itemCount: suppliers.length,
                            itemBuilder: (context, index) {
                              final supplier = suppliers[index];
                              return CardItem(
                                pageTitle: 'supplier',
                                id: supplier.supplierId,
                                supplier: supplier,
                                onEdit: () => context.go(
                                  '/suppliers/edit/${supplier.supplierId}?mode=edit',
                                ),
                                onDelete: () => context.go(
                                  '/suppliers/edit/${supplier.supplierId}?mode=delete',
                                ),
                              );
                            },
                          );
                        } else {
                          return ListView.builder(
                            itemCount: suppliers.length,
                            itemBuilder: (context, index) {
                              final supplier = suppliers[index];
                              return CardItem(
                                pageTitle: 'supplier',
                                id: supplier.supplierId,
                                supplier: supplier,
                                onEdit: () => context.go(
                                  '/suppliers/edit/${supplier.supplierId}?mode=edit',
                                ),
                                onDelete: () => context.go(
                                  '/suppliers/edit/${supplier.supplierId}?mode=delete',
                                ),
                              );
                            },
                          );
                        }
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) =>
                          Center(child: Text('Error loading suppliers: $err')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
