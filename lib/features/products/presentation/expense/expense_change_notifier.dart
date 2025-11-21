import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pos_ai_sales/core/firebase/firebase_expenses_service.dart';
// import 'package:pos_ai_sales/core/db/Expense/sqlite_service_riverpod.dart';
import 'package:pos_ai_sales/core/models/expense.dart';

class ExpenseListNotifier extends StateNotifier<AsyncValue<List<Expense>>> {
  final Ref ref;

  ExpenseListNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    state = const AsyncValue.loading();
    try {
      List<Expense> firebaseList = [];
      // List<Expense> localList = [];

      final firebaseService = ref.read(firebaseExpensesServiceProvider);
      firebaseList = await firebaseService.getExpenses();
      state = AsyncValue.data(firebaseList);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Add new Expense and update state immediately
  void addExpense(Expense newExpense) {
    final currentList = state.value ?? [];
    state = AsyncValue.data([newExpense, ...currentList]);
  }

  // Update existing Expense
  void updateExpense(Expense updatedExpense) {
    final currentList = state.value ?? [];
    final newList = currentList.map((Expense) {
      return Expense.expenseId == updatedExpense.expenseId
          ? updatedExpense
          : Expense;
    }).toList();

    state = AsyncValue.data(newList);
  }

  // Remove Expense
  void removeExpense(String expenseId) {
    final currentList = state.value ?? [];
    final newList = currentList
        .where((Expense) => Expense.expenseId.toString() != expenseId)
        .toList();

    state = AsyncValue.data(newList);
  }

  // Mark Expense as deleted (soft delete)
  void deleteExpense(String expenseId) {
    final currentList = state.value ?? [];
    final newList = currentList.map((expense) {
      if (expense.expenseId.toString() == expenseId) {
        return expense.copyWith(deleted: 1);
      }
      return expense;
    }).toList();

    state = AsyncValue.data(newList);
  }

  // Refresh the list from sources
  Future<void> refresh() async {
    await _loadExpenses();
  }

  // Search Expenses
  void searchExpenses(String query) {
    if (query.isEmpty) {
      // If search is empty, reload original list
      _loadExpenses();
      return;
    }

    final currentList = state.value ?? [];
    final filteredList = currentList.where((expense) {
      return expense.name
          .toString()
          .toLowerCase()
          .contains(query.toLowerCase()); //  ||
      // Expense.phone?.toLowerCase().contains(query.toLowerCase()) == true ||
      // Expense.email?.toLowerCase().contains(query.toLowerCase()) == true;
    }).toList();

    state = AsyncValue.data(filteredList);
  }
}

final expenseListNotifierProvider = StateNotifierProvider.autoDispose<
    ExpenseListNotifier,
    AsyncValue<List<Expense>>>((ref) => ExpenseListNotifier(ref));
