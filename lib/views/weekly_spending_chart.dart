import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import 'day_transactions_screen.dart';

class WeeklySpendingChart extends StatelessWidget {
  final List<Transaction> transactions;
  final List<Category> categories;

  const WeeklySpendingChart({
    super.key,
    required this.transactions,
    required this.categories,
  });

  Map<String, double> _calculateWeeklyData(List<Transaction> transactions) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weekData = <String, double>{};
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      final key = weekdays[i];
      weekData[key] = transactions
          .where((t) =>
              t.type == 'expense' &&
              t.date.year == day.year &&
              t.date.month == day.month &&
              t.date.day == day.day)
          .fold(0.0, (sum, t) => sum + t.amount);
    }
    return weekData;
  }

  @override
  Widget build(BuildContext context) {
    final weekData = _calculateWeeklyData(transactions);
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Details')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        child: Center(
          child: Card(
            color: Theme.of(context).cardColor.withOpacity(0.97),
            elevation: 6,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bar_chart, color: Colors.indigo.shade400),
                      const SizedBox(width: 10),
                      Text('Weekly Spending',
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 180,
                    child: BarChart(
                      BarChartData(
                        barGroups: weekData.entries
                            .map((e) => BarChartGroupData(
                                  x: weekData.keys.toList().indexOf(e.key),
                                  barRods: [
                                    BarChartRodData(
                                      toY: e.value,
                                      color: Colors.indigo,
                                      width: 18,
                                      borderRadius: BorderRadius.circular(6),
                                      backDrawRodData:
                                          BackgroundBarChartRodData(
                                        show: true,
                                        toY: weekData.values.fold<double>(0,
                                            (prev, v) => v > prev ? v : prev),
                                        color: Colors.indigo.withOpacity(0.08),
                                      ),
                                    )
                                  ],
                                ))
                            .toList(),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget: (double value, TitleMeta meta) =>
                                  SizedBox(
                                width: 32, // Fixed width for equal spacing
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      weekData.keys.elementAt(value.toInt()),
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipBgColor: Colors.indigo.shade100,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                '${weekData.keys.elementAt(group.x)}\n',
                                const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo),
                                children: [
                                  TextSpan(
                                    text:
                                        'Spent: ${rod.toY.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  const TextSpan(
                                    text: '\nTap to see details',
                                    style: TextStyle(
                                        color: Colors.indigo,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              );
                            },
                          ),
                          touchCallback:
                              (FlTouchEvent event, barTouchResponse) {
                            if (event is FlTapUpEvent &&
                                barTouchResponse != null &&
                                barTouchResponse.spot != null) {
                              final touchedIndex =
                                  barTouchResponse.spot!.touchedBarGroupIndex;
                              final now = DateTime.now();
                              final startOfWeek =
                                  now.subtract(Duration(days: now.weekday - 1));
                              final selectedDate =
                                  startOfWeek.add(Duration(days: touchedIndex));

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DayTransactionsScreen(
                                    date: selectedDate,
                                    transactions: transactions,
                                    categories: categories,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        groupsSpace: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.touch_app,
                          size: 14, color: Colors.indigo.shade300),
                      const SizedBox(width: 4),
                      Text('Tap a bar to see transactions',
                          style: TextStyle(
                              fontSize: 12, color: Colors.indigo.shade300)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
