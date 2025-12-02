import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'add_transaction_form.dart';
import 'widgets/standard_bottom_sheet.dart';

void showAddTransactionModal(BuildContext context) {
  showStandardFormSheet(
    context,
    title: 'Add New Transaction',
    child: const AddTransactionForm(),
  );
}

class AddTransactionAction extends ConsumerWidget {
  const AddTransactionAction({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      onPressed: () => showAddTransactionModal(context),
      icon: const Icon(Icons.add),
      label: const Text('Add Transaction'),
    );
  }
}
