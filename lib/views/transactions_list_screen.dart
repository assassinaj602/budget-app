import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../providers/app_provider.dart';
import 'edit_transaction_screen.dart';

class TransactionsListScreen extends ConsumerStatefulWidget {
  const TransactionsListScreen({super.key});

  @override
  ConsumerState<TransactionsListScreen> createState() =>
      _TransactionsListScreenState();
}

class _TransactionsListScreenState
    extends ConsumerState<TransactionsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterType = 'all'; // all, income, expense
  String _sortBy = 'date'; // date, amount, title

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Transaction> _getFilteredTransactions(List<Transaction> transactions) {
    var filtered = transactions;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((t) =>
              t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              t.category.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply type filter
    if (_filterType != 'all') {
      filtered = filtered.where((t) => t.type == _filterType).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'date':
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'amount':
        filtered.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'title':
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);
    final filteredTransactions = _getFilteredTransactions(state.transactions);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Transactions'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
                const SizedBox(height: 12),
                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Income', 'income'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Expense', 'expense'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Transactions List
          Expanded(
            child: filteredTransactions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = filteredTransactions[index];
                      final category = state.categories.firstWhere(
                        (c) => c.name == transaction.category,
                        orElse: () => state.categories.first,
                      );

                      return Dismissible(
                        key: Key(transaction.id),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await _showDeleteConfirmation(
                              context, transaction);
                        },
                        onDismissed: (direction) {
                          ref
                              .read(appProvider.notifier)
                              .deleteTransaction(transaction.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${transaction.title} deleted'),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () {
                                  ref
                                      .read(appProvider.notifier)
                                      .addTransaction(transaction);
                                },
                              ),
                            ),
                          );
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.shade600,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.delete_forever,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        child: _buildTransactionCard(transaction, category),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterType == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filterType = value);
      },
      backgroundColor: Colors.white.withOpacity(0.2),
      selectedColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : Colors.white,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildTransactionCard(Transaction transaction, category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _editTransaction(transaction),
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: transaction.type == 'income'
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            child: Icon(
              category.icon,
              color: transaction.type == 'income'
                  ? Colors.green.shade700
                  : Colors.red.shade700,
            ),
          ),
          title: Text(
            transaction.title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                '${category.name} • ${DateFormat('MMM dd, yyyy').format(transaction.date)}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              if (transaction.note != null && transaction.note!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  transaction.note!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
          trailing: Text(
            transaction.type == 'income'
                ? '+\$${transaction.amount.toStringAsFixed(2)}'
                : '-\$${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: transaction.type == 'income'
                  ? Colors.green.shade700
                  : Colors.red.shade700,
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(
      BuildContext context, Transaction transaction) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content:
            Text('Are you sure you want to delete "${transaction.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _editTransaction(Transaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTransactionScreen(transaction: transaction),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sort by',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date'),
              trailing: _sortBy == 'date'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                setState(() => _sortBy = 'date');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Amount'),
              trailing: _sortBy == 'amount'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                setState(() => _sortBy = 'amount');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.title),
              title: const Text('Title'),
              trailing: _sortBy == 'title'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                setState(() => _sortBy = 'title');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
