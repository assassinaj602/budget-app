import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../providers/app_provider.dart';
import 'enhanced_weekly_screen.dart';

class MonthSelectionScreen extends ConsumerStatefulWidget {
  const MonthSelectionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MonthSelectionScreen> createState() =>
      _MonthSelectionScreenState();
}

class _MonthSelectionScreenState extends ConsumerState<MonthSelectionScreen> {
  int selectedYear = DateTime.now().year;
  int? selectedMonth;

  Map<String, double> _calculateMonthlyData(
      List<Transaction> transactions, int year) {
    final monthlyData = <String, double>{};

    for (int month = 1; month <= 12; month++) {
      final key = DateFormat('MMM yyyy').format(DateTime(year, month));
      final monthTransactions = transactions
          .where((t) =>
              t.type == 'expense' &&
              t.date.year == year &&
              t.date.month == month)
          .toList();

      final total = monthTransactions.fold(0.0, (sum, t) => sum + t.amount);
      monthlyData[key] = total;
    }

    return monthlyData;
  }

  List<Transaction> _getMonthTransactions(
      List<Transaction> transactions, int year, int month) {
    return transactions
        .where((t) => t.date.year == year && t.date.month == month)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);
    final monthlyData = _calculateMonthlyData(state.transactions, selectedYear);
    final totalYearSpending =
        monthlyData.values.fold(0.0, (sum, amount) => sum + amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Month for Weekly View'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Year Selection Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          selectedYear--;
                          selectedMonth = null;
                        });
                      },
                    ),
                    Column(
                      children: [
                        Text(
                          selectedYear.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Total: ${totalYearSpending.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios,
                          color: Colors.white),
                      onPressed: () {
                        setState(() {
                          selectedYear++;
                          selectedMonth = null;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Select a month to view weekly details',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Month Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final month = index + 1;
                  final date = DateTime(selectedYear, month);
                  final monthKey = DateFormat('MMM yyyy').format(date);
                  final monthName = DateFormat('MMM').format(date);
                  final amount = monthlyData[monthKey] ?? 0.0;
                  final isSelected = selectedMonth == month;
                  final hasData = amount > 0;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedMonth = month;
                      });
                    },
                    onDoubleTap: () {
                      if (hasData) {
                        final monthTransactions = _getMonthTransactions(
                            state.transactions, selectedYear, month);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MonthlyWeeklyView(
                              year: selectedYear,
                              month: month,
                              transactions: monthTransactions,
                              categories: state.categories,
                            ),
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor.withOpacity(0.15)
                            : hasData
                                ? Colors.green.shade50
                                : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : hasData
                                  ? Colors.green.shade300
                                  : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              monthName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : hasData
                                        ? Colors.green.shade700
                                        : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              amount.toStringAsFixed(0),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : hasData
                                        ? Colors.green.shade600
                                        : Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (hasData)
                              Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Colors.green.shade400,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              )
                            else
                              Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Action Button
          if (selectedMonth != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () {
                  final monthTransactions = _getMonthTransactions(
                      state.transactions, selectedYear, selectedMonth!);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MonthlyWeeklyView(
                        year: selectedYear,
                        month: selectedMonth!,
                        transactions: monthTransactions,
                        categories: state.categories,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.calendar_view_week),
                label: Text(
                    'View ${DateFormat('MMMM').format(DateTime(selectedYear, selectedMonth!))} Weekly Details'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MonthlyWeeklyView extends StatefulWidget {
  final int year;
  final int month;
  final List<Transaction> transactions;
  final List<Category> categories;

  const MonthlyWeeklyView({
    Key? key,
    required this.year,
    required this.month,
    required this.transactions,
    required this.categories,
  }) : super(key: key);

  @override
  State<MonthlyWeeklyView> createState() => _MonthlyWeeklyViewState();
}

class _MonthlyWeeklyViewState extends State<MonthlyWeeklyView> {
  Map<String, Map<String, dynamic>> _calculateWeeklyData() {
    final firstDayOfMonth = DateTime(widget.year, widget.month, 1);
    final lastDayOfMonth = DateTime(widget.year, widget.month + 1, 0);

    final weeklyData = <String, Map<String, dynamic>>{};

    DateTime current = firstDayOfMonth;
    int weekNumber = 1;

    while (
        current.isBefore(lastDayOfMonth) || current.day == lastDayOfMonth.day) {
      final weekStart = current;
      final weekEnd = DateTime(current.year, current.month, current.day + 6);
      final actualWeekEnd =
          weekEnd.isAfter(lastDayOfMonth) ? lastDayOfMonth : weekEnd;

      final weekTransactions = widget.transactions
          .where((t) =>
              t.type == 'expense' &&
              !t.date.isBefore(weekStart) &&
              !t.date.isAfter(actualWeekEnd))
          .toList();

      final total = weekTransactions.fold(0.0, (sum, t) => sum + t.amount);

      final weekKey = 'Week $weekNumber';
      weeklyData[weekKey] = {
        'total': total,
        'transactions': weekTransactions,
        'startDate': weekStart,
        'endDate': actualWeekEnd,
        'weekNumber': weekNumber,
      };

      current = DateTime(current.year, current.month, current.day + 7);
      weekNumber++;

      if (current.month != widget.month) break;
    }

    return weeklyData;
  }

  @override
  Widget build(BuildContext context) {
    final weeklyData = _calculateWeeklyData();
    final monthName =
        DateFormat('MMMM yyyy').format(DateTime(widget.year, widget.month));
    final totalMonthSpending = weeklyData.values
        .fold(0.0, (sum, week) => sum + (week['total'] as double));

    return Scaffold(
      appBar: AppBar(
        title: Text('$monthName Weekly View'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Month Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Text(
                  monthName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Month Spending: ${totalMonthSpending.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Weekly List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: weeklyData.length,
              itemBuilder: (context, index) {
                final weekKey = weeklyData.keys.elementAt(index);
                final weekData = weeklyData[weekKey]!;
                final total = weekData['total'] as double;
                final startDate = weekData['startDate'] as DateTime;
                final endDate = weekData['endDate'] as DateTime;
                final transactions =
                    weekData['transactions'] as List<Transaction>;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EnhancedWeeklyScreen(
                            transactions: transactions,
                            categories: widget.categories,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    weekKey,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${DateFormat('MMM dd').format(startDate)} - ${DateFormat('MMM dd').format(endDate)}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    total.toStringAsFixed(0),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: total > 0
                                          ? Colors.red.shade700
                                          : Colors.grey.shade500,
                                    ),
                                  ),
                                  Text(
                                    '${transactions.length} transactions',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: totalMonthSpending > 0
                                      ? total / totalMonthSpending
                                      : 0,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    total > 0
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                totalMonthSpending > 0
                                    ? '${((total / totalMonthSpending) * 100).toStringAsFixed(1)}%'
                                    : '0%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
