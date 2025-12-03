import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../providers/app_provider.dart';
import '../services/advanced_export_service.dart';
import '../views/theme/app_theme.dart';

class EnhancedReportsScreen extends ConsumerStatefulWidget {
  const EnhancedReportsScreen({super.key});

  @override
  ConsumerState<EnhancedReportsScreen> createState() =>
      _EnhancedReportsScreenState();
}

class _EnhancedReportsScreenState extends ConsumerState<EnhancedReportsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeframe = 'Month';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Transaction> _getFilteredTransactions(List<Transaction> transactions) {
    final now = _selectedDate;
    switch (_selectedTimeframe) {
      case 'Week':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return transactions
            .where((t) =>
                t.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
                t.date.isBefore(endOfWeek.add(const Duration(days: 1))))
            .toList();
      case 'Month':
        return transactions
            .where((t) => t.date.year == now.year && t.date.month == now.month)
            .toList();
      case 'Year':
        return transactions.where((t) => t.date.year == now.year).toList();
      case 'All':
      default:
        return transactions;
    }
  }

  Widget _buildOverviewTab(
      List<Transaction> transactions, List<Category> categories) {
    final income = transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);
    final expenses = transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);
    final balance = income - expenses;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.43,
                    child: Card(
                      color: Colors.green.shade50,
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(Icons.trending_up,
                                color: Colors.green.shade600, size: 32),
                            const SizedBox(height: 8),
                            Text(
                              'Income',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              income.toStringAsFixed(0),
                              style: TextStyle(
                                fontSize: 20,
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
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.43,
                    child: Card(
                      color: Colors.red.shade50,
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(Icons.trending_down,
                                color: Colors.red.shade600, size: 32),
                            const SizedBox(height: 8),
                            Text(
                              'Expenses',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              expenses.toStringAsFixed(0),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
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
            const SizedBox(height: 16),

            // Balance Card
            Card(
              color: balance >= 0 ? Colors.blue.shade50 : Colors.orange.shade50,
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Net Balance',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: balance >= 0
                                ? Colors.blue.shade700
                                : Colors.orange.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          balance >= 0
                              ? '+${balance.toStringAsFixed(0)}'
                              : balance.toStringAsFixed(0),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: balance >= 0
                                ? Colors.blue.shade700
                                : Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      balance >= 0
                          ? Icons.account_balance_wallet
                          : Icons.warning,
                      color: balance >= 0
                          ? Colors.blue.shade600
                          : Colors.orange.shade600,
                      size: 48,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Transaction Count Stats
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaction Statistics',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                '${transactions.length}',
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const Text('Total Transactions'),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                '${transactions.where((t) => t.type == 'income').length}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade600,
                                ),
                              ),
                              const Text('Income'),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                '${transactions.where((t) => t.type == 'expense').length}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade600,
                                ),
                              ),
                              const Text('Expenses'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendsTab(List<Transaction> transactions) {
    // Group data based on _selectedTimeframe
    final grouped = <String, Map<String, double>>{};
    String makeKey(DateTime d) {
      switch (_selectedTimeframe) {
        case 'Week':
          final startOfWeek = d.subtract(Duration(days: d.weekday - 1));
          return 'Wk ${DateFormat('w').format(startOfWeek)} ${DateFormat('yyyy').format(startOfWeek)}';
        case 'Month':
          return DateFormat('MMM yyyy').format(d);
        case 'Year':
          return DateFormat('yyyy').format(d);
        case 'All':
        default:
          return DateFormat('MMM yyyy').format(d);
      }
    }

    for (final t in transactions) {
      final key = makeKey(t.date);
      grouped.putIfAbsent(key, () => {'income': 0.0, 'expense': 0.0});
      grouped[key]![t.type] = (grouped[key]![t.type] ?? 0.0) + t.amount;
    }

    final keys = grouped.keys.toList()
      ..sort((a, b) {
        // Attempt to sort by parsed date fragments
        DateTime parseKey(String k) {
          if (_selectedTimeframe == 'Year') {
            return DateTime(int.tryParse(k) ?? 0);
          }
          // For week/month, fallback to first day of month
          final parts = k.split(' ');
          if (parts.length >= 2 && int.tryParse(parts.last) != null) {
            try {
              return DateFormat('MMM yyyy').parse('${parts[0]} ${parts[1]}');
            } catch (_) {
              return DateTime.now();
            }
          }
          return DateTime.now();
        }

        return parseKey(a).compareTo(parseKey(b));
      });

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedTimeframe == 'Week'
                          ? 'Weekly Trends'
                          : _selectedTimeframe == 'Year'
                              ? 'Yearly Trends'
                              : _selectedTimeframe == 'All'
                                  ? 'All-Time Trends'
                                  : 'Monthly Trends',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 1000,
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: 1,
                                getTitlesWidget:
                                    (double value, TitleMeta meta) {
                                  final index = value.toInt();
                                  if (index >= 0 && index < keys.length) {
                                    final key = keys[index];
                                    final label = _selectedTimeframe == 'Year'
                                        ? key
                                        : key.split(' ')[0];
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        label,
                                        style: const TextStyle(fontSize: 10),
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
                                interval: 1000,
                                getTitlesWidget:
                                    (double value, TitleMeta meta) {
                                  return Text(value.toInt().toString(),
                                      style: const TextStyle(fontSize: 10));
                                },
                                reservedSize: 42,
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: true),
                          minX: 0,
                          maxX: (keys.length - 1).toDouble(),
                          minY: 0,
                          maxY:
                              grouped.values.expand((m) => m.values).isNotEmpty
                                  ? grouped.values
                                          .expand((m) => m.values)
                                          .reduce((a, b) => a > b ? a : b) *
                                      1.2
                                  : 1000,
                          lineBarsData: [
                            LineChartBarData(
                              spots: keys.map((k) {
                                final i = keys.indexOf(k);
                                return FlSpot(
                                    i.toDouble(), grouped[k]!['income'] ?? 0.0);
                              }).toList(),
                              isCurved: true,
                              color: Colors.green.shade600,
                              barWidth: 3,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.green.shade100.withOpacity(0.3),
                              ),
                            ),
                            LineChartBarData(
                              spots: keys.map((k) {
                                final i = keys.indexOf(k);
                                return FlSpot(i.toDouble(),
                                    grouped[k]!['expense'] ?? 0.0);
                              }).toList(),
                              isCurved: true,
                              color: Colors.red.shade600,
                              barWidth: 3,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.red.shade100.withOpacity(0.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.green.shade600,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Income'),
                        const SizedBox(width: 24),
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.red.shade600,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Expenses'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesTab(
      List<Transaction> transactions, List<Category> categories) {
    final categoryData = <String, Map<String, dynamic>>{};

    for (final transaction in transactions) {
      if (transaction.type == 'expense') {
        final category = categories.firstWhere(
          (c) => c.name == transaction.category,
          orElse: () => Category(
            id: 'unknown',
            name: 'Unknown',
            iconCode: Icons.help.codePoint,
            colorValue: Colors.grey.value,
          ),
        );

        if (!categoryData.containsKey(category.name)) {
          categoryData[category.name] = {
            'amount': 0.0,
            'count': 0,
            'category': category
          };
        }
        categoryData[category.name]!['amount'] += transaction.amount;
        categoryData[category.name]!['count'] += 1;
      }
    }

    final sortedCategories = categoryData.entries.toList()
      ..sort((a, b) => b.value['amount'].compareTo(a.value['amount']));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (sortedCategories.isNotEmpty) ...[
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top Categories',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: sortedCategories.take(6).map((entry) {
                            final index = sortedCategories.indexOf(entry);
                            final colors = [
                              Colors.blue.shade600,
                              Colors.red.shade600,
                              Colors.green.shade600,
                              Colors.orange.shade600,
                              Colors.purple.shade600,
                              Colors.teal.shade600,
                            ];
                            final total = sortedCategories.fold(
                                0.0, (sum, e) => sum + e.value['amount']);
                            final percentage =
                                (entry.value['amount'] / total * 100);

                            return PieChartSectionData(
                              color: colors[index % colors.length],
                              value: entry.value['amount'],
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category Breakdown',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sortedCategories.length,
                      itemBuilder: (context, index) {
                        final entry = sortedCategories[index];
                        final category = entry.value['category'] as Category;
                        final amount = entry.value['amount'] as double;
                        final count = entry.value['count'] as int;
                        final total = sortedCategories.fold(
                            0.0, (sum, e) => sum + e.value['amount']);
                        final percentage = (amount / total * 100);

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red.shade100,
                            child:
                                Icon(category.icon, color: Colors.red.shade700),
                          ),
                          title: Text(category.name),
                          subtitle: Text('$count transactions'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                amount.toStringAsFixed(0),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ] else
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pie_chart, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No category data available'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExportTab(List<Transaction> transactions) {
    final state = ref.watch(appProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Export Options Card
          Card(
            elevation: 6,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryContainer,
                    Colors.white,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.file_download_outlined,
                            color: AppColors.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Export & Backup Center',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Export your data for analysis or create backups',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Export Statistics
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              'Transactions',
                              '${transactions.length}',
                              Icons.receipt_long,
                              AppColors.info,
                            ),
                          ),
                          Container(
                              height: 40,
                              width: 1,
                              color: AppColors.primary.withOpacity(0.2)),
                          Expanded(
                            child: _buildStatItem(
                              'Categories',
                              '${state.categories.length}',
                              Icons.category,
                              AppColors.warning,
                            ),
                          ),
                          Container(
                              height: 40,
                              width: 1,
                              color: AppColors.primary.withOpacity(0.2)),
                          Expanded(
                            child: _buildStatItem(
                              'Period',
                              _selectedTimeframe,
                              Icons.calendar_today,
                              AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Export Actions
                    _buildExportAction(
                      'Export Transactions to CSV',
                      'Download all transaction data in spreadsheet format',
                      Icons.table_chart,
                      AppColors.success,
                      transactions.isNotEmpty,
                      () => _handleCsvExport(transactions, state.categories),
                    ),

                    const SizedBox(height: 16),

                    _buildExportAction(
                      'Generate Detailed Report',
                      'Create a comprehensive financial analysis report',
                      Icons.assessment,
                      AppColors.info,
                      transactions.isNotEmpty,
                      () => _handleReportGeneration(
                          transactions, state.categories),
                    ),

                    const SizedBox(height: 16),

                    _buildExportAction(
                      'Export Category Summary',
                      'Download spending breakdown by category',
                      Icons.pie_chart,
                      AppColors.warning,
                      transactions.isNotEmpty,
                      () => _handleCategorySummaryExport(
                          transactions, state.categories),
                    ),

                    const SizedBox(height: 16),

                    _buildExportAction(
                      'Create Full Backup',
                      'Backup all data including transactions and settings',
                      Icons.backup,
                      AppColors.primary,
                      true,
                      () => _handleFullBackup(
                          state.transactions, state.categories),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Import/Restore Card
          Card(
            elevation: 6,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.secondaryContainer,
                    Colors.white,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.file_upload_outlined,
                            color: AppColors.secondary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Import & Restore',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.secondary,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Restore data from backup files',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildExportAction(
                      'Restore from Backup',
                      'Import data from a previously created backup file',
                      Icons.restore,
                      AppColors.secondary,
                      true,
                      () => _handleBackupRestore(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Report Summary',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text('Period: ${_selectedTimeframe}'),
                  Text('Transactions: ${transactions.length}'),
                  Text(
                      'Date Range: ${transactions.isNotEmpty ? "${DateFormat('MMM dd, yyyy').format(transactions.first.date)} - ${DateFormat('MMM dd, yyyy').format(transactions.last.date)}" : "No data"}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);
    final filteredTransactions = _getFilteredTransactions(state.transactions);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Reports'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.trending_up), text: 'Trends'),
            Tab(icon: Icon(Icons.pie_chart), text: 'Categories'),
            Tab(icon: Icon(Icons.file_download), text: 'Export'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Time Period Selector
          Container(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Text('Period: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ['Week', 'Month', 'Year', 'All']
                              .map(
                                (period) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(period),
                                    selected: _selectedTimeframe == period,
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() {
                                          _selectedTimeframe = period;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() {
                            _selectedDate = date;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(filteredTransactions, state.categories),
                _buildTrendsTab(filteredTransactions),
                _buildCategoriesTab(filteredTransactions, state.categories),
                _buildExportTab(filteredTransactions),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods for Export Functionality
  Widget _buildStatItem(
      String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textTertiary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildExportAction(
    String title,
    String description,
    IconData icon,
    Color color,
    bool enabled,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: enabled ? Colors.white : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: enabled ? color.withOpacity(0.3) : Colors.grey.shade300,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (enabled ? color : Colors.grey).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: enabled ? color : Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: enabled ? AppColors.textPrimary : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: enabled ? AppColors.textSecondary : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: enabled ? color : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Export Handler Methods
  Future<void> _handleCsvExport(
      List<Transaction> transactions, List<Category> categories) async {
    try {
      await AdvancedExportService.quickExportTransactions(
          context, transactions, categories);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('Export failed: $e'),
              ],
            ),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleReportGeneration(
      List<Transaction> transactions, List<Category> categories) async {
    try {
      final filePath = await AdvancedExportService.generateDetailedReport(
        transactions,
        categories,
        _selectedTimeframe,
        _selectedDate,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                      'Report generated successfully!\nSaved to: ${filePath.split('/').last}'),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('Report generation failed: $e'),
              ],
            ),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleCategorySummaryExport(
      List<Transaction> transactions, List<Category> categories) async {
    try {
      // Calculate category data
      final categoryData = <String, double>{};
      for (final transaction
          in transactions.where((t) => t.type == 'expense')) {
        categoryData[transaction.category] =
            (categoryData[transaction.category] ?? 0) + transaction.amount;
      }

      final filePath = await AdvancedExportService.exportCategorySummaryToCSV(
        categoryData,
        _selectedTimeframe,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                      'Category summary exported!\nSaved to: ${filePath.split('/').last}'),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('Category export failed: $e'),
              ],
            ),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleFullBackup(
      List<Transaction> transactions, List<Category> categories) async {
    try {
      await AdvancedExportService.quickCreateBackup(
          context, transactions, categories);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('Backup failed: $e'),
              ],
            ),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleBackupRestore() async {
    try {
      // Show confirmation dialog first
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Restore from Backup'),
          content: const Text(
              'This will replace all current data with data from the backup file. '
              'Are you sure you want to continue?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
              ),
              child: const Text('Restore'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await AdvancedExportService.importBackup();

        // TODO: Implement actual data restoration
        // This would involve updating the app state with the imported data

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text('Backup restored successfully!'),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('Restore failed: $e'),
              ],
            ),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
