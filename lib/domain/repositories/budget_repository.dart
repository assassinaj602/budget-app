import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/budget_entity.dart';

/// Repository interface for Budget operations
abstract class BudgetRepository {
  /// Get all budgets
  Future<Either<Failure, List<BudgetEntity>>> getBudgets();

  /// Get budget by ID
  Future<Either<Failure, BudgetEntity>> getBudgetById(String id);

  /// Get budgets by category
  Future<Either<Failure, List<BudgetEntity>>> getBudgetsByCategory(
    String categoryId,
  );

  /// Get active budgets for current period
  Future<Either<Failure, List<BudgetEntity>>> getActiveBudgets();

  /// Add a new budget
  Future<Either<Failure, void>> addBudget(BudgetEntity budget);

  /// Update an existing budget
  Future<Either<Failure, void>> updateBudget(BudgetEntity budget);

  /// Delete a budget
  Future<Either<Failure, void>> deleteBudget(String id);

  /// Get budget spent amount
  Future<Either<Failure, double>> getBudgetSpentAmount(String budgetId);

  /// Check if budget limit is reached
  Future<Either<Failure, bool>> isBudgetLimitReached(String budgetId);
}
