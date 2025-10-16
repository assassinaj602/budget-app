import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/category.dart';
import '../models/transaction.dart';
import '../providers/app_provider.dart';

class AddTransactionForm extends ConsumerStatefulWidget {
  const AddTransactionForm({super.key});

  @override
  ConsumerState<AddTransactionForm> createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends ConsumerState<AddTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedType = 'expense';
  Category? _selectedCategory;

  // Category list as a class field
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
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                      onTap: () => setState(() => _selectedType = 'expense'),
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
                      onTap: () => setState(() => _selectedType = 'income'),
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
                hintText: 'e.g., Grocery shopping, Salary',
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
                hintText: '0.00',
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
                if (value?.isEmpty ?? true) return 'Please enter an amount';
                if (double.tryParse(value!) == null)
                  return 'Please enter a valid number';
                return null;
              },
            ),

            const SizedBox(height: 20),
            // Category Selection
            DropdownButtonFormField<Category>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                hintText: 'Choose a category',
                prefixIcon: Icon(Icons.category, color: Colors.grey.shade600),
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
              items: [
                ...categories.map((category) => DropdownMenuItem<Category>(
                      key: ValueKey(category.id),
                      value: category,
                      child: Row(
                        children: [
                          Icon(category.icon),
                          const SizedBox(width: 8),
                          Text(category.name),
                        ],
                      ),
                    )),
              ],
              onChanged: (value) async {
                if (value == null) {
                  // Show dialog to add new category
                  final newCategory = await showDialog<Category>(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (context, setState) {
                          final catNameController = TextEditingController();
                          IconData? selectedIcon;
                          return AlertDialog(
                            title: const Text('Add Category'),
                            content: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: catNameController,
                                    decoration: const InputDecoration(
                                        labelText: 'Category Name'),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      for (final icon in [
                                        Icons.restaurant,
                                        Icons.directions_car,
                                        Icons.shopping_bag,
                                        Icons.receipt,
                                        Icons.money_off,
                                        Icons.attach_money,
                                        Icons.card_giftcard,
                                        Icons.monetization_on,
                                      ])
                                        GestureDetector(
                                          onTap: () => setState(
                                              () => selectedIcon = icon),
                                          child: CircleAvatar(
                                            backgroundColor:
                                                selectedIcon == icon
                                                    ? Colors.indigo
                                                    : Colors.grey.shade200,
                                            child: Icon(icon,
                                                color: selectedIcon == icon
                                                    ? Colors.white
                                                    : Colors.black),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  catNameController.dispose();
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  final name = catNameController.text.trim();
                                  if (name.isEmpty || selectedIcon == null)
                                    return;
                                  final exists = categories.any((cat) =>
                                      cat.name.toLowerCase() ==
                                      name.toLowerCase());
                                  if (exists) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Category already exists.')),
                                    );
                                    return;
                                  }
                                  final cat = Category.withIconAndColor(
                                    id: name.toLowerCase().replaceAll(' ', '_'),
                                    name: name,
                                    icon: selectedIcon!,
                                    color: Colors.grey,
                                  );
                                  catNameController.dispose();
                                  Navigator.pop(context, cat);
                                },
                                child: const Text('Add'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                  if (newCategory != null) {
                    setState(() {
                      categories.add(newCategory);
                      _selectedCategory = newCategory;
                    });
                  }
                } else {
                  setState(() => _selectedCategory = value);
                }
              },
              validator: (value) =>
                  value == null ? 'Please select a category' : null,
            ),

            const SizedBox(height: 20),

            // Date Selection
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.grey.shade600),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('MMMM dd, yyyy').format(_selectedDate),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Icon(Icons.edit, color: Colors.grey.shade400, size: 20),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Notes Field
            TextFormField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Add any additional details...',
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 60),
                  child: Icon(Icons.note_add, color: Colors.grey.shade600),
                ),
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
            ValueListenableBuilder(
              valueListenable: _titleController,
              builder: (context, _, __) {
                final isEnabled = _titleController.text.trim().isNotEmpty &&
                    _amountController.text.trim().isNotEmpty &&
                    _selectedCategory != null;
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEnabled
                        ? (_selectedType == 'income'
                            ? Colors.green.shade600
                            : Colors.red.shade600)
                        : Colors.grey.shade400,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: isEnabled ? 2 : 0,
                  ),
                  onPressed: isEnabled
                      ? () {
                          // Check for null before using _formKey.currentState
                          final formState = _formKey.currentState;
                          if (formState != null && formState.validate()) {
                            double? amount;
                            try {
                              amount = double.parse(_amountController.text);
                            } catch (_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Enter a valid amount.')),
                              );
                              return;
                            }
                            ref.read(appProvider.notifier).addTransaction(
                                  Transaction(
                                    id: DateTime.now().toString(),
                                    title: _titleController.text,
                                    amount: amount,
                                    date: _selectedDate,
                                    category: _selectedCategory?.name ??
                                        'Uncategorized',
                                    type: _selectedType,
                                    note: _noteController.text,
                                  ),
                                );
                            Navigator.pop(context);
                          }
                        }
                      : null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _selectedType == 'income'
                            ? Icons.add_circle_outline
                            : Icons.remove_circle_outline,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Add ${_selectedType == 'income' ? 'Income' : 'Expense'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
    );
  }
}

extension StringExtension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}
