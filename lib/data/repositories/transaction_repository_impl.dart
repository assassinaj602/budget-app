import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import '../../services/hive_security.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final String boxName = 'transactions';

  Future<Box<TransactionModel>> _getBox() async {
    try {
      final cipher = await HiveSecurity.getCipher();
      if (cipher != null) {
        return await Hive.openBox<TransactionModel>(
          boxName,
          encryptionCipher: cipher,
        );
      }
    } catch (_) {
      // Fallback below
    }
    // Fallback to unencrypted open if cipher unavailable or open fails
    return await Hive.openBox<TransactionModel>(boxName);
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions() async {
    try {
      final box = await _getBox();
      final transactions = box.values.map((model) => model.toEntity()).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      return Right(transactions);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final box = await _getBox();
      final transactions = box.values
          .where((t) =>
              t.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
              t.date.isBefore(endDate.add(const Duration(days: 1))))
          .map((model) => model.toEntity())
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      return Right(transactions);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByCategory(
    String categoryId,
  ) async {
    try {
      final box = await _getBox();
      final transactions = box.values
          .where((t) => t.category == categoryId)
          .map((model) => model.toEntity())
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      return Right(transactions);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByType(
    String type,
  ) async {
    try {
      final box = await _getBox();
      final transactions = box.values
          .where((t) => t.type == type)
          .map((model) => model.toEntity())
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      return Right(transactions);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addTransaction(
    TransactionEntity transaction,
  ) async {
    try {
      final box = await _getBox();
      final model = TransactionModel.fromEntity(transaction);
      await box.add(model);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateTransaction(
    TransactionEntity transaction,
  ) async {
    try {
      final box = await _getBox();
      final index =
          box.values.toList().indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        final model = TransactionModel.fromEntity(transaction);
        await box.putAt(index, model);
        return const Right(null);
      }
      return const Left(DatabaseFailure('Transaction not found'));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String id) async {
    try {
      final box = await _getBox();
      final key = box.keys.firstWhere(
        (k) => box.get(k)?.id == id,
        orElse: () => null,
      );
      if (key != null) {
        await box.delete(key);
        // Hint Hive to compact storage after deletions
        await box.compact();
        return const Right(null);
      }
      return const Left(DatabaseFailure('Transaction not found'));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> searchTransactions(
    String query,
  ) async {
    try {
      final box = await _getBox();
      final lowercaseQuery = query.toLowerCase();
      final transactions = box.values
          .where((t) =>
              t.title.toLowerCase().contains(lowercaseQuery) ||
              t.category.toLowerCase().contains(lowercaseQuery) ||
              (t.note?.toLowerCase().contains(lowercaseQuery) ?? false))
          .map((model) => model.toEntity())
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      return Right(transactions);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>>
      getRecurringTransactions() async {
    try {
      final box = await _getBox();
      final transactions = box.values
          .where((t) => t.isRecurring)
          .map((model) => model.toEntity())
          .toList();
      return Right(transactions);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> generateRecurringTransactions() async {
    try {
      final recurringResult = await getRecurringTransactions();
      return recurringResult.fold(
        (failure) => Left(failure),
        (recurring) async {
          final now = DateTime.now();
          for (final transaction in recurring) {
            // Check if we need to generate a new transaction
            if (transaction.recurringEndDate != null &&
                now.isAfter(transaction.recurringEndDate!)) {
              continue; // Recurring period has ended
            }

            // Logic to generate next transaction based on pattern
            DateTime? nextDate;
            switch (transaction.recurringPattern) {
              case 'daily':
                nextDate = transaction.date.add(const Duration(days: 1));
                break;
              case 'weekly':
                nextDate = transaction.date.add(const Duration(days: 7));
                break;
              case 'monthly':
                nextDate = DateTime(
                  transaction.date.year,
                  transaction.date.month + 1,
                  transaction.date.day,
                );
                break;
              case 'yearly':
                nextDate = DateTime(
                  transaction.date.year + 1,
                  transaction.date.month,
                  transaction.date.day,
                );
                break;
            }

            if (nextDate != null && nextDate.isBefore(now)) {
              // Create new transaction
              final newTransaction = transaction.copyWith(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                date: nextDate,
              );
              await addTransaction(newTransaction);
            }
          }
          return const Right(null);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
