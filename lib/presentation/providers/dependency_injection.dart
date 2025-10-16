import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../data/repositories/budget_repository_impl.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../domain/usecases/transaction_usecases.dart';
import '../../domain/usecases/budget_usecases.dart';

// ========== Repository Providers ==========

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl();
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepositoryImpl();
});

// ========== Use Case Providers ==========

// Transaction Use Cases
final getTransactionsUseCaseProvider = Provider<GetTransactions>((ref) {
  return GetTransactions(ref.read(transactionRepositoryProvider));
});

final getTransactionsByDateRangeUseCaseProvider =
    Provider<GetTransactionsByDateRange>((ref) {
  return GetTransactionsByDateRange(ref.read(transactionRepositoryProvider));
});

final addTransactionUseCaseProvider = Provider<AddTransaction>((ref) {
  return AddTransaction(ref.read(transactionRepositoryProvider));
});

final deleteTransactionUseCaseProvider = Provider<DeleteTransaction>((ref) {
  return DeleteTransaction(ref.read(transactionRepositoryProvider));
});

final searchTransactionsUseCaseProvider = Provider<SearchTransactions>((ref) {
  return SearchTransactions(ref.read(transactionRepositoryProvider));
});

// Budget Use Cases
final getBudgetsUseCaseProvider = Provider<GetBudgets>((ref) {
  return GetBudgets(ref.read(budgetRepositoryProvider));
});

final getActiveBudgetsUseCaseProvider = Provider<GetActiveBudgets>((ref) {
  return GetActiveBudgets(ref.read(budgetRepositoryProvider));
});

final addBudgetUseCaseProvider = Provider<AddBudget>((ref) {
  return AddBudget(ref.read(budgetRepositoryProvider));
});

final getBudgetSpentAmountUseCaseProvider =
    Provider<GetBudgetSpentAmount>((ref) {
  return GetBudgetSpentAmount(ref.read(budgetRepositoryProvider));
});
