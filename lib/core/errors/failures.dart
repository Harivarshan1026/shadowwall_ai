/// Error handling — Failure classes for clean error propagation.
///
/// Uses the Either pattern (via dartz) to return [Failure] from
/// repository methods instead of throwing exceptions.
library;

import 'package:equatable/equatable.dart';

/// Base failure class.
abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Server-side failures (Firebase, API).
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

/// Local cache or database failures.
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code});
}

/// Network connectivity failures.
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
  });
}

/// Authentication failures.
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});
}

/// Input validation failures.
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

/// Permission denied failures.
class PermissionFailure extends Failure {
  const PermissionFailure({
    super.message = 'Permission denied. Please grant the required permissions.',
  });
}

/// AI / ML model failures.
class AIFailure extends Failure {
  const AIFailure({
    super.message = 'AI analysis failed. Using rule-based fallback.',
  });
}

/// File operation failures.
class FileFailure extends Failure {
  const FileFailure({required super.message});
}

/// Unknown / unexpected failures.
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred. Please try again.',
  });
}
