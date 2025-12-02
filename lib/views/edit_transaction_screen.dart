import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/category.dart';
import '../models/transaction.dart';
import '../providers/app_provider.dart';
import 'widgets/custom_snackbar.dart';

class EditTransactionScreen extends ConsumerStatefulWidget {
  final Transaction transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  ConsumerState<EditTransactionScreen> createState() =>
      _EditTransactionScreenState();
}

class _EditTransactionScreenState extends ConsumerState<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late DateTime _selectedDate;
  late String _selectedType;
  Category? _selectedCategory;
  bool _isSubmitting = false;

  final List<Category> categories = [
    Category.withIconAndColor(
        id: 'food', name: 'Food', icon: Icons.restaurant, color: Colors.orange),
    Category.withIconAndColor(
        id: 'transport',
        name: 'Transport',
        icon: Icons.directions_car,
        color: Colors.purple),
    Category.withIconAndColor(
        id: 'shopping',
        name: 'Shopping',
        icon: Icons.shopping_bag,
        color: Colors.pink),
    Category.withIconAndColor(
        id: 'bills', name: 'Bills', icon: Icons.receipt, color: Colors.red),
    Category.withIconAndColor(
        id: 'other_expense',
        name: 'Other Expense',
        icon: Icons.money_off,
        color: Colors.grey),
    Category.withIconAndColor(
        id: 'salary',
        name: 'Salary',
        icon: Icons.attach_money,
        color: Colors.indigo),
    Category.withIconAndColor(
        id: 'gift',
        name: 'Gift',
        icon: Icons.card_giftcard,
        color: Colors.green),
    Category.withIconAndColor(
        id: 'other_income',
        name: 'Other Income',
        icon: Icons.monetization_on,
        color: Colors.blue),
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.transaction.title);
    _amountController =
        TextEditingController(text: widget.transaction.amount.toString());
    _noteController =
        TextEditingController(text: widget.transaction.note ?? '');
    _selectedDate = widget.transaction.date;
    _selectedType = widget.transaction.type;
    _selectedCategory = categories.firstWhere(
      (c) => c.name == widget.transaction.category,
      orElse: () => categories.first,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) {
      if (_selectedCategory == null) {
        CustomSnackBar.show(
          context,
          message: 'Please select a category',
          type: SnackBarType.error,
        );
      }
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final updatedTransaction = Transaction(
        id: widget.transaction.id,
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        category: _selectedCategory!.name,
        type: _selectedType,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );

      await ref
          .read(appProvider.notifier)
          .updateTransaction(updatedTransaction);

      if (mounted) {
        CustomSnackBar.show(
          context,
          message: 'Transaction updated successfully!',
          type: SnackBarType.success,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context,
          message: 'Failed to update transaction: $e',
          type: SnackBarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Transaction'),
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Transaction Type Toggle
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedType = 'expense'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedType == 'expense'
                                    ? Colors.red.shade600
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Expense',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _selectedType == 'expense'
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedType = 'income'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedType == 'income'
                                    ? Colors.green.shade600
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Income',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _selectedType == 'income'
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Title Field
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Transaction Title',
                      prefixIcon: Icon(Icons.edit, color: Colors.grey.shade600),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _selectedType == 'income'
                              ? Colors.green.shade600
                              : Colors.red.shade600,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Please enter a title' : null,
                  ),

                  const SizedBox(height: 20),

                  // Amount Field
                  TextFormField(
                    controller: _amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      prefixIcon: Icon(
                        _selectedType == 'income'
                            ? Icons.add_circle
                            : Icons.remove_circle,
                        color: _selectedType == 'income'
                            ? Colors.green.shade600
                            : Colors.red.shade600,
                      ),
                      prefixText: '\$ ',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _selectedType == 'income'
                              ? Colors.green.shade600
                              : Colors.red.shade600,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true)
                        return 'Please enter an amount';
                      if (double.tryParse(value!) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Category Selection
                  const Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: categories
                            .where((c) =>
                                (_selectedType == 'income' &&
                                    ['Salary', 'Gift', 'Other Income']
                                        .contains(c.name)) ||
                                (_selectedType == 'expense' &&
                                    [
                                      'Food',
                                      'Transport',
                                      'Shopping',
                                      'Bills',
                                      'Other Expense'
                                    ].contains(c.name)))
                            .map((category) => _buildCategoryChip(category))
                            .toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Date Picker
                  InkWell(
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              color: Colors.grey.shade600),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('MMM dd, yyyy').format(_selectedDate),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.arrow_drop_down,
                              color: Colors.grey.shade600),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Note Field
                  TextFormField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Note (Optional)',
                      hintText: 'Add any additional details...',
                      prefixIcon: Icon(Icons.note, color: Colors.grey.shade600),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _selectedType == 'income'
                              ? Colors.green.shade600
                              : Colors.red.shade600,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Update Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleUpdate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedType == 'income'
                            ? Colors.green.shade600
                            : Colors.red.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Update Transaction',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(Category category) {
    final isSelected = _selectedCategory?.id == category.id;
    return InkWell(
      onTap: () => setState(() => _selectedCategory = category),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? category.color.withOpacity(0.2)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? category.color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 18,
              color: isSelected ? category.color : Colors.grey.shade700,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                category.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? category.color : Colors.grey.shade700,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
