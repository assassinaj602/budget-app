import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class GetTransactions implements UseCase<List<TransactionEntity>, NoParams> {
  final TransactionRepository repository;

  GetTransactions(this.repository);

  @override
  Future<Either<Failure, List<TransactionEntity>>> call(NoParams params) async {
    return await repository.getTransactions();
  }
}

class GetTransactionsByDateRange
    implements
        UseCase<List<TransactionEntity>, GetTransactionsByDateRangeParams> {
  final TransactionRepository repository;

  GetTransactionsByDateRange(this.repository);

  @override
  Future<Either<Failure, List<TransactionEntity>>> call(
    GetTransactionsByDateRangeParams params,
  ) async {
    return await repository.getTransactionsByDateRange(
      params.startDate,
      params.endDate,
    );
  }
}

class GetTransactionsByDateRangeParams {
  final DateTime startDate;
  final DateTime endDate;

  GetTransactionsByDateRangeParams({
    required this.startDate,
    required this.endDate,
  });
}

class AddTransaction implements UseCase<void, AddTransactionParams> {
  final TransactionRepository repository;

  AddTransaction(this.repository);

  @override
  Future<Either<Failure, void>> call(AddTransactionParams params) async {
    return await repository.addTransaction(params.transaction);
  }
}

class AddTransactionParams {
  final TransactionEntity transaction;

  AddTransactionParams({required this.transaction});
}

class DeleteTransaction implements UseCase<void, DeleteTransactionParams> {
  final TransactionRepository repository;

  DeleteTransaction(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteTransactionParams params) async {
    return await repository.deleteTransaction(params.id);
  }
}

class DeleteTransactionParams {
  final String id;

  DeleteTransactionParams({required this.id});
}

class SearchTransactions
    implements UseCase<List<TransactionEntity>, SearchTransactionsParams> {
  final TransactionRepository repository;

  SearchTransactions(this.repository);

  @override
  Future<Either<Failure, List<TransactionEntity>>> call(
    SearchTransactionsParams params,
  ) async {
    return await repository.searchTransactions(params.query);
  }
}

class SearchTransactionsParams {
  final String query;

  SearchTransactionsParams({required this.query});
}
