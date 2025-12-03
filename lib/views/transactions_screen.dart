import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../providers/currency_provider.dart';
import '../models/transaction.dart';
import '../models/category.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen>
    with AutomaticKeepAliveClientMixin {
  String _selectedFilter = 'All'; // All, Income, Expense
  String _selectedSort = 'Date'; // Date, Amount, Category
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  List<Transaction> _getFilteredTransactions(List<Transaction> transactions) {
    var filtered = transactions.toList();

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((t) {
        return t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            t.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (t.note?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                false);
      }).toList();
    }

    // Apply filter
    if (_selectedFilter == 'Income') {
      filtered = filtered.where((t) => t.type == 'income').toList();
    } else if (_selectedFilter == 'Expense') {
      filtered = filtered.where((t) => t.type == 'expense').toList();
    }

    // Apply sort
    if (_selectedSort == 'Date') {
      filtered.sort((a, b) => b.date.compareTo(a.date));
    } else if (_selectedSort == 'Amount') {
      filtered.sort((a, b) => b.amount.compareTo(a.amount));
    } else if (_selectedSort == 'Category') {
      filtered.sort((a, b) => a.category.compareTo(b.category));
    }

    return filtered;
  }

  Map<String, List<Transaction>> _groupByDate(List<Transaction> transactions) {
    final grouped = <String, List<Transaction>>{};

    for (final transaction in transactions) {
      final dateKey = DateFormat('yyyy-MM-dd').format(transaction.date);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(transaction);
    }

    return grouped;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(appProvider);
    final currency = ref.watch(currencyProvider);
    final transactions = _getFilteredTransactions(state.transactions);
    final groupedTransactions = _groupByDate(transactions);

    final totalIncome = transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpense = transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search transactions...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : const Text('All Transactions'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      body: transactions.isEmpty
          ? _buildEmptyState()
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
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
                          '${transactions.length} Transactions',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildSummaryCard(
                              'Income',
                              totalIncome,
                              Icons.arrow_downward,
                              Colors.green.shade300,
                              currency,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white30,
                            ),
                            _buildSummaryCard(
                              'Expense',
                              totalExpense,
                              Icons.arrow_upward,
                              Colors.red.shade300,
                              currency,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white30,
                            ),
                            _buildSummaryCard(
                              'Balance',
                              totalIncome - totalExpense,
                              Icons.account_balance_wallet,
                              Colors.white,
                              currency,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFilterChip('All'),
                                const SizedBox(width: 8),
                                _buildFilterChip('Income'),
                                const SizedBox(width: 8),
                                _buildFilterChip('Expense'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: PopupMenuButton<String>(
                            icon: Icon(
                              Icons.sort,
                              color: Theme.of(context).primaryColor,
                            ),
                            tooltip: 'Sort Options',
                            onSelected: (value) {
                              setState(() {
                                _selectedSort = value;
                              });
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'Date',
                                child: Row(
                                  children: [
                                    const Icon(Icons.date_range, size: 18),
                                    const SizedBox(width: 8),
                                    const Text('Sort by Date'),
                                    if (_selectedSort == 'Date')
                                      const SizedBox(width: 8),
                                    if (_selectedSort == 'Date')
                                      const Icon(Icons.check,
                                          size: 16, color: Colors.green),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'Amount',
                                child: Row(
                                  children: [
                                    const Icon(Icons.attach_money, size: 18),
                                    const SizedBox(width: 8),
                                    const Text('Sort by Amount'),
                                    if (_selectedSort == 'Amount')
                                      const SizedBox(width: 8),
                                    if (_selectedSort == 'Amount')
                                      const Icon(Icons.check,
                                          size: 16, color: Colors.green),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'Category',
                                child: Row(
                                  children: [
                                    const Icon(Icons.category, size: 18),
                                    const SizedBox(width: 8),
                                    const Text('Sort by Category'),
                                    if (_selectedSort == 'Category')
                                      const SizedBox(width: 8),
                                    if (_selectedSort == 'Category')
                                      const Icon(Icons.check,
                                          size: 16, color: Colors.green),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList.separated(
                    itemCount: groupedTransactions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 0),
                    itemBuilder: (context, index) {
                      final dateKey = groupedTransactions.keys.elementAt(index);
                      final dayTransactions = groupedTransactions[dateKey]!;
                      final date = dayTransactions.first.date;

                      final dayTotal = dayTransactions.fold(0.0, (sum, t) {
                        return sum +
                            (t.type == 'income' ? t.amount : -t.amount);
                      });

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 4, top: 8, bottom: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('EEEE, MMM dd, yyyy').format(date),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                Text(
                                  '${dayTotal >= 0 ? '+' : ''}${dayTotal.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: dayTotal >= 0
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...dayTransactions.map((transaction) {
                            Category category;
                            if (state.categories.isEmpty) {
                              category = Category(
                                id: 'unknown',
                                name: 'Unknown',
                                iconCode: Icons.help_outline.codePoint,
                                colorValue: Colors.grey.value,
                              );
                            } else {
                              category = state.categories.firstWhere(
                                (c) => c.name == transaction.category,
                                orElse: () {
                                  return state.categories.firstWhere(
                                    (c) => c.id == transaction.category,
                                    orElse: () => Category(
                                      id: 'unknown',
                                      name: 'Unknown',
                                      iconCode: Icons.help_outline.codePoint,
                                      colorValue: Colors.grey.value,
                                    ),
                                  );
                                },
                              );
                            }

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: transaction.type == 'income'
                                      ? Colors.green.withOpacity(0.3)
                                      : Colors.red.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: category.color.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    category.icon,
                                    color: category.color,
                                    size: 24,
                                  ),
                                ),
                                title: Text(
                                  transaction.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                category.color.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            category.name,
                                            style: TextStyle(
                                              color: category.color,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          DateFormat('h:mm a')
                                              .format(transaction.date),
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${transaction.type == 'income' ? '+' : '-'}${transaction.amount.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        color: transaction.type == 'income'
                                            ? Colors.green.shade700
                                            : Colors.red.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      currency,
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding your income and expenses',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    double amount,
    IconData icon,
    Color color,
    String currency,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          amount.toStringAsFixed(0),
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    final icon = label == 'Income'
        ? Icons.arrow_downward
        : label == 'Expense'
            ? Icons.arrow_upward
            : Icons.all_inclusive;

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).primaryColor.withOpacity(0.15)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: isSelected
            ? Border.all(color: Theme.of(context).primaryColor, width: 2)
            : Border.all(color: Colors.grey.shade300),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          setState(() {
            _selectedFilter = label;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.check_circle,
                  size: 14,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
