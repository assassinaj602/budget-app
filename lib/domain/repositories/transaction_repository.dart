import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/transaction_entity.dart';

/// Repository interface for Transaction operations
abstract class TransactionRepository {
  /// Get all transactions
  Future<Either<Failure, List<TransactionEntity>>> getTransactions();

  /// Get transactions by date range
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Get transactions by category
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByCategory(
    String categoryId,
  );

  /// Get transactions by type (income/expense)
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByType(
    String type,
  );

  /// Add a new transaction
  Future<Either<Failure, void>> addTransaction(TransactionEntity transaction);

  /// Update an existing transaction
  Future<Either<Failure, void>> updateTransaction(
      TransactionEntity transaction);

  /// Delete a transaction
  Future<Either<Failure, void>> deleteTransaction(String id);

  /// Search transactions
  Future<Either<Failure, List<TransactionEntity>>> searchTransactions(
    String query,
  );

  /// Get recurring transactions
  Future<Either<Failure, List<TransactionEntity>>> getRecurringTransactions();

  /// Generate recurring transactions
  Future<Either<Failure, void>> generateRecurringTransactions();
}
