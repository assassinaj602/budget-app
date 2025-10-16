import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/category.dart';
import '../models/transaction.dart';
import '../providers/app_provider.dart';

class EnhancedAddTransactionForm extends ConsumerStatefulWidget {
  const EnhancedAddTransactionForm({super.key});

  @override
  ConsumerState<EnhancedAddTransactionForm> createState() =>
      _EnhancedAddTransactionFormState();
}

class _EnhancedAddTransactionFormState
    extends ConsumerState<EnhancedAddTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _selectedType; // null = None, 'income' or 'expense'
  Category? _selectedCategory;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  List<Category> get _filteredCategories {
    final state = ref.watch(appProvider);
    if (_selectedType == null) return [];

    return state.categories.where((cat) {
      if (_selectedType == 'income') {
        return cat.id.contains('income') ||
            cat.id.contains('salary') ||
            cat.id.contains('gift');
      } else {
        return !cat.id.contains('income') &&
            !cat.id.contains('salary') &&
            !cat.id.contains('gift');
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.05),
            Colors.white,
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.add_circle_outline,
                      color: Theme.of(context).primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Transaction',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          'Track your income and expenses',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Transaction Type Selection
              Text(
                'Transaction Type *',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTypeButton(
                      label: 'None',
                      icon: Icons.remove_circle_outline,
                      color: Colors.grey,
                      isSelected: _selectedType == null,
                      onTap: () {
                        setState(() {
                          _selectedType = null;
                          _selectedCategory = null;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeButton(
                      label: 'Income',
                      icon: Icons.arrow_downward,
                      color: Colors.green,
                      isSelected: _selectedType == 'income',
                      onTap: () {
                        setState(() {
                          _selectedType = 'income';
                          _selectedCategory = null;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeButton(
                      label: 'Expense',
                      icon: Icons.arrow_upward,
                      color: Colors.red,
                      isSelected: _selectedType == 'expense',
                      onTap: () {
                        setState(() {
                          _selectedType = 'expense';
                          _selectedCategory = null;
                        });
                      },
                    ),
                  ),
                ],
              ),

              if (_selectedType == null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.orange.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Select Income or Expense to add a transaction',
                          style: TextStyle(
                            color: Colors.orange.shade900,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Amount Field
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                ],
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'Amount *',
                  labelStyle:
                      TextStyle(fontSize: 15, color: Colors.grey.shade700),
                  prefixIcon: Icon(Icons.attach_money,
                      color: Theme.of(context).primaryColor),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: Theme.of(context).primaryColor, width: 2),
                  ),
                ),
                validator: (value) {
                  if (_selectedType != null &&
                      (value == null || value.isEmpty)) {
                    return 'Please enter an amount';
                  }
                  if (_selectedType != null &&
                      double.tryParse(value!) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Title Field
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Title *',
                  labelStyle:
                      TextStyle(fontSize: 15, color: Colors.grey.shade700),
                  prefixIcon:
                      Icon(Icons.title, color: Theme.of(context).primaryColor),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: Theme.of(context).primaryColor, width: 2),
                  ),
                ),
                validator: (value) {
                  if (_selectedType != null &&
                      (value == null || value.isEmpty)) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Category Selection
              if (_selectedType != null) ...[
                Text(
                  'Category *',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _filteredCategories.map((category) {
                    final isSelected = _selectedCategory?.id == category.id;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? category.color.withOpacity(0.2)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? category.color
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              category.icon,
                              color: isSelected
                                  ? category.color
                                  : Colors.grey.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              category.name,
                              style: TextStyle(
                                color: isSelected
                                    ? category.color
                                    : Colors.grey.shade700,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (_selectedCategory == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Please select a category',
                      style:
                          TextStyle(color: Colors.red.shade700, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 20),
              ],

              // Date Picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.calendar_today,
                      color: Theme.of(context).primaryColor),
                ),
                title: Text(
                  'Date',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                subtitle: Text(
                  DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                trailing: TextButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDate = date;
                      });
                    }
                  },
                  child: const Text('Change'),
                ),
              ),

              const SizedBox(height: 12),

              // Notes Field
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  labelStyle:
                      TextStyle(fontSize: 15, color: Colors.grey.shade700),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(bottom: 50),
                    child:
                        Icon(Icons.note, color: Theme.of(context).primaryColor),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: Theme.of(context).primaryColor, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed:
                          _selectedType == null ? null : _saveTransaction,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                        disabledBackgroundColor: Colors.grey.shade300,
                        elevation: 0,
                      ),
                      child: Text(
                        _selectedType == null
                            ? 'Select Type First'
                            : 'Add Transaction',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey.shade600,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveTransaction() {
    // Don't save if type is null
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select transaction type (Income or Expense)'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        category: _selectedCategory!.id,
        date: _selectedDate,
        type: _selectedType!,
      );

      ref.read(appProvider.notifier).addTransaction(transaction);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${_selectedType == 'income' ? 'Income' : 'Expense'} added successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
