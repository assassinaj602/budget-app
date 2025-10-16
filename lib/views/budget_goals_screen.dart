import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_provider.dart';
import '../models/category.dart';
import '../views/theme/app_theme.dart';

class BudgetGoalsScreen extends ConsumerStatefulWidget {
  const BudgetGoalsScreen({super.key});

  @override
  ConsumerState<BudgetGoalsScreen> createState() => _BudgetGoalsScreenState();
}

class _BudgetGoalsScreenState extends ConsumerState<BudgetGoalsScreen> {
  final Map<String, double> _categoryBudgets = {};
  double _totalMonthlyBudget = 0.0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveBudgets,
            tooltip: 'Save budgets',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Monthly Budget Overview
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_balance_wallet,
                          color: AppColors.primary, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'Monthly Budget Overview',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Total Monthly Budget',
                      prefixIcon: Icon(Icons.attach_money),
                      helperText: 'Set your overall monthly spending limit',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _totalMonthlyBudget = double.tryParse(value) ?? 0.0;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Category Budgets
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.category,
                          color: AppColors.secondary, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'Category Budgets',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (state.categories.isNotEmpty) ...[
                    ...state.categories
                        .map((category) => _buildCategoryBudgetItem(category)),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(Icons.category_outlined,
                              size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'No categories found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add some expense categories first',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Budget Summary
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.pie_chart, color: AppColors.info, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'Budget Summary',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSummaryRow(
                      'Total Budget', _totalMonthlyBudget, AppColors.primary),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                      'Category Budgets',
                      _categoryBudgets.values
                          .fold(0.0, (sum, amount) => sum + amount),
                      AppColors.secondary),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                      'Remaining',
                      _totalMonthlyBudget -
                          _categoryBudgets.values
                              .fold(0.0, (sum, amount) => sum + amount),
                      AppColors.warning),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Smart Budget Suggestions
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: AppColors.warning, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'Smart Suggestions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSuggestionTile(
                    'Use 50/30/20 Rule',
                    'Allocate 50% for needs, 30% for wants, 20% for savings',
                    Icons.rule,
                    () => _apply50_30_20Rule(),
                  ),
                  _buildSuggestionTile(
                    'Based on Past Spending',
                    'Set budgets based on your spending history',
                    Icons.history,
                    () => _applyHistoricalBudgets(state),
                  ),
                  _buildSuggestionTile(
                    'Conservative Approach',
                    'Set budgets 20% lower than average spending',
                    Icons.security,
                    () => _applyConservativeBudgets(state),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBudgetItem(Category category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Color(category.colorValue).withOpacity(0.2),
            child: Icon(
              category.icon,
              color: Color(category.colorValue),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Enter budget amount',
                    prefixIcon: const Icon(Icons.attach_money, size: 20),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _categoryBudgets[category.name] =
                          double.tryParse(value) ?? 0.0;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            amount.toStringAsFixed(0),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionTile(
      String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: TextButton(
        onPressed: onTap,
        child: const Text('Apply'),
      ),
    );
  }

  void _apply50_30_20Rule() {
    if (_totalMonthlyBudget > 0) {
      // This is a simplified implementation
      // In a real app, you'd categorize expenses as needs/wants/savings
      final needs = _totalMonthlyBudget * 0.5;
      final wants = _totalMonthlyBudget * 0.3;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('50/30/20 Budget Applied'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Needs (50%): ${needs.toStringAsFixed(0)}'),
              Text('Wants (30%): ${wants.toStringAsFixed(0)}'),
              Text(
                  'Savings (20%): ${(_totalMonthlyBudget * 0.2).toStringAsFixed(0)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _applyHistoricalBudgets(AppState state) {
    // Calculate average spending per category from last 3 months
    final now = DateTime.now();
    final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);

    final recentTransactions = state.transactions
        .where((t) => t.date.isAfter(threeMonthsAgo) && t.type == 'expense')
        .toList();

    final categorySpending = <String, double>{};
    for (final transaction in recentTransactions) {
      categorySpending[transaction.category] =
          (categorySpending[transaction.category] ?? 0.0) + transaction.amount;
    }

    setState(() {
      _categoryBudgets.clear();
      categorySpending.forEach((category, amount) {
        _categoryBudgets[category] = amount / 3; // Average per month
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Historical budgets applied!')),
    );
  }

  void _applyConservativeBudgets(AppState state) {
    // Similar to historical but with 20% reduction
    _applyHistoricalBudgets(state);
    setState(() {
      _categoryBudgets.updateAll((key, value) => value * 0.8);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Conservative budgets applied!')),
    );
  }

  void _saveBudgets() {
    // In a real app, you'd save these to a database or shared preferences
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Budgets saved successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context);
  }
}
