import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../error/failures.dart';

/// Base class for all use cases
/// Takes a parameter of type [Params] and returns an [Either] with [Failure] or [Type]
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// UseCase that doesn't require parameters
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
