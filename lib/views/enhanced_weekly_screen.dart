import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction.dart';
import '../models/category.dart';

class EnhancedWeeklyScreen extends StatefulWidget {
  final List<Transaction> transactions;
  final List<Category> categories;

  const EnhancedWeeklyScreen({
    Key? key,
    required this.transactions,
    required this.categories,
  }) : super(key: key);

  @override
  State<EnhancedWeeklyScreen> createState() => _EnhancedWeeklyScreenState();
}

class _EnhancedWeeklyScreenState extends State<EnhancedWeeklyScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Map<String, double> _getDailyExpenses() {
    final dailyExpenses = <String, double>{};
    
    for (final transaction in widget.transactions) {
      if (transaction.type == 'expense') {
        final dayKey = DateFormat('EEE dd').format(transaction.date);
        dailyExpenses[dayKey] = (dailyExpenses[dayKey] ?? 0) + transaction.amount;
      }
    }
    
    return dailyExpenses;
  }

  Map<String, double> _getCategoryExpenses() {
    final categoryExpenses = <String, double>{};
    
    for (final transaction in widget.transactions) {
      if (transaction.type == 'expense') {
        final category = widget.categories.firstWhere(
          (c) => c.name == transaction.category,
          orElse: () => Category(
            id: 'unknown', 
            name: 'Unknown', 
            iconCode: Icons.help.codePoint, 
            colorValue: Colors.grey.value,
          ),
        );
        categoryExpenses[category.name] = (categoryExpenses[category.name] ?? 0) + transaction.amount;
      }
    }
    
    return categoryExpenses;
  }

  Widget _buildDailyChart() {
    final dailyData = _getDailyExpenses();
    
    if (dailyData.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No expense data available'),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: dailyData.values.isNotEmpty ? dailyData.values.reduce((a, b) => a > b ? a : b) * 1.2 : 100,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.blueGrey,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${dailyData.keys.elementAt(group.x.toInt())}\n${rod.toY.toStringAsFixed(0)}',
                  const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < dailyData.length) {
                    final key = dailyData.keys.elementAt(index);
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        key.split(' ')[0], // Show only day name
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: dailyData.entries.map((entry) {
            final index = dailyData.keys.toList().indexOf(entry.key);
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: entry.value,
                  color: Colors.blue.shade600,
                  width: 20,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryChart() {
    final categoryData = _getCategoryExpenses();
    
    if (categoryData.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No category data available'),
          ],
        ),
      );
    }

    final colors = [
      Colors.blue.shade600,
      Colors.red.shade600,
      Colors.green.shade600,
      Colors.orange.shade600,
      Colors.purple.shade600,
      Colors.teal.shade600,
      Colors.pink.shade600,
      Colors.brown.shade600,
    ];

    return Column(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sections: categoryData.entries.map((entry) {
                final index = categoryData.keys.toList().indexOf(entry.key);
                final percentage = entry.value / categoryData.values.fold(0.0, (a, b) => a + b) * 100;
                
                return PieChartSectionData(
                  color: colors[index % colors.length],
                  value: entry.value,
                  title: '${percentage.toStringAsFixed(1)}%',
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: categoryData.length,
            itemBuilder: (context, index) {
              final entry = categoryData.entries.elementAt(index);
              return ListTile(
                leading: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colors[index % colors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(entry.key),
                trailing: Text(
                  entry.value.toStringAsFixed(0),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsList() {
    if (widget.transactions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No transactions available'),
          ],
        ),
      );
    }

    final groupedTransactions = <String, List<Transaction>>{};
    
    for (final transaction in widget.transactions) {
      final dateKey = DateFormat('EEE, MMM dd').format(transaction.date);
      if (!groupedTransactions.containsKey(dateKey)) {
        groupedTransactions[dateKey] = [];
      }
      groupedTransactions[dateKey]!.add(transaction);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedTransactions.length,
      itemBuilder: (context, index) {
        final dateKey = groupedTransactions.keys.elementAt(index);
        final dayTransactions = groupedTransactions[dateKey]!;
        final dayTotal = dayTransactions.fold(0.0, (sum, t) => 
            sum + (t.type == 'expense' ? -t.amount : t.amount));

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateKey,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      dayTotal >= 0 
                          ? '+${dayTotal.toStringAsFixed(0)}'
                          : dayTotal.toStringAsFixed(0),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: dayTotal >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dayTransactions.length,
                itemBuilder: (context, transIndex) {
                  final transaction = dayTransactions[transIndex];
                  final category = widget.categories.firstWhere(
                    (c) => c.name == transaction.category,
                    orElse: () => Category(
                      id: 'unknown', 
                      name: 'Unknown', 
                      iconCode: Icons.help.codePoint, 
                      colorValue: Colors.grey.value,
                    ),
                  );

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: transaction.type == 'income' 
                          ? Colors.green.shade100 
                          : Colors.red.shade100,
                      child: Icon(
                        category.icon,
                        color: transaction.type == 'income' 
                            ? Colors.green.shade700 
                            : Colors.red.shade700,
                      ),
                    ),
                    title: Text(transaction.title),
                    subtitle: Text(category.name),
                    trailing: Text(
                      transaction.type == 'income' 
                          ? '+${transaction.amount.toStringAsFixed(0)}'
                          : '-${transaction.amount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: transaction.type == 'income' 
                            ? Colors.green.shade700 
                            : Colors.red.shade700,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final weekStart = widget.transactions.isNotEmpty 
        ? widget.transactions.map((t) => t.date).reduce((a, b) => a.isBefore(b) ? a : b)
        : DateTime.now();
    final weekEnd = widget.transactions.isNotEmpty 
        ? widget.transactions.map((t) => t.date).reduce((a, b) => a.isAfter(b) ? a : b)
        : DateTime.now();
    
    final totalExpenses = widget.transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final totalIncome = widget.transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);

    return Scaffold(
      appBar: AppBar(
        title: Text('${DateFormat('MMM dd').format(weekStart)} - ${DateFormat('MMM dd').format(weekEnd)}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.bar_chart), text: 'Daily'),
            Tab(icon: Icon(Icons.pie_chart), text: 'Categories'),
            Tab(icon: Icon(Icons.list), text: 'Transactions'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Summary Cards
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.arrow_upward, color: Colors.green.shade700),
                          const SizedBox(height: 8),
                          Text(
                            'Income',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            totalIncome.toStringAsFixed(0),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.arrow_downward, color: Colors.red.shade700),
                          const SizedBox(height: 8),
                          Text(
                            'Expenses',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            totalExpenses.toStringAsFixed(0),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.account_balance_wallet, color: Colors.blue.shade700),
                          const SizedBox(height: 8),
                          Text(
                            'Balance',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            (totalIncome - totalExpenses).toStringAsFixed(0),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDailyChart(),
                _buildCategoryChart(),
                _buildTransactionsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}