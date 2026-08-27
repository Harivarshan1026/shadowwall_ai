/// Exception classes for data layer error handling.
///
/// These are caught in repository implementations and converted
/// to [Failure] instances for the domain layer.
library;

/// Thrown when a server/API call fails.
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException: $message (code: $statusCode)';
}

/// Thrown when local cache operations fail.
class CacheException implements Exception {
  final String message;

  const CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

/// Thrown when authentication operations fail.
class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException({required this.message, this.code});

  @override
  String toString() => 'AuthException: $message (code: $code)';
}

/// Thrown when no network connection is available.
class NetworkException implements Exception {
  const NetworkException();

  @override
  String toString() => 'NetworkException: No internet connection';
}

/// Thrown when AI/ML model operations fail.
class AIException implements Exception {
  final String message;

  const AIException({required this.message});

  @override
  String toString() => 'AIException: $message';
}

/// Thrown when file operations fail.
class FileOperationException implements Exception {
  final String message;

  const FileOperationException({required this.message});

  @override
  String toString() => 'FileOperationException: $message';
}
