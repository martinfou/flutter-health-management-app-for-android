import 'package:fpdart/fpdart.dart';

/// Type alias for Result using Either[Failure, T]
/// 
/// Usage:
/// ```dart
/// Result<double> calculateAverage(List<double> values) {
///   if (values.isEmpty) {
///     return Left(ValidationFailure('Values cannot be empty'));
///   }
///   return Right(values.reduce((a, b) => a + b) / values.length);
/// }
/// ```
typedef Result<T> = Either<Failure, T>;

/// Base Failure class for all error types
abstract class Failure {
  /// Error message
  final String message;

  /// Optional error code
  final int? code;

  /// Creates a Failure with a message and optional code
  Failure(this.message, [this.code]);

  @override
  String toString() => message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          code == other.code;

  @override
  int get hashCode => message.hashCode ^ code.hashCode;
}

/// Validation failure for input validation errors
class ValidationFailure extends Failure {
  /// Field-specific validation errors
  final Map<String, String> fieldErrors;

  /// Creates a ValidationFailure with a message and optional field errors
  ValidationFailure(
    super.message, [
    this.fieldErrors = const {},
  ]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is ValidationFailure &&
          fieldErrors == other.fieldErrors;

  @override
  int get hashCode => super.hashCode ^ fieldErrors.hashCode;
}

/// Database failure for Hive/database errors
class DatabaseFailure extends Failure {
  /// Creates a DatabaseFailure with a message
  DatabaseFailure(super.message);
}

/// Network failure for API/network errors (post-MVP)
class NetworkFailure extends Failure {
  /// HTTP status code if available
  final int? statusCode;

  /// Creates a NetworkFailure with a message and optional status code
  NetworkFailure(String message, [this.statusCode]) : super(message, statusCode);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is NetworkFailure &&
          statusCode == other.statusCode;

  @override
  int get hashCode => super.hashCode ^ statusCode.hashCode;
}

/// Permission failure for permission-related errors
class PermissionFailure extends Failure {
  /// Creates a PermissionFailure with a message
  PermissionFailure(super.message);
}

/// Not found failure for resource not found errors
class NotFoundFailure extends Failure {
  /// Resource name that was not found
  final String resource;

  /// Creates a NotFoundFailure for a resource
  NotFoundFailure(this.resource) : super('$resource not found');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is NotFoundFailure &&
          resource == other.resource;

  @override
  int get hashCode => super.hashCode ^ resource.hashCode;
}

/// Cache failure for cache-related errors
class CacheFailure extends Failure {
  /// Creates a CacheFailure with a message
  CacheFailure(super.message);
}

/// Authentication failure for authentication-related errors
class AuthenticationFailure extends Failure {
  /// Creates an AuthenticationFailure with a message
  AuthenticationFailure(super.message);
}

