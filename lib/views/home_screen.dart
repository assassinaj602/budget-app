import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dashboard_components.dart';
import 'enhanced_add_transaction_form.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: const DashboardScreen(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const EnhancedAddTransactionForm(),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }
}
