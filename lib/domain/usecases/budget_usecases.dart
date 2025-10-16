import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';
import '../entities/budget_entity.dart';
import '../repositories/budget_repository.dart';

class GetBudgets implements UseCase<List<BudgetEntity>, NoParams> {
  final BudgetRepository repository;

  GetBudgets(this.repository);

  @override
  Future<Either<Failure, List<BudgetEntity>>> call(NoParams params) async {
    return await repository.getBudgets();
  }
}

class GetActiveBudgets implements UseCase<List<BudgetEntity>, NoParams> {
  final BudgetRepository repository;

  GetActiveBudgets(this.repository);

  @override
  Future<Either<Failure, List<BudgetEntity>>> call(NoParams params) async {
    return await repository.getActiveBudgets();
  }
}

class AddBudget implements UseCase<void, AddBudgetParams> {
  final BudgetRepository repository;

  AddBudget(this.repository);

  @override
  Future<Either<Failure, void>> call(AddBudgetParams params) async {
    return await repository.addBudget(params.budget);
  }
}

class AddBudgetParams {
  final BudgetEntity budget;

  AddBudgetParams({required this.budget});
}

class GetBudgetSpentAmount
    implements UseCase<double, GetBudgetSpentAmountParams> {
  final BudgetRepository repository;

  GetBudgetSpentAmount(this.repository);

  @override
  Future<Either<Failure, double>> call(
      GetBudgetSpentAmountParams params) async {
    return await repository.getBudgetSpentAmount(params.budgetId);
  }
}

class GetBudgetSpentAmountParams {
  final String budgetId;

  GetBudgetSpentAmountParams({required this.budgetId});
}
