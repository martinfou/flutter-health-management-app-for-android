/// Base exception class for all custom exceptions
abstract class AppException implements Exception {
  /// Error message
  final String message;

  /// Optional error code
  final int? code;

  /// Creates an AppException with a message and optional code
  AppException(this.message, [this.code]);

  @override
  String toString() => message;
}

/// Database exception for Hive/database errors
class DatabaseException extends AppException {
  /// Creates a DatabaseException with a message
  DatabaseException(super.message);
}

/// Validation exception for input validation errors
class ValidationException extends AppException {
  /// Field-specific validation errors
  final Map<String, String> fieldErrors;

  /// Creates a ValidationException with a message and optional field errors
  ValidationException(
    super.message, [
    this.fieldErrors = const {},
  ]);
}

/// Network exception for API/network errors (post-MVP)
class NetworkException extends AppException {
  /// HTTP status code if available
  final int? statusCode;

  /// Creates a NetworkException with a message and optional status code
  NetworkException(String message, [this.statusCode]) : super(message, statusCode);
}

/// Permission exception for permission-related errors
class PermissionException extends AppException {
  /// Creates a PermissionException with a message
  PermissionException(super.message);
}

/// Not found exception for resource not found errors
class NotFoundException extends AppException {
  /// Resource name that was not found
  final String resource;

  /// Creates a NotFoundException for a resource
  NotFoundException(this.resource) : super('$resource not found');
}

