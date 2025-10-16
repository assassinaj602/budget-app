import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../utils/database_helper.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];

  List<Transaction> get transactions => _transactions;

  Future<void> loadTransactions() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('transactions');
    _transactions = List.generate(maps.length, (i) {
      return Transaction.fromMap(maps[i]);
    });
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('transactions', transaction.toMap());
    await loadTransactions();
    notifyListeners();
  }
}
