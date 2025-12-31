import 'package:flutter/foundation.dart';
import 'package:health_app/core/errors/exceptions.dart';
import 'package:health_app/core/errors/failures.dart';

/// Generic failure for untyped exceptions
class _GenericFailure extends Failure {
  _GenericFailure(super.message);
}

/// Global error handler for logging and processing errors
class ErrorHandler {
  ErrorHandler._();

  /// Log an error with optional stack trace
  static void logError(
    dynamic error, {
    StackTrace? stackTrace,
    String? context,
  }) {
    final contextPrefix = context != null ? '[$context] ' : '';
    
    if (kDebugMode) {
      debugPrint('${contextPrefix}Error: $error');
      if (stackTrace != null) {
        debugPrint('${contextPrefix}Stack trace: $stackTrace');
      }
    }

    // Log specific error types with additional context
    if (error is ValidationFailure) {
      debugPrint('${contextPrefix}Validation errors: ${error.fieldErrors}');
    } else if (error is NetworkFailure) {
      debugPrint('${contextPrefix}Network error status: ${error.statusCode}');
    } else if (error is DatabaseFailure) {
      debugPrint('${contextPrefix}Database error: ${error.message}');
    }

    // TODO: In production, send to crash reporting service
    // (Firebase Crashlytics, Sentry, etc.)
  }

  /// Convert an exception to a Failure
  static Failure exceptionToFailure(dynamic exception) {
    if (exception is ValidationException) {
      return ValidationFailure(
        exception.message,
        exception.fieldErrors,
      );
    } else if (exception is DatabaseException) {
      return DatabaseFailure(exception.message);
    } else if (exception is NetworkException) {
      return NetworkFailure(exception.message, exception.statusCode);
    } else if (exception is PermissionException) {
      return PermissionFailure(exception.message);
    } else if (exception is NotFoundException) {
      return NotFoundFailure(exception.resource);
    } else {
      return _GenericFailure(exception.toString());
    }
  }

  /// Get user-friendly error message from a Failure
  static String getUserFriendlyMessage(Failure failure) {
    if (failure is ValidationFailure) {
      // Return first field error or general message
      if (failure.fieldErrors.isNotEmpty) {
        return failure.fieldErrors.values.first;
      }
      return failure.message;
    } else if (failure is DatabaseFailure) {
      return 'Unable to save or load data. Please try again.';
    } else if (failure is NetworkFailure) {
      return 'Unable to connect to the server. Please check your internet connection.';
    } else if (failure is PermissionFailure) {
      return 'Permission denied. Please grant the required permissions.';
    } else if (failure is NotFoundFailure) {
      return '${failure.resource} not found.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Handle an error and return a user-friendly message
  static String handleError(
    dynamic error, {
    StackTrace? stackTrace,
    String? context,
  }) {
    logError(error, stackTrace: stackTrace, context: context);

    if (error is Failure) {
      return getUserFriendlyMessage(error);
    } else if (error is AppException) {
      final failure = exceptionToFailure(error);
      return getUserFriendlyMessage(failure);
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }
}

