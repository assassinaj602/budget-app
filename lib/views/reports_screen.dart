import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/currency_provider.dart';
import '../providers/app_provider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appProvider);
    final transactions = state.transactions;
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: transactions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart,
                      color: Colors.indigo.shade200, size: 56),
                  const SizedBox(height: 16),
                  const Text('No report data yet',
                      style: TextStyle(color: Color(0xFF9FA8DA), fontSize: 18)),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(24), // Fix padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: const Color(0xFFE8EAF6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Income',
                              style:
                                  TextStyle(color: Colors.green, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(
                              '\u0024${ref.watch(currencyProvider)} ${transactions.where((t) => t.type == 'income').fold(0.0, (sum, t) => sum + t.amount).toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          const Text('Total Expenses',
                              style:
                                  TextStyle(color: Colors.red, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(
                              '\u0024${ref.watch(currencyProvider)} ${transactions.where((t) => t.type == 'expense').fold(0.0, (sum, t) => sum + t.amount).toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          const Text('Balance',
                              style: TextStyle(
                                  color: Color(0xFF3F51B5), fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(
                              '\u0024${ref.watch(currencyProvider)} ${(transactions.where((t) => t.type == 'income').fold(0.0, (sum, t) => sum + t.amount) - transactions.where((t) => t.type == 'expense').fold(0.0, (sum, t) => sum + t.amount)).toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: Color(0xFF3F51B5),
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
