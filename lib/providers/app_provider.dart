import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../models/transaction_template.dart';
import '../models/recurring_transaction.dart';

class AppState {
  final ThemeMode themeMode;
  final List<Transaction> transactions;
  final List<Category> categories;
  final List<TransactionTemplate> templates;
  final List<RecurringTransaction> recurringTransactions;

  const AppState({
    this.themeMode = ThemeMode.system,
    this.transactions = const [],
    this.categories = const [],
    this.templates = const [],
    this.recurringTransactions = const [],
  });

  AppState copyWith({
    ThemeMode? themeMode,
    List<Transaction>? transactions,
    List<Category>? categories,
    List<TransactionTemplate>? templates,
    List<RecurringTransaction>? recurringTransactions,
  }) {
    return AppState(
      themeMode: themeMode ?? this.themeMode,
      transactions: transactions ?? this.transactions,
      categories: categories ?? this.categories,
      templates: templates ?? this.templates,
      recurringTransactions:
          recurringTransactions ?? this.recurringTransactions,
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
      final templatesBox = await Hive.openBox<TransactionTemplate>('templates');
      final recurringBox =
          await Hive.openBox<RecurringTransaction>('recurring_transactions');

      List<Category> categories = categoriesBox.values.toList();
      List<TransactionTemplate> templates = templatesBox.values.toList();
      List<RecurringTransaction> recurringTransactions =
          recurringBox.values.toList();

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

      // Add default templates if empty
      if (templates.isEmpty) {
        templates = [
          TransactionTemplate(
            title: 'Morning Coffee',
            amount: 5.00,
            category: 'Food',
            type: 'expense',
            isDefault: true,
          ),
          TransactionTemplate(
            title: 'Lunch',
            amount: 15.00,
            category: 'Food',
            type: 'expense',
            isDefault: true,
          ),
          TransactionTemplate(
            title: 'Fuel',
            amount: 50.00,
            category: 'Transport',
            type: 'expense',
            isDefault: true,
          ),
          TransactionTemplate(
            title: 'Monthly Salary',
            amount: 5000.00,
            category: 'Salary',
            type: 'income',
            isDefault: true,
          ),
        ];

        for (final template in templates) {
          await templatesBox.add(template);
        }
      }

      state = state.copyWith(
        transactions: transactionsBox.values.toList(),
        categories: categories,
        templates: templates,
        recurringTransactions: recurringTransactions,
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

  Future<void> updateTransaction(Transaction updatedTransaction) async {
    try {
      final box = await Hive.openBox<Transaction>('transactions');
      final transactions = [...state.transactions];
      final index =
          transactions.indexWhere((t) => t.id == updatedTransaction.id);

      if (index != -1) {
        transactions[index] = updatedTransaction;
        await box.putAt(index, updatedTransaction);

        state = state.copyWith(transactions: transactions);
      }
    } catch (e) {
      debugPrint('Error updating transaction: $e');
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      final box = await Hive.openBox<Transaction>('transactions');
      final transactions = [...state.transactions];
      final index = transactions.indexWhere((t) => t.id == transactionId);

      if (index != -1) {
        transactions.removeAt(index);
        await box.deleteAt(index);

        state = state.copyWith(transactions: transactions);
      }
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
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

  Future<void> addTemplate(TransactionTemplate template) async {
    try {
      final box = await Hive.openBox<TransactionTemplate>('templates');
      await box.add(template);

      state = state.copyWith(
        templates: [...state.templates, template],
      );
    } catch (e) {
      debugPrint('Error adding template: $e');
    }
  }

  Future<void> deleteTemplate(String templateId) async {
    try {
      final box = await Hive.openBox<TransactionTemplate>('templates');
      final templates = [...state.templates];
      final index = templates.indexWhere((t) => t.id == templateId);

      if (index != -1) {
        templates.removeAt(index);
        await box.deleteAt(index);

        state = state.copyWith(templates: templates);
      }
    } catch (e) {
      debugPrint('Error deleting template: $e');
    }
  }

  // Recurring Transaction Methods
  Future<void> addRecurringTransaction(RecurringTransaction recurring) async {
    try {
      final box =
          await Hive.openBox<RecurringTransaction>('recurring_transactions');
      await box.add(recurring);

      state = state.copyWith(
        recurringTransactions: [...state.recurringTransactions, recurring],
      );
    } catch (e) {
      debugPrint('Error adding recurring transaction: $e');
    }
  }

  Future<void> updateRecurringTransaction(
      RecurringTransaction updatedRecurring) async {
    try {
      final box =
          await Hive.openBox<RecurringTransaction>('recurring_transactions');
      final recurring = [...state.recurringTransactions];
      final index = recurring.indexWhere((r) => r.id == updatedRecurring.id);

      if (index != -1) {
        recurring[index] = updatedRecurring;
        await box.putAt(index, updatedRecurring);

        state = state.copyWith(recurringTransactions: recurring);
      }
    } catch (e) {
      debugPrint('Error updating recurring transaction: $e');
    }
  }

  Future<void> deleteRecurringTransaction(String recurringId) async {
    try {
      final box =
          await Hive.openBox<RecurringTransaction>('recurring_transactions');
      final recurring = [...state.recurringTransactions];
      final index = recurring.indexWhere((r) => r.id == recurringId);

      if (index != -1) {
        recurring.removeAt(index);
        await box.deleteAt(index);

        state = state.copyWith(recurringTransactions: recurring);
      }
    } catch (e) {
      debugPrint('Error deleting recurring transaction: $e');
    }
  }

  /// Clear all local data (transactions and categories) and reset app state.
  Future<void> clearAllData() async {
    try {
      // Clear transactions
      if (Hive.isBoxOpen('transactions')) {
        final txBox = Hive.box<Transaction>('transactions');
        await txBox.clear();
      } else {
        final txBox = await Hive.openBox<Transaction>('transactions');
        await txBox.clear();
      }

      // Clear categories
      if (Hive.isBoxOpen('categories')) {
        final catBox = Hive.box<Category>('categories');
        await catBox.clear();
      } else {
        final catBox = await Hive.openBox<Category>('categories');
        await catBox.clear();
      }

      state = const AppState();
    } catch (e) {
      debugPrint('Error clearing data: $e');
    }
  }
}

final appProvider = StateNotifierProvider<AppNotifier, AppState>((ref) {
  return AppNotifier();
});
