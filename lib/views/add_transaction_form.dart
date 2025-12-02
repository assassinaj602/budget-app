import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/category.dart';
import '../models/transaction.dart';
import '../models/transaction_template.dart';
import '../providers/app_provider.dart';
import 'widgets/custom_snackbar.dart';

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
  late final _debouncer = _Debouncer(const Duration(milliseconds: 250));

  DateTime _selectedDate = DateTime.now();
  String _selectedType = 'expense';
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
  void dispose() {
    _debouncer.dispose();
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fieldFill = isDark ? cs.surfaceVariant : Colors.grey.shade50;
    final borderColor = isDark ? cs.outlineVariant : Colors.grey.shade300;
    final focusColor = _selectedType == 'income'
        ? Colors.green.shade600
        : Colors.red.shade600;
    final textColor = cs.onSurface;

    return Center(
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
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Transaction Title',
                    hintText: 'e.g., Grocery shopping, Salary',
                    labelStyle: TextStyle(color: cs.onSurfaceVariant),
                    hintStyle:
                        TextStyle(color: cs.onSurfaceVariant.withOpacity(0.8)),
                    prefixIcon: Icon(Icons.edit, color: cs.onSurfaceVariant),
                    filled: true,
                    fillColor: fieldFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: focusColor, width: 2),
                    ),
                  ),
                  style: TextStyle(color: textColor),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter a title' : null,
                ),

                const SizedBox(height: 20),

                // Amount Field
                TextFormField(
                  controller: _amountController,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    _TwoDecimalTextInputFormatter(),
                  ],
                  onChanged: (v) => _debouncer.run(() => setState(() {})),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    hintText: '0.00',
                    labelStyle: TextStyle(color: cs.onSurfaceVariant),
                    hintStyle:
                        TextStyle(color: cs.onSurfaceVariant.withOpacity(0.8)),
                    prefixIcon: Icon(
                      _selectedType == 'income'
                          ? Icons.add_circle
                          : Icons.remove_circle,
                      color: focusColor,
                    ),
                    prefixText: '\$ ',
                    filled: true,
                    fillColor: fieldFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: focusColor, width: 2),
                    ),
                  ),
                  style: TextStyle(color: textColor),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Please enter an amount';
                    if (double.tryParse(value!) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),
                // Category Selection (Autocomplete)
                Autocomplete<Category>(
                  initialValue: _selectedCategory != null
                      ? TextEditingValue(text: _selectedCategory!.name)
                      : const TextEditingValue(text: ''),
                  displayStringForOption: (c) => c.name,
                  optionsBuilder: (TextEditingValue text) {
                    final query = text.text.toLowerCase();
                    return categories.where(
                      (c) => c.name.toLowerCase().contains(query),
                    );
                  },
                  onSelected: (c) => setState(() => _selectedCategory = c),
                  fieldViewBuilder: (
                    context,
                    textController,
                    focusNode,
                    onFieldSubmitted,
                  ) {
                    return TextFormField(
                      controller: textController,
                      focusNode: focusNode,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        hintText: 'Search or select category',
                        labelStyle: TextStyle(color: cs.onSurfaceVariant),
                        hintStyle: TextStyle(
                            color: cs.onSurfaceVariant.withOpacity(0.8)),
                        prefixIcon:
                            Icon(Icons.category, color: cs.onSurfaceVariant),
                        filled: true,
                        fillColor: fieldFill,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: focusColor, width: 2),
                        ),
                      ),
                      validator: (_) =>
                          _selectedCategory == null
                              ? 'Please select a category'
                              : null,
                      onFieldSubmitted: (_) => onFieldSubmitted(),
                      onChanged: (v) => _debouncer.run(() => setState(() {})),
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(12),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 240),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final c = options.elementAt(index);
                              return ListTile(
                                leading: Icon(c.icon),
                                title: Text(c.name),
                                onTap: () => onSelected(c),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Date Selection
                InkWell(
                  onTap: () async {
                    await showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24)),
                      ),
                      builder: (ctx) {
                        DateTime temp = _selectedDate;
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CalendarDatePicker(
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
                                initialDate: _selectedDate,
                                onDateChanged: (d) => temp = d,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Cancel'),
                                  ),
                                  const Spacer(),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() => _selectedDate = temp);
                                      Navigator.pop(ctx);
                                    },
                                    child: const Text('Select'),
                                  )
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: fieldFill,
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: cs.onSurfaceVariant),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date',
                              style: TextStyle(
                                fontSize: 12,
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('MMMM dd, yyyy').format(_selectedDate),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Icon(Icons.edit, color: cs.onSurfaceVariant, size: 20),
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
                    labelStyle: TextStyle(color: cs.onSurfaceVariant),
                    hintStyle:
                        TextStyle(color: cs.onSurfaceVariant.withOpacity(0.8)),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(bottom: 60),
                      child: Icon(Icons.note_add, color: cs.onSurfaceVariant),
                    ),
                    filled: true,
                    fillColor: fieldFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: focusColor, width: 2),
                    ),
                  ),
                  style: TextStyle(color: textColor),
                ),

                const SizedBox(height: 20),

                // Save as Template button
                ValueListenableBuilder(
                  valueListenable: _titleController,
                  builder: (context, _, __) {
                    final canSaveTemplate =
                        _titleController.text.trim().isNotEmpty &&
                            _amountController.text.trim().isNotEmpty &&
                            _selectedCategory != null;
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            canSaveTemplate ? _showSaveTemplateDialog : null,
                        icon: const Icon(Icons.save),
                        label: const Text('Save as Template'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              canSaveTemplate ? cs.primary : Colors.grey.shade400,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                ValueListenableBuilder(
                  valueListenable: _titleController,
                  builder: (context, _, __) {
                    final isEnabled = _titleController.text.trim().isNotEmpty &&
                        _amountController.text.trim().isNotEmpty &&
                        _selectedCategory != null;
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isEnabled ? focusColor : Colors.grey.shade400,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: isEnabled ? 2 : 0,
                      ),
                      onPressed: isEnabled && !_isSubmitting
                          ? () async {
                              final formState = _formKey.currentState;
                              if (formState != null && formState.validate()) {
                                setState(() => _isSubmitting = true);
                                final navigator = Navigator.of(context);
                                double? amount;
                                try {
                                  amount = double.parse(_amountController.text);
                                } catch (_) {
                                  setState(() => _isSubmitting = false);
                                  CustomSnackBar.show(
                                    context,
                                    message: 'Please enter a valid amount',
                                    type: SnackBarType.error,
                                  );
                                  return;
                                }

                                try {
                                  await ref.read(appProvider.notifier).addTransaction(
                                        Transaction(
                                          id: DateTime.now().toString(),
                                          title: _titleController.text,
                                          amount: amount,
                                          date: _selectedDate,
                                          category:
                                              _selectedCategory?.name ?? 'Uncategorized',
                                          type: _selectedType,
                                          note: _noteController.text.isEmpty
                                              ? null
                                              : _noteController.text,
                                        ),
                                      );

                                  if (!mounted) return;
                                  navigator.pop();
                                  CustomSnackBar.show(
                                      context,
                                      message:
                                          '${_selectedType == "income" ? "Income" : "Expense"} added successfully!',
                                      type: SnackBarType.success,
                                    );
                                } catch (e) {
                                  setState(() => _isSubmitting = false);
                                  if (mounted) {
                                    CustomSnackBar.show(
                                      context,
                                      message:
                                          'Failed to add transaction. Please try again.',
                                      type: SnackBarType.error,
                                    );
                                  }
                                }
                              }
                            }
                          : null,
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Row(
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
        ),
      ),
    );
  }

  void _showSaveTemplateDialog() {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) {
      CustomSnackBar.show(
        context,
        message: 'Fill in the form before saving as template',
        type: SnackBarType.warning,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save as Template'),
        content: Text(
          'Save "${_titleController.text}" as a quick template?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final notifier = ref.read(appProvider.notifier);
              await notifier.addTemplate(
                TransactionTemplate(
                  title: _titleController.text,
                  amount: double.tryParse(_amountController.text) ?? 0,
                  category: _selectedCategory?.name ?? 'Other',
                  type: _selectedType,
                  note: _noteController.text.isEmpty
                      ? null
                      : _noteController.text,
                ),
              );

              if (mounted) {
                Navigator.pop(context);
                CustomSnackBar.show(
                  context,
                  message: 'Template saved!',
                  type: SnackBarType.success,
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _Debouncer {
  final Duration delay;
  Timer? _timer;
  _Debouncer(this.delay);
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }
  void dispose() => _timer?.cancel();
}

class _TwoDecimalTextInputFormatter extends TextInputFormatter {
  final RegExp _reg = RegExp(r'^\d*\.?\d{0,2}$');
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    if (_reg.hasMatch(text)) return newValue;
    return oldValue;
  }
}

extension StringExtension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}
