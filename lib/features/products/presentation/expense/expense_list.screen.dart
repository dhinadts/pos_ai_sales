import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_ai_sales/core/db/expence/expence_service_riverpod.dart';
import 'package:pos_ai_sales/features/products/presentation/Widgets/card_details.dart';
import 'package:uuid/uuid_value.dart';

class ExpensesList extends ConsumerWidget {
  const ExpensesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseAsync = ref.watch(ExpenseListProvider);
    final isWeb = MediaQuery.of(context).size.width > 600;

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
          title: const Text(
            'All Expenses',
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
                      hintText: "Search expenses...",
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
                        if (isWeb) {
                          return GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 1.3,
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
                          itemCount: expenses.length,
                          itemBuilder: (context, index) {
                            final expense = expenses[index];
                            return CardItem(
                              pageTitle: 'expense',
                              id: UuidValue(expense.expenseId.toString()),
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
        ),

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
