import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pos_ai_sales/core/firebase/firebase_expenses_service.dart';
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

      final firebaseService = ref.read(firebaseExpensesServiceProvider);
      firebaseList = await firebaseService.getExpenses();
      state = AsyncValue.data(firebaseList);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void addExpense(Expense newExpense) {
    final currentList = state.value ?? [];
    state = AsyncValue.data([newExpense, ...currentList]);
  }

  void updateExpense(Expense updatedExpense) {
    final currentList = state.value ?? [];
    final newList = currentList.map((Expense) {
      return Expense.expenseId == updatedExpense.expenseId
          ? updatedExpense
          : Expense;
    }).toList();

    state = AsyncValue.data(newList);
  }

  void removeExpense(String expenseId) {
    final currentList = state.value ?? [];
    final newList = currentList
        .where((Expense) => Expense.expenseId.toString() != expenseId)
        .toList();

    state = AsyncValue.data(newList);
  }

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

  Future<void> refresh() async {
    await _loadExpenses();
  }

  void searchExpenses(String query) {
    if (query.isEmpty) {
      _loadExpenses();
      return;
    }

    final currentList = state.value ?? [];
    final filteredList = currentList.where((expense) {
      return expense.name
          .toString()
          .toLowerCase()
          .contains(query.toLowerCase());
    }).toList();

    state = AsyncValue.data(filteredList);
  }
}

final expenseListNotifierProvider = StateNotifierProvider.autoDispose<
    ExpenseListNotifier,
    AsyncValue<List<Expense>>>((ref) => ExpenseListNotifier(ref));
