// Dart SDK

/// Network error utilities for handling and categorizing errors
class NetworkErrorUtils {
  /// Get user-friendly error message from error object
  static String getErrorMessage(dynamic error) {
    if (error == null) {
      return 'An unknown error occurred';
    }

    final errorString = error.toString();

    if (errorString.contains('SocketException')) {
      return 'No internet connection. Please check your network.';
    } else if (errorString.contains('HttpException')) {
      if (errorString.contains('Connection refused')) {
        return 'Server is not responding. Please try again later.';
      } else if (errorString.contains('Connection timed out')) {
        return 'Connection timed out. Please check your internet connection.';
      } else if (errorString.contains('Host not found')) {
        return 'Server address not found. Please check the URL.';
      }
      return 'A network error occurred. Please try again.';
    } else if (errorString.contains('NetworkImageLoadException')) {
      return 'Failed to load image. Please check your connection.';
    } else if (errorString.contains('CertificateException')) {
      return 'Security certificate error. Please check your date/time settings.';
    } else if (errorString.contains('HandshakeException')) {
      return 'Secure connection failed. Please try again.';
    }

    return errorString;
  }

  /// Check if error is transient (can be retried)
  static bool isTransientError(dynamic error) {
    if (error == null) {
      return false;
    }

    final errorString = error.toString();

    return errorString.contains('SocketException') ||
        errorString.contains('Connection refused') ||
        errorString.contains('Connection timed out') ||
        errorString.contains('Network unreachable') ||
        errorString.contains('599') || // Server error range
        errorString.contains('429'); // Rate limit
  }

  /// Get retry count based on attempt number (exponential backoff)
  static int getRetryCount(int attemptNumber) {
    return attemptNumber;
  }

  /// Get retry delay with exponential backoff (1s, 2s, 4s, 8s, max 16s)
  static Duration getRetryDelay(int attemptNumber) {
    const baseDelay = Duration(seconds: 1);
    const maxDelay = Duration(seconds: 16);

    final delay = baseDelay * (1 << attemptNumber);
    return delay > maxDelay ? maxDelay : delay;
  }

  /// Check if should retry based on error type and attempt count
  static bool shouldRetry(dynamic error, int attemptNumber) {
    if (!isTransientError(error)) {
      return false;
    }

    return attemptNumber < 3;
  }
}
