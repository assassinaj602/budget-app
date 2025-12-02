import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/transaction.dart';

final monthlyTotalsProvider = Provider<Map<String, double>>((ref) {
  final transactions = ref.watch(appProvider).transactions;
  final df = DateFormat('MMM yyyy');
  final result = <String, double>{};
  for (final Transaction t in transactions) {
    if (t.type == 'expense') {
      final key = df.format(t.date);
      result[key] = (result[key] ?? 0) + t.amount;
    }
  }
  return result;
});

final categoryTotalsProvider = Provider<Map<String, double>>((ref) {
  final state = ref.watch(appProvider);
  final result = <String, double>{};
  for (final Transaction t in state.transactions) {
    if (t.type == 'expense') {
      result[t.category] = (result[t.category] ?? 0) + t.amount;
    }
  }
  return result;
});
