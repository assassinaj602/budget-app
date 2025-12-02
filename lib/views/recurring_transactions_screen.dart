import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_provider.dart';
import '../models/recurring_transaction.dart';
import '../models/category.dart';
import '../views/widgets/custom_snackbar.dart';
import 'package:intl/intl.dart';

class RecurringTransactionsScreen extends ConsumerStatefulWidget {
  const RecurringTransactionsScreen({super.key});

  @override
  ConsumerState<RecurringTransactionsScreen> createState() =>
      _RecurringTransactionsScreenState();
}

class _RecurringTransactionsScreenState
    extends ConsumerState<RecurringTransactionsScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);
    final recurringTransactions = state.recurringTransactions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Transactions'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddRecurringSheet(context),
        icon: const Icon(Icons.repeat),
        label: const Text('Add Recurring'),
      ),
      body: recurringTransactions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.repeat, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No recurring transactions',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add monthly bills, subscriptions, or regular income',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: recurringTransactions.length,
              itemBuilder: (context, index) {
                final recurring = recurringTransactions[index];
                return _buildRecurringCard(context, recurring);
              },
            ),
    );
  }

  Widget _buildRecurringCard(
      BuildContext context, RecurringTransaction recurring) {
    final category = _getCategoryForTransaction(recurring);
    final color = recurring.type == 'income' ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showRecurringDetails(context, recurring),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  category?.icon ?? Icons.repeat,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recurring.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.category,
                            size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            recurring.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.repeat,
                            size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          _getFrequencyText(recurring.frequency),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    if (recurring.nextDueDate != null)
                      const SizedBox(height: 4),
                    if (recurring.nextDueDate != null)
                      Row(
                        children: [
                          Icon(Icons.event,
                              size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            'Next: ${DateFormat('MMM dd, yyyy').format(recurring.nextDueDate!)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${recurring.type == 'income' ? '+' : '-'}\$${recurring.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: recurring.isActive
                          ? Colors.green.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      recurring.isActive ? 'Active' : 'Paused',
                      style: TextStyle(
                        fontSize: 10,
                        color: recurring.isActive ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.w600,
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

  Category? _getCategoryForTransaction(RecurringTransaction recurring) {
    final state = ref.watch(appProvider);
    try {
      return state.categories
          .firstWhere((cat) => cat.name == recurring.category);
    } catch (e) {
      return null;
    }
  }

  String _getFrequencyText(RecurrenceFrequency frequency) {
    switch (frequency) {
      case RecurrenceFrequency.daily:
        return 'Daily';
      case RecurrenceFrequency.weekly:
        return 'Weekly';
      case RecurrenceFrequency.biweekly:
        return 'Bi-weekly';
      case RecurrenceFrequency.monthly:
        return 'Monthly';
      case RecurrenceFrequency.quarterly:
        return 'Quarterly';
      case RecurrenceFrequency.yearly:
        return 'Yearly';
    }
  }

  void _showRecurringDetails(
      BuildContext context, RecurringTransaction recurring) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  recurring.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            _buildDetailRow(
                'Amount', '\$${recurring.amount.toStringAsFixed(2)}'),
            _buildDetailRow(
                'Type', recurring.type == 'income' ? 'Income' : 'Expense'),
            _buildDetailRow('Category', recurring.category),
            _buildDetailRow(
                'Frequency', _getFrequencyText(recurring.frequency)),
            if (recurring.nextDueDate != null)
              _buildDetailRow('Next occurrence',
                  DateFormat('MMM dd, yyyy').format(recurring.nextDueDate!)),
            if (recurring.note != null && recurring.note!.isNotEmpty)
              _buildDetailRow('Note', recurring.note!),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _toggleRecurringStatus(recurring);
                    },
                    icon: Icon(
                        recurring.isActive ? Icons.pause : Icons.play_arrow),
                    label: Text(recurring.isActive ? 'Pause' : 'Resume'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteRecurring(recurring);
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleRecurringStatus(RecurringTransaction recurring) {
    final updated = RecurringTransaction(
      id: recurring.id,
      title: recurring.title,
      amount: recurring.amount,
      category: recurring.category,
      type: recurring.type,
      frequency: recurring.frequency,
      startDate: recurring.startDate,
      endDate: recurring.endDate,
      lastGenerated: recurring.lastGenerated,
      isActive: !recurring.isActive,
      note: recurring.note,
    );

    ref.read(appProvider.notifier).updateRecurringTransaction(updated);

    CustomSnackBar.show(
      context,
      message: updated.isActive
          ? 'Recurring transaction resumed'
          : 'Recurring transaction paused',
      type: SnackBarType.success,
    );
  }

  void _deleteRecurring(RecurringTransaction recurring) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recurring Transaction'),
        content: Text(
            'Are you sure you want to delete "${recurring.title}"? This will not affect existing transactions.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(appProvider.notifier)
                  .deleteRecurringTransaction(recurring.id);
              Navigator.pop(context);
              CustomSnackBar.show(
                context,
                message: 'Recurring transaction deleted',
                type: SnackBarType.success,
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddRecurringDialog(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    String selectedType = 'expense';
    String selectedCategory = 'Food';
    RecurrenceFrequency selectedFrequency = RecurrenceFrequency.monthly;
    DateTime startDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Recurring Transaction'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'e.g., Netflix Subscription',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '\$ ',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(value: 'expense', child: Text('Expense')),
                    DropdownMenuItem(value: 'income', child: Text('Income')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: const [
                    DropdownMenuItem(value: 'Food', child: Text('Food')),
                    DropdownMenuItem(
                        value: 'Transportation', child: Text('Transportation')),
                    DropdownMenuItem(
                        value: 'Entertainment', child: Text('Entertainment')),
                    DropdownMenuItem(value: 'Bills', child: Text('Bills')),
                    DropdownMenuItem(value: 'Salary', child: Text('Salary')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedCategory = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<RecurrenceFrequency>(
                  value: selectedFrequency,
                  decoration: const InputDecoration(labelText: 'Frequency'),
                  items: const [
                    DropdownMenuItem(
                        value: RecurrenceFrequency.daily, child: Text('Daily')),
                    DropdownMenuItem(
                        value: RecurrenceFrequency.weekly,
                        child: Text('Weekly')),
                    DropdownMenuItem(
                        value: RecurrenceFrequency.monthly,
                        child: Text('Monthly')),
                    DropdownMenuItem(
                        value: RecurrenceFrequency.yearly,
                        child: Text('Yearly')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedFrequency = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Start Date'),
                  subtitle: Text(DateFormat('MMM dd, yyyy').format(startDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setDialogState(() => startDate = picked);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: 'Note (Optional)',
                    hintText: 'Add a note',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isEmpty ||
                    amountController.text.isEmpty) {
                  CustomSnackBar.show(
                    context,
                    message: 'Please fill in all required fields',
                    type: SnackBarType.error,
                  );
                  return;
                }

                final recurring = RecurringTransaction(
                  id: DateTime.now().toString(),
                  title: titleController.text,
                  amount: double.parse(amountController.text),
                  category: selectedCategory,
                  type: selectedType,
                  frequency: selectedFrequency,
                  startDate: startDate,
                  isActive: true,
                  note:
                      noteController.text.isEmpty ? null : noteController.text,
                );

                ref
                    .read(appProvider.notifier)
                    .addRecurringTransaction(recurring);

                Navigator.pop(context);
                CustomSnackBar.show(
                  context,
                  message: 'Recurring transaction added!',
                  type: SnackBarType.success,
                );
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddRecurringSheet(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    String selectedType = 'expense';
    String selectedCategory = 'Food';
    RecurrenceFrequency selectedFrequency = RecurrenceFrequency.monthly;
    DateTime startDate = DateTime.now();

    // Use the same standardized bottom sheet wrapper for visual consistency
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.85,
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: StatefulBuilder(
              builder: (context, setSheetState) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                          foregroundColor: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Add Recurring Transaction',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: titleController,
                            decoration: const InputDecoration(
                              labelText: 'Title',
                              prefixIcon: Icon(Icons.title),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: amountController,
                            decoration: const InputDecoration(
                              labelText: 'Amount',
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: selectedType,
                            decoration: const InputDecoration(labelText: 'Type'),
                            items: const [
                              DropdownMenuItem(value: 'expense', child: Text('Expense')),
                              DropdownMenuItem(value: 'income', child: Text('Income')),
                            ],
                            onChanged: (v) {
                              if (v != null) setSheetState(() => selectedType = v);
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: selectedCategory,
                            decoration: const InputDecoration(labelText: 'Category'),
                            items: const [
                              DropdownMenuItem(value: 'Food', child: Text('Food')),
                              DropdownMenuItem(value: 'Transportation', child: Text('Transportation')),
                              DropdownMenuItem(value: 'Entertainment', child: Text('Entertainment')),
                              DropdownMenuItem(value: 'Bills', child: Text('Bills')),
                              DropdownMenuItem(value: 'Salary', child: Text('Salary')),
                              DropdownMenuItem(value: 'Other', child: Text('Other')),
                            ],
                            onChanged: (v) {
                              if (v != null) setSheetState(() => selectedCategory = v);
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<RecurrenceFrequency>(
                            value: selectedFrequency,
                            decoration: const InputDecoration(labelText: 'Frequency'),
                            items: const [
                              DropdownMenuItem(value: RecurrenceFrequency.daily, child: Text('Daily')),
                              DropdownMenuItem(value: RecurrenceFrequency.weekly, child: Text('Weekly')),
                              DropdownMenuItem(value: RecurrenceFrequency.monthly, child: Text('Monthly')),
                              DropdownMenuItem(value: RecurrenceFrequency.yearly, child: Text('Yearly')),
                            ],
                            onChanged: (v) {
                              if (v != null) setSheetState(() => selectedFrequency = v);
                            },
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Start Date'),
                            subtitle: Text(DateFormat('MMM dd, yyyy').format(startDate)),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: ctx,
                                initialDate: startDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) setSheetState(() => startDate = picked);
                            },
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: noteController,
                            decoration: const InputDecoration(
                              labelText: 'Note (Optional)',
                              prefixIcon: Icon(Icons.note),
                            ),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (titleController.text.isEmpty || amountController.text.isEmpty) {
                          CustomSnackBar.show(
                            ctx,
                            message: 'Please fill in title and amount',
                            type: SnackBarType.error,
                          );
                          return;
                        }
                        final recurring = RecurringTransaction(
                          id: DateTime.now().toString(),
                          title: titleController.text,
                          amount: double.tryParse(amountController.text) ?? 0.0,
                          category: selectedCategory,
                          type: selectedType,
                          frequency: selectedFrequency,
                          startDate: startDate,
                          isActive: true,
                          note: noteController.text.isEmpty ? null : noteController.text,
                        );
                        ref.read(appProvider.notifier).addRecurringTransaction(recurring);
                        Navigator.pop(ctx);
                        CustomSnackBar.show(
                          context,
                          message: 'Recurring transaction added!',
                          type: SnackBarType.success,
                        );
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Add Recurring'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
