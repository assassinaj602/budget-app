import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/category.dart';

class DayTransactionsScreen extends StatelessWidget {
  final DateTime date;
  final List<Transaction> transactions;
  final List<Category> categories;

  const DayTransactionsScreen({
    Key? key,
    required this.date,
    required this.transactions,
    required this.categories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dayTransactions = transactions
        .where((t) =>
            t.date.year == date.year &&
            t.date.month == date.month &&
            t.date.day == date.day)
        .toList();

    final expenses = dayTransactions.where((t) => t.type == 'expense').toList();
    final income = dayTransactions.where((t) => t.type == 'income').toList();

    final totalExpense = expenses.fold(0.0, (sum, t) => sum + t.amount);
    final totalIncome = income.fold(0.0, (sum, t) => sum + t.amount);

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('EEEE, MMM dd, yyyy').format(date)),
        elevation: 0,
      ),
      body: dayTransactions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined,
                      size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions on this day',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Summary Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Summary',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSummaryItem(
                              context,
                              'Income',
                              totalIncome,
                              Colors.green,
                              Icons.arrow_upward,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey.shade300,
                            ),
                            _buildSummaryItem(
                              context,
                              'Expense',
                              totalExpense,
                              Colors.red,
                              Icons.arrow_downward,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey.shade300,
                            ),
                            _buildSummaryItem(
                              context,
                              'Net',
                              totalIncome - totalExpense,
                              totalIncome >= totalExpense
                                  ? Colors.green
                                  : Colors.red,
                              Icons.account_balance_wallet,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Expenses Section
                if (expenses.isNotEmpty) ...[
                  Text(
                    'Expenses (${expenses.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ...expenses.map((transaction) {
                    final category = categories.firstWhere(
                      (c) => c.id == transaction.category,
                      orElse: () => Category(
                        id: 'unknown',
                        name: 'Unknown',
                        iconCode: Icons.help_outline.codePoint,
                        colorValue: Colors.grey.value,
                      ),
                    );
                    return _buildTransactionTile(
                      context,
                      transaction,
                      category,
                      true,
                    );
                  }).toList(),
                  const SizedBox(height: 24),
                ],

                // Income Section
                if (income.isNotEmpty) ...[
                  Text(
                    'Income (${income.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ...income.map((transaction) {
                    final category = categories.firstWhere(
                      (c) => c.id == transaction.category,
                      orElse: () => Category(
                        id: 'unknown',
                        name: 'Unknown',
                        iconCode: Icons.help_outline.codePoint,
                        colorValue: Colors.grey.value,
                      ),
                    );
                    return _buildTransactionTile(
                      context,
                      transaction,
                      category,
                      false,
                    );
                  }).toList(),
                ],
              ],
            ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount.toStringAsFixed(0),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionTile(
    BuildContext context,
    Transaction transaction,
    Category category,
    bool isExpense,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: category.color.withOpacity(0.2),
          child: Icon(category.icon, color: category.color),
        ),
        title: Text(
          transaction.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              category.name,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ],
        ),
        trailing: Text(
          '${isExpense ? '-' : '+'}${transaction.amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isExpense ? Colors.red : Colors.green,
          ),
        ),
      ),
    );
  }
}
