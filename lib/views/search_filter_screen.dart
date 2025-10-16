import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../providers/app_provider.dart';

class SearchFilterScreen extends ConsumerStatefulWidget {
  const SearchFilterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends ConsumerState<SearchFilterScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedType = 'all'; // 'all', 'income', 'expense'
  String _selectedCategory = 'all';
  DateTimeRange? _dateRange;
  double? _minAmount;
  double? _maxAmount;
  String _sortBy =
      'date_desc'; // 'date_asc', 'date_desc', 'amount_asc', 'amount_desc'

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);
    final filteredTransactions = _applyFilters(state.transactions);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search & Filter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_off),
            onPressed: _clearFilters,
            tooltip: 'Clear Filters',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip(
                  'Type',
                  Icons.category,
                  () => _showTypeFilterDialog(),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Category',
                  Icons.label,
                  () => _showCategoryFilterDialog(),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Date Range',
                  Icons.date_range,
                  () => _showDateRangeDialog(),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Amount',
                  Icons.attach_money,
                  () => _showAmountFilterDialog(),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Sort',
                  Icons.sort,
                  () => _showSortDialog(),
                ),
              ],
            ),
          ),

          // Active Filters Display
          if (_hasActiveFilters())
            Container(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _buildActiveFilterChips(),
              ),
            ),

          const Divider(),

          // Results Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '${filteredTransactions.length} results found',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          // Transaction List
          Expanded(
            child: filteredTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions found',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredTransactions.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final transaction = filteredTransactions[index];
                      return _buildTransactionCard(transaction);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Chip(
        avatar: Icon(icon, size: 18),
        label: Text(label),
        backgroundColor: Colors.indigo.shade50,
      ),
    );
  }

  List<Widget> _buildActiveFilterChips() {
    List<Widget> chips = [];

    if (_selectedType != 'all') {
      chips.add(Chip(
        label: Text('Type: ${_selectedType.toUpperCase()}'),
        deleteIcon: const Icon(Icons.close, size: 18),
        onDeleted: () => setState(() => _selectedType = 'all'),
      ));
    }

    if (_selectedCategory != 'all') {
      chips.add(Chip(
        label: Text('Category: $_selectedCategory'),
        deleteIcon: const Icon(Icons.close, size: 18),
        onDeleted: () => setState(() => _selectedCategory = 'all'),
      ));
    }

    if (_dateRange != null) {
      chips.add(Chip(
        label: Text(
          'Date: ${DateFormat('MMM d').format(_dateRange!.start)} - ${DateFormat('MMM d').format(_dateRange!.end)}',
        ),
        deleteIcon: const Icon(Icons.close, size: 18),
        onDeleted: () => setState(() => _dateRange = null),
      ));
    }

    if (_minAmount != null || _maxAmount != null) {
      chips.add(Chip(
        label: Text(
          'Amount: \$${_minAmount ?? 0} - \$${_maxAmount ?? '∞'}',
        ),
        deleteIcon: const Icon(Icons.close, size: 18),
        onDeleted: () => setState(() {
          _minAmount = null;
          _maxAmount = null;
        }),
      ));
    }

    return chips;
  }

  Widget _buildTransactionCard(Transaction transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: transaction.type == 'income'
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            transaction.type == 'income'
                ? Icons.arrow_downward
                : Icons.arrow_upward,
            color: transaction.type == 'income' ? Colors.green : Colors.red,
          ),
        ),
        title: Text(transaction.title),
        subtitle: Text(
          '${transaction.category} • ${DateFormat('MMM d, yyyy').format(transaction.date)}',
        ),
        trailing: Text(
          '${transaction.type == 'income' ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: transaction.type == 'income' ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  bool _hasActiveFilters() {
    return _selectedType != 'all' ||
        _selectedCategory != 'all' ||
        _dateRange != null ||
        _minAmount != null ||
        _maxAmount != null;
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedType = 'all';
      _selectedCategory = 'all';
      _dateRange = null;
      _minAmount = null;
      _maxAmount = null;
      _sortBy = 'date_desc';
    });
  }

  List<Transaction> _applyFilters(List<Transaction> transactions) {
    List<Transaction> filtered = transactions;

    // Search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered
          .where((t) =>
              t.title.toLowerCase().contains(query) ||
              t.category.toLowerCase().contains(query) ||
              (t.note?.toLowerCase().contains(query) ?? false))
          .toList();
    }

    // Type filter
    if (_selectedType != 'all') {
      filtered = filtered.where((t) => t.type == _selectedType).toList();
    }

    // Category filter
    if (_selectedCategory != 'all') {
      filtered =
          filtered.where((t) => t.category == _selectedCategory).toList();
    }

    // Date range filter
    if (_dateRange != null) {
      filtered = filtered
          .where((t) =>
              t.date.isAfter(
                  _dateRange!.start.subtract(const Duration(days: 1))) &&
              t.date.isBefore(_dateRange!.end.add(const Duration(days: 1))))
          .toList();
    }

    // Amount filter
    if (_minAmount != null) {
      filtered = filtered.where((t) => t.amount >= _minAmount!).toList();
    }
    if (_maxAmount != null) {
      filtered = filtered.where((t) => t.amount <= _maxAmount!).toList();
    }

    // Sort
    switch (_sortBy) {
      case 'date_asc':
        filtered.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'date_desc':
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'amount_asc':
        filtered.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case 'amount_desc':
        filtered.sort((a, b) => b.amount.compareTo(a.amount));
        break;
    }

    return filtered;
  }

  void _showTypeFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('All'),
              value: 'all',
              groupValue: _selectedType,
              onChanged: (value) {
                setState(() => _selectedType = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Income'),
              value: 'income',
              groupValue: _selectedType,
              onChanged: (value) {
                setState(() => _selectedType = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Expense'),
              value: 'expense',
              groupValue: _selectedType,
              onChanged: (value) {
                setState(() => _selectedType = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryFilterDialog() {
    final categories = ref.read(appProvider).categories;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('All Categories'),
                value: 'all',
                groupValue: _selectedCategory,
                onChanged: (value) {
                  setState(() => _selectedCategory = value!);
                  Navigator.pop(context);
                },
              ),
              ...categories.map((category) => RadioListTile<String>(
                    title: Text(category.name),
                    value: category.name,
                    groupValue: _selectedCategory,
                    onChanged: (value) {
                      setState(() => _selectedCategory = value!);
                      Navigator.pop(context);
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDateRangeDialog() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  void _showAmountFilterDialog() {
    final minController =
        TextEditingController(text: _minAmount?.toString() ?? '');
    final maxController =
        TextEditingController(text: _maxAmount?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Amount'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: minController,
              decoration: const InputDecoration(
                labelText: 'Min Amount',
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: maxController,
              decoration: const InputDecoration(
                labelText: 'Max Amount',
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _minAmount = double.tryParse(minController.text);
                _maxAmount = double.tryParse(maxController.text);
              });
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort By'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Date (Newest First)'),
              value: 'date_desc',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() => _sortBy = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Date (Oldest First)'),
              value: 'date_asc',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() => _sortBy = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Amount (High to Low)'),
              value: 'amount_desc',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() => _sortBy = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Amount (Low to High)'),
              value: 'amount_asc',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() => _sortBy = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
