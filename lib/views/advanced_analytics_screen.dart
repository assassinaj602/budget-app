import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../providers/app_provider.dart';

class AdvancedAnalyticsScreen extends ConsumerStatefulWidget {
  const AdvancedAnalyticsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdvancedAnalyticsScreen> createState() =>
      _AdvancedAnalyticsScreenState();
}

class _AdvancedAnalyticsScreenState
    extends ConsumerState<AdvancedAnalyticsScreen> {
  String _selectedPeriod = '6M'; // '1M', '3M', '6M', '1Y', 'ALL'
  String _selectedChartType = 'Line'; // 'Line', 'Bar', 'Pie'

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);
    final transactions = _getFilteredTransactions(state.transactions);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodSelector(),
            const SizedBox(height: 24),
            _buildSummaryCards(transactions),
            const SizedBox(height: 24),
            _buildChartTypeSelector(),
            const SizedBox(height: 16),
            _buildMainChart(transactions),
            const SizedBox(height: 24),
            _buildCategoryBreakdown(transactions),
            const SizedBox(height: 24),
            _buildTrendAnalysis(transactions),
            const SizedBox(height: 24),
            _buildTopSpendingCategories(transactions),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _periodButton('1M'),
            _periodButton('3M'),
            _periodButton('6M'),
            _periodButton('1Y'),
            _periodButton('ALL'),
          ],
        ),
      ),
    );
  }

  Widget _periodButton(String period) {
    final isSelected = _selectedPeriod == period;
    return InkWell(
      onTap: () => setState(() => _selectedPeriod = period),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.indigo : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          period,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(List<Transaction> transactions) {
    final income = transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);
    final expense = transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);
    final balance = income - expense;
    final savingsRate = income > 0 ? ((balance / income) * 100) : 0.0;

    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            'Income',
            '\$${income.toStringAsFixed(2)}',
            Colors.green,
            Icons.trending_up,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _summaryCard(
            'Expense',
            '\$${expense.toStringAsFixed(2)}',
            Colors.red,
            Icons.trending_down,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _summaryCard(
            'Savings',
            '${savingsRate.toStringAsFixed(1)}%',
            Colors.blue,
            Icons.savings,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartTypeSelector() {
    return Row(
      children: [
        const Text(
          'Chart Type:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 12),
        ChoiceChip(
          label: const Text('Line'),
          selected: _selectedChartType == 'Line',
          onSelected: (selected) {
            if (selected) setState(() => _selectedChartType = 'Line');
          },
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Bar'),
          selected: _selectedChartType == 'Bar',
          onSelected: (selected) {
            if (selected) setState(() => _selectedChartType = 'Bar');
          },
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Pie'),
          selected: _selectedChartType == 'Pie',
          onSelected: (selected) {
            if (selected) setState(() => _selectedChartType = 'Pie');
          },
        ),
      ],
    );
  }

  Widget _buildMainChart(List<Transaction> transactions) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Spending Trend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: _selectedChartType == 'Line'
                  ? _buildLineChart(transactions)
                  : _selectedChartType == 'Bar'
                      ? _buildBarChart(transactions)
                      : _buildPieChart(transactions),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(List<Transaction> transactions) {
    final monthlyData = _getMonthlyData(transactions);

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${value.toInt()}',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < monthlyData.length) {
                  return Text(
                    monthlyData[index]['month'],
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: monthlyData.asMap().entries.map((entry) {
              return FlSpot(
                entry.key.toDouble(),
                entry.value['amount'],
              );
            }).toList(),
            isCurved: true,
            color: Colors.indigo,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.indigo.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<Transaction> transactions) {
    final monthlyData = _getMonthlyData(transactions);

    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${value.toInt()}',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < monthlyData.length) {
                  return Text(
                    monthlyData[index]['month'],
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: monthlyData.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value['amount'],
                color: Colors.indigo,
                width: 20,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPieChart(List<Transaction> transactions) {
    final categoryData = _getCategoryData(transactions);

    return PieChart(
      PieChartData(
        sections: categoryData.entries.map((entry) {
          final index = categoryData.keys.toList().indexOf(entry.key);
          return PieChartSectionData(
            value: entry.value,
            title:
                '${((entry.value / categoryData.values.reduce((a, b) => a + b)) * 100).toStringAsFixed(1)}%',
            color: Colors.primaries[index % Colors.primaries.length],
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }

  Widget _buildCategoryBreakdown(List<Transaction> transactions) {
    final categoryData = _getCategoryData(transactions);
    final total = categoryData.values.fold(0.0, (sum, val) => sum + val);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...categoryData.entries.map((entry) {
              final percentage = (entry.value / total) * 100;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key),
                        Text(
                          '\$${entry.value.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.primaries[
                            categoryData.keys.toList().indexOf(entry.key) %
                                Colors.primaries.length],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendAnalysis(List<Transaction> transactions) {
    final currentMonthExpense = _getCurrentMonthExpense(transactions);
    final lastMonthExpense = _getLastMonthExpense(transactions);
    final change = lastMonthExpense > 0
        ? ((currentMonthExpense - lastMonthExpense) / lastMonthExpense) * 100
        : 0.0;
    final isIncrease = change > 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trend Analysis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  isIncrease ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isIncrease ? Colors.red : Colors.green,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${change.abs().toStringAsFixed(1)}% ${isIncrease ? 'increase' : 'decrease'}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isIncrease ? Colors.red : Colors.green,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Compared to last month',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSpendingCategories(List<Transaction> transactions) {
    final categoryData = _getCategoryData(transactions);
    final sortedCategories = categoryData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategories = sortedCategories.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top 5 Spending Categories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...topCategories.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors
                      .primaries[index % Colors.primaries.length]
                      .withOpacity(0.2),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Colors.primaries[index % Colors.primaries.length],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(category.key),
                trailing: Text(
                  '\$${category.value.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  List<Transaction> _getFilteredTransactions(List<Transaction> transactions) {
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedPeriod) {
      case '1M':
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case '3M':
        startDate = DateTime(now.year, now.month - 3, now.day);
        break;
      case '6M':
        startDate = DateTime(now.year, now.month - 6, now.day);
        break;
      case '1Y':
        startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      case 'ALL':
        return transactions;
      default:
        startDate = DateTime(now.year, now.month - 6, now.day);
    }

    return transactions.where((t) => t.date.isAfter(startDate)).toList();
  }

  List<Map<String, dynamic>> _getMonthlyData(List<Transaction> transactions) {
    final Map<String, double> monthlyExpenses = {};

    for (final transaction in transactions.where((t) => t.type == 'expense')) {
      final monthKey = DateFormat('MMM').format(transaction.date);
      monthlyExpenses[monthKey] =
          (monthlyExpenses[monthKey] ?? 0) + transaction.amount;
    }

    return monthlyExpenses.entries
        .map((e) => {'month': e.key, 'amount': e.value})
        .toList();
  }

  Map<String, double> _getCategoryData(List<Transaction> transactions) {
    final Map<String, double> categoryExpenses = {};

    for (final transaction in transactions.where((t) => t.type == 'expense')) {
      categoryExpenses[transaction.category] =
          (categoryExpenses[transaction.category] ?? 0) + transaction.amount;
    }

    return categoryExpenses;
  }

  double _getCurrentMonthExpense(List<Transaction> transactions) {
    final now = DateTime.now();
    return transactions
        .where((t) =>
            t.type == 'expense' &&
            t.date.month == now.month &&
            t.date.year == now.year)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double _getLastMonthExpense(List<Transaction> transactions) {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1);
    return transactions
        .where((t) =>
            t.type == 'expense' &&
            t.date.month == lastMonth.month &&
            t.date.year == lastMonth.year)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Analytics Info'),
        content: const Text(
          'This screen provides comprehensive insights into your spending patterns:\n\n'
          '• Period Selector: Choose timeframe for analysis\n'
          '• Summary Cards: Quick overview of income, expense, and savings\n'
          '• Charts: Visual representation of your spending trends\n'
          '• Category Breakdown: See where your money goes\n'
          '• Trend Analysis: Compare with previous period\n'
          '• Top Categories: Your biggest spending areas',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
