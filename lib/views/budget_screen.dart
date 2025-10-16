import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../domain/entities/budget_entity.dart';
import '../data/models/budget_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Budget Provider
final budgetsProvider =
    StateNotifierProvider<BudgetNotifier, List<BudgetEntity>>((ref) {
  return BudgetNotifier();
});

class BudgetNotifier extends StateNotifier<List<BudgetEntity>> {
  BudgetNotifier() : super([]) {
    _loadBudgets();
  }

  Future<void> _loadBudgets() async {
    try {
      final box = await Hive.openBox<BudgetModel>('budgets');
      state = box.values.map((model) => model.toEntity()).toList();
    } catch (e) {
      debugPrint('Error loading budgets: $e');
    }
  }

  Future<void> addBudget(BudgetEntity budget) async {
    try {
      final box = await Hive.openBox<BudgetModel>('budgets');
      await box.add(BudgetModel.fromEntity(budget));
      state = [...state, budget];
    } catch (e) {
      debugPrint('Error adding budget: $e');
    }
  }

  Future<void> updateBudget(BudgetEntity budget) async {
    try {
      final box = await Hive.openBox<BudgetModel>('budgets');
      final index = box.values.toList().indexWhere((b) => b.id == budget.id);
      if (index != -1) {
        await box.putAt(index, BudgetModel.fromEntity(budget));
        state = [
          for (final b in state)
            if (b.id == budget.id) budget else b
        ];
      }
    } catch (e) {
      debugPrint('Error updating budget: $e');
    }
  }

  Future<void> deleteBudget(String id) async {
    try {
      final box = await Hive.openBox<BudgetModel>('budgets');
      final key = box.keys.firstWhere(
        (k) => box.get(k)?.id == id,
        orElse: () => null,
      );
      if (key != null) {
        await box.delete(key);
        state = state.where((b) => b.id != id).toList();
      }
    } catch (e) {
      debugPrint('Error deleting budget: $e');
    }
  }
}

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetsProvider);
    final now = DateTime.now();
    final activeBudgets = budgets
        .where((b) =>
            now.isAfter(b.startDate.subtract(const Duration(days: 1))) &&
            now.isBefore(b.endDate.add(const Duration(days: 1))))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Goals'),
        elevation: 0,
      ),
      body: activeBudgets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance_wallet,
                      color: Colors.indigo.shade200, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'No budgets set',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create a budget to track your spending',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: activeBudgets.length,
              itemBuilder: (context, index) {
                return _BudgetCard(budget: activeBudgets[index]);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => const AddBudgetForm(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Budget'),
      ),
    );
  }
}

class _BudgetCard extends ConsumerWidget {
  final BudgetEntity budget;

  const _BudgetCard({required this.budget});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Calculate spent amount (you can connect this to actual transactions)
    final spent = _calculateSpent(ref);
    final percentage = (spent / budget.amount).clamp(0.0, 1.0);
    final remaining = budget.amount - spent;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        budget.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        budget.categoryId ?? 'Overall Budget',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    _showBudgetOptions(context, ref);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearPercentIndicator(
              lineHeight: 12,
              percent: percentage,
              backgroundColor: Colors.grey.shade200,
              progressColor: _getProgressColor(percentage),
              barRadius: const Radius.circular(6),
              animation: true,
              animationDuration: 1000,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spent',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${spent.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Remaining',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${remaining.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Budget',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${budget.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  '${DateFormat('MMM d').format(budget.startDate)} - ${DateFormat('MMM d, yyyy').format(budget.endDate)}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _calculateSpent(WidgetRef ref) {
    // TODO: Connect to actual transactions
    // For now, return a mock value
    return budget.amount * 0.6; // 60% spent
  }

  Color _getProgressColor(double percentage) {
    if (percentage < 0.5) return Colors.green;
    if (percentage < 0.8) return Colors.orange;
    return Colors.red;
  }

  void _showBudgetOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Budget'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show edit dialog
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Budget',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                ref.read(budgetsProvider.notifier).deleteBudget(budget.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AddBudgetForm extends ConsumerStatefulWidget {
  const AddBudgetForm({Key? key}) : super(key: key);

  @override
  ConsumerState<AddBudgetForm> createState() => _AddBudgetFormState();
}

class _AddBudgetFormState extends ConsumerState<AddBudgetForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String _period = 'monthly';
  String? _selectedCategory;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Create Budget',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Budget Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _period,
                decoration: const InputDecoration(
                  labelText: 'Period',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                items: const [
                  DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                  DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                  DropdownMenuItem(value: 'custom', child: Text('Custom')),
                ],
                onChanged: (value) {
                  setState(() {
                    _period = value!;
                    _updateEndDate();
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitBudget,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Create Budget'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateEndDate() {
    switch (_period) {
      case 'weekly':
        _endDate = _startDate.add(const Duration(days: 7));
        break;
      case 'monthly':
        _endDate =
            DateTime(_startDate.year, _startDate.month + 1, _startDate.day);
        break;
      case 'yearly':
        _endDate =
            DateTime(_startDate.year + 1, _startDate.month, _startDate.day);
        break;
    }
  }

  void _submitBudget() {
    if (_formKey.currentState?.validate() ?? false) {
      final budget = BudgetEntity(
        id: const Uuid().v4(),
        name: _nameController.text,
        amount: double.parse(_amountController.text),
        categoryId: _selectedCategory,
        startDate: _startDate,
        endDate: _endDate,
        period: _period,
      );

      ref.read(budgetsProvider.notifier).addBudget(budget);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
