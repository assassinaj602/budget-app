import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Failure when database operations fail
class DatabaseFailure extends Failure {
  const DatabaseFailure([String message = 'Database operation failed'])
      : super(message);
}

/// Failure when cache operations fail
class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache operation failed'])
      : super(message);
}

/// Failure when network operations fail
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Network operation failed'])
      : super(message);
}

/// Failure when validation fails
class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Validation failed'])
      : super(message);
}

/// Failure when authentication fails
class AuthenticationFailure extends Failure {
  const AuthenticationFailure([String message = 'Authentication failed'])
      : super(message);
}

/// Failure for unexpected errors
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([String message = 'An unexpected error occurred'])
      : super(message);
}
