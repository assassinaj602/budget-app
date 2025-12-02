import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_provider.dart';

class SpendingInsightsScreen extends ConsumerStatefulWidget {
  const SpendingInsightsScreen({super.key});

  @override
  ConsumerState<SpendingInsightsScreen> createState() =>
      _SpendingInsightsScreenState();
}

class _SpendingInsightsScreenState
    extends ConsumerState<SpendingInsightsScreen> {
  String _selectedPeriod = 'month'; // week, month, year

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);
    final transactions = state.transactions;

    // Filter transactions by period
    final now = DateTime.now();
    final filteredTransactions = transactions.where((t) {
      switch (_selectedPeriod) {
        case 'week':
          return t.date.isAfter(now.subtract(const Duration(days: 7)));
        case 'month':
          return t.date.month == now.month && t.date.year == now.year;
        case 'year':
          return t.date.year == now.year;
        default:
          return true;
      }
    }).toList();

    // Calculate insights
    final totalIncome = filteredTransactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalExpense = filteredTransactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);

    // Category breakdown
    final Map<String, double> categorySpending = {};
    for (var t in filteredTransactions.where((t) => t.type == 'expense')) {
      categorySpending[t.category] =
          (categorySpending[t.category] ?? 0) + t.amount;
    }

    final sortedCategories = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spending Insights'),
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period Selector
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildPeriodChip('Week', 'week'),
                      _buildPeriodChip('Month', 'month'),
                      _buildPeriodChip('Year', 'year'),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Total Income',
                        '\$${totalIncome.toStringAsFixed(2)}',
                        Colors.green,
                        Icons.trending_up,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        'Total Expense',
                        '\$${totalExpense.toStringAsFixed(2)}',
                        Colors.red,
                        Icons.trending_down,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                _buildSummaryCard(
                  'Net Balance',
                  '\$${(totalIncome - totalExpense).toStringAsFixed(2)}',
                  totalIncome > totalExpense ? Colors.green : Colors.red,
                  totalIncome > totalExpense
                      ? Icons.check_circle
                      : Icons.warning,
                ),

                const SizedBox(height: 32),

                // Category Breakdown
                const Text(
                  'Spending by Category',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                if (categorySpending.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.pie_chart_outline,
                              size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'No spending data',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  // Pie Chart
                  SizedBox(
                    height: 250,
                    child: PieChart(
                      PieChartData(
                        sections: _buildPieChartSections(
                            categorySpending, totalExpense),
                        centerSpaceRadius: 60,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Category List
                  ...sortedCategories.map((entry) {
                    final category = state.categories.firstWhere(
                      (c) => c.name == entry.key,
                      orElse: () => state.categories.first,
                    );
                    final percentage = (entry.value / totalExpense * 100);

                    return _buildCategoryItem(
                      category.name,
                      entry.value,
                      percentage,
                      category.icon,
                      category.color,
                    );
                  }).toList(),

                  const SizedBox(height: 32),

                  // Spending Trends
                  const Text(
                    'Spending Trend',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    height: 200,
                    child: _buildTrendChart(filteredTransactions),
                  ),

                  const SizedBox(height: 32),

                  // Insights and Tips
                  const Text(
                    'Insights & Tips',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildInsightCard(
                    Icons.lightbulb_outline,
                    'Top Spending Category',
                    sortedCategories.isNotEmpty
                        ? '${sortedCategories.first.key}: \$${sortedCategories.first.value.toStringAsFixed(2)}'
                        : 'No data',
                    Colors.orange,
                  ),

                  const SizedBox(height: 12),

                  _buildInsightCard(
                    Icons.trending_up,
                    'Average Daily Spending',
                    '\$${(totalExpense / (_selectedPeriod == 'week' ? 7 : _selectedPeriod == 'month' ? 30 : 365)).toStringAsFixed(2)}',
                    Colors.blue,
                  ),

                  const SizedBox(height: 12),

                  _buildInsightCard(
                    Icons.savings_outlined,
                    'Savings Rate',
                    totalIncome > 0
                        ? '${((totalIncome - totalExpense) / totalIncome * 100).toStringAsFixed(1)}%'
                        : '0%',
                    Colors.green,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    Map<String, double> categorySpending,
    double total,
  ) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.amber,
    ];

    int index = 0;
    return categorySpending.entries.map((entry) {
      final percentage = (entry.value / total * 100);
      final color = colors[index % colors.length];
      index++;

      return PieChartSectionData(
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        color: color,
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildCategoryItem(
    String name,
    double amount,
    double percentage,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.grey.shade300,
                  color: color,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart(List transactions) {
    // Group by day for visualization
    final Map<DateTime, double> dailySpending = {};

    for (var t in transactions.where((t) => t.type == 'expense')) {
      final day = DateTime(t.date.year, t.date.month, t.date.day);
      dailySpending[day] = (dailySpending[day] ?? 0) + t.amount;
    }

    final sorted = dailySpending.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (sorted.isEmpty) {
      return Center(
        child: Text('No data available',
            style: TextStyle(color: Colors.grey.shade600)),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: sorted.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.value);
            }).toList(),
            isCurved: true,
            color: Theme.of(context).primaryColor,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(
      IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
