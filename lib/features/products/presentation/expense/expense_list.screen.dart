import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_ai_sales/core/utilits/responsive_design.dart';

import 'package:pos_ai_sales/features/products/presentation/Widgets/card_details.dart';
import 'package:pos_ai_sales/features/products/presentation/expense/expense_change_notifier.dart';
import 'package:uuid/uuid_value.dart';

class ExpensesList extends ConsumerWidget {
  const ExpensesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseAsync = ref.watch(expenseListNotifierProvider);
    // final isWeb = MediaQuery.of(context).size.width > 600;
    final responsive = ref.watch(responsiveProvider);

    return WillPopScope(
      onWillPop: () async {
        context.go('/home');
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xffF7F9FB),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.cyan,
          title: const Text(
            'All Expenses',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => context.go('/home'),
          ),
        ),
        body: LayoutBuilder(builder: (context, constraints) {
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
                          hintText: "Search expenses...",
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
                      child: expenseAsync.when(
                        data: (expenses) {
                          if (expenses.isEmpty) {
                            return const Center(
                              child: Text(
                                'No expenses found.',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          }

                          // 🌐 Grid for Web
                          if (responsive.isDesktop) {
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
                              itemCount: expenses.length,
                              itemBuilder: (context, index) {
                                final expense = expenses[index];
                                return CardItem(
                                  pageTitle: 'expense',
                                  id: expense.expenseId,
                                  expense: expense,
                                  onEdit: () => context.go(
                                    '/expenses/edit/${expense.expenseId}?mode=edit',
                                  ),
                                  onDelete: () => context.go(
                                    '/expenses/edit/${expense.expenseId}?mode=delete',
                                  ),
                                );
                              },
                            );
                          }

                          // 📱 List for Mobile
                          return ListView.builder(
                            padding: EdgeInsets.only(
                              top: responsive.height(10),
                              bottom: responsive.height(80),
                            ),
                            itemCount: expenses.length,
                            itemBuilder: (context, index) {
                              final expense = expenses[index];
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: responsive.height(12),
                                ),
                                child: CardItem(
                                  pageTitle: 'expense',
                                  id: UuidValue(expense.expenseId.toString()),
                                  expense: expense,
                                  responsive: responsive,
                                  onEdit: () => context.go(
                                    '/expenses/edit/${expense.expenseId}?mode=edit',
                                  ),
                                  onDelete: () => context.go(
                                    '/expenses/edit/${expense.expenseId}?mode=delete',
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (err, _) =>
                            Center(child: Text('Error loading expenses: $err')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.go('/expenses/edit/new?mode=add'),
          icon: const Icon(Icons.add),
          label: const Text('Add Expense'),
          backgroundColor: const Color(0xff00B4F0),
        ),
      ),
    );
  }
}
