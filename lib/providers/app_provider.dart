import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/category.dart';
import '../models/transaction.dart';

class AppState {
  final ThemeMode themeMode;
  final List<Transaction> transactions;
  final List<Category> categories;

  const AppState({
    this.themeMode = ThemeMode.system,
    this.transactions = const [],
    this.categories = const [],
  });

  AppState copyWith({
    ThemeMode? themeMode,
    List<Transaction>? transactions,
    List<Category>? categories,
  }) {
    return AppState(
      themeMode: themeMode ?? this.themeMode,
      transactions: transactions ?? this.transactions,
      categories: categories ?? this.categories,
    );
  }
}

class AppNotifier extends StateNotifier<AppState> {
  AppNotifier() : super(const AppState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadData();
  }

  void toggleTheme() {
    state = state.copyWith(
      themeMode:
          state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
    );
  }

  Future<void> loadData() async {
    try {
      final transactionsBox = await Hive.openBox<Transaction>('transactions');
      final categoriesBox = await Hive.openBox<Category>('categories');

      List<Category> categories = categoriesBox.values.toList();

      // Add default categories if empty
      if (categories.isEmpty) {
        categories = [
          Category.withIconAndColor(
              id: 'food',
              name: 'Food',
              icon: Icons.restaurant,
              color: Colors.orange),
          Category.withIconAndColor(
              id: 'transport',
              name: 'Transport',
              icon: Icons.directions_car,
              color: Colors.purple),
          Category.withIconAndColor(
              id: 'shopping',
              name: 'Shopping',
              icon: Icons.shopping_bag,
              color: Colors.pink),
          Category.withIconAndColor(
              id: 'bills',
              name: 'Bills',
              icon: Icons.receipt,
              color: Colors.red),
          Category.withIconAndColor(
              id: 'other_expense',
              name: 'Other Expense',
              icon: Icons.money_off,
              color: Colors.grey),
          Category.withIconAndColor(
              id: 'salary',
              name: 'Salary',
              icon: Icons.attach_money,
              color: Colors.indigo),
          Category.withIconAndColor(
              id: 'gift',
              name: 'Gift',
              icon: Icons.card_giftcard,
              color: Colors.green),
          Category.withIconAndColor(
              id: 'other_income',
              name: 'Other Income',
              icon: Icons.monetization_on,
              color: Colors.blue),
        ];

        // Save default categories
        for (final category in categories) {
          await categoriesBox.add(category);
        }
      }

      state = state.copyWith(
        transactions: transactionsBox.values.toList(),
        categories: categories,
      );
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      final box = await Hive.openBox<Transaction>('transactions');
      await box.add(transaction);

      state = state.copyWith(
        transactions: [...state.transactions, transaction],
      );
    } catch (e) {
      debugPrint('Error adding transaction: $e');
    }
  }

  Future<void> addCategory(Category category) async {
    try {
      final box = await Hive.openBox<Category>('categories');
      await box.add(category);

      state = state.copyWith(
        categories: [...state.categories, category],
      );
    } catch (e) {
      debugPrint('Error adding category: $e');
    }
  }

  Future<void> updateCategory(Category updatedCategory) async {
    try {
      final box = await Hive.openBox<Category>('categories');
      final categories = [...state.categories];
      final index = categories.indexWhere((c) => c.id == updatedCategory.id);

      if (index != -1) {
        categories[index] = updatedCategory;
        await box.putAt(index, updatedCategory);

        state = state.copyWith(categories: categories);
      }
    } catch (e) {
      debugPrint('Error updating category: $e');
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      final box = await Hive.openBox<Category>('categories');
      final categories = [...state.categories];
      final index = categories.indexWhere((c) => c.id == categoryId);

      if (index != -1) {
        categories.removeAt(index);
        await box.deleteAt(index);

        state = state.copyWith(categories: categories);
      }
    } catch (e) {
      debugPrint('Error deleting category: $e');
    }
  }
}

final appProvider = StateNotifierProvider<AppNotifier, AppState>((ref) {
  return AppNotifier();
});
