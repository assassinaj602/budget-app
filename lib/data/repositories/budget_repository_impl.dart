import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/budget_repository.dart';
import '../models/budget_model.dart';
import '../models/transaction_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final String boxName = 'budgets';
  final String transactionsBoxName = 'transactions';

  Future<Box<BudgetModel>> _getBox() async {
    return await Hive.openBox<BudgetModel>(boxName);
  }

  Future<Box<TransactionModel>> _getTransactionsBox() async {
    return await Hive.openBox<TransactionModel>(transactionsBoxName);
  }

  @override
  Future<Either<Failure, List<BudgetEntity>>> getBudgets() async {
    try {
      final box = await _getBox();
      final budgets = box.values.map((model) => model.toEntity()).toList();
      return Right(budgets);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BudgetEntity>> getBudgetById(String id) async {
    try {
      final box = await _getBox();
      final budget = box.values.firstWhere((b) => b.id == id);
      return Right(budget.toEntity());
    } catch (e) {
      return Left(DatabaseFailure('Budget not found'));
    }
  }

  @override
  Future<Either<Failure, List<BudgetEntity>>> getBudgetsByCategory(
    String categoryId,
  ) async {
    try {
      final box = await _getBox();
      final budgets = box.values
          .where((b) => b.categoryId == categoryId)
          .map((model) => model.toEntity())
          .toList();
      return Right(budgets);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BudgetEntity>>> getActiveBudgets() async {
    try {
      final box = await _getBox();
      final now = DateTime.now();
      final budgets = box.values
          .where((b) =>
              now.isAfter(b.startDate.subtract(const Duration(days: 1))) &&
              now.isBefore(b.endDate.add(const Duration(days: 1))))
          .map((model) => model.toEntity())
          .toList();
      return Right(budgets);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addBudget(BudgetEntity budget) async {
    try {
      final box = await _getBox();
      final model = BudgetModel.fromEntity(budget);
      await box.add(model);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateBudget(BudgetEntity budget) async {
    try {
      final box = await _getBox();
      final index = box.values.toList().indexWhere((b) => b.id == budget.id);
      if (index != -1) {
        final model = BudgetModel.fromEntity(budget);
        await box.putAt(index, model);
        return const Right(null);
      }
      return const Left(DatabaseFailure('Budget not found'));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBudget(String id) async {
    try {
      final box = await _getBox();
      final key = box.keys.firstWhere(
        (k) => box.get(k)?.id == id,
        orElse: () => null,
      );
      if (key != null) {
        await box.delete(key);
        return const Right(null);
      }
      return const Left(DatabaseFailure('Budget not found'));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getBudgetSpentAmount(String budgetId) async {
    try {
      final budgetResult = await getBudgetById(budgetId);
      return budgetResult.fold(
        (failure) => Left(failure),
        (budget) async {
          final transactionsBox = await _getTransactionsBox();

          // Calculate spent amount based on budget parameters
          double spent = 0.0;

          for (final transaction in transactionsBox.values) {
            // Only count expenses
            if (transaction.type != 'expense') continue;

            // Check if transaction is within budget period
            if (transaction.date.isBefore(budget.startDate) ||
                transaction.date.isAfter(budget.endDate)) {
              continue;
            }

            // If budget is category-specific, filter by category
            if (budget.categoryId != null &&
                transaction.category != budget.categoryId) {
              continue;
            }

            spent += transaction.amount;
          }

          return Right(spent);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isBudgetLimitReached(String budgetId) async {
    try {
      final budgetResult = await getBudgetById(budgetId);
      return budgetResult.fold(
        (failure) => Left(failure),
        (budget) async {
          final spentResult = await getBudgetSpentAmount(budgetId);
          return spentResult.fold(
            (failure) => Left(failure),
            (spent) => Right(spent >= budget.amount),
          );
        },
      );
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
