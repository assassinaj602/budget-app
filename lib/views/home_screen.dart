import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dashboard_components.dart';
import 'add_transaction_modal.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: const DashboardScreen(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddTransactionModal(context),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }
}
