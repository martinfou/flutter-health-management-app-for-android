// Dart SDK
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Authentication configuration
///
/// Use [authEnabledProvider] for runtime toggle (can be changed from settings)
/// Use [AuthConfig.isEnabledByDefault] for compile-time default
class AuthConfig {
  AuthConfig._();

  /// Default authentication state (compile-time constant)
  ///
  /// Set to true to enable authentication by default for production.
  /// Note: This can be overridden at runtime using [authEnabledProvider]
  static const bool isEnabledByDefault = true;

  /// Enable or disable authentication (runtime)
  ///
  /// When false:
  /// - Login page is skipped
  /// - Protected routes are accessible without authentication
  /// - User can access all app features without logging in
  ///
  /// When true:
  /// - Users must register/login to access the app
  /// - Protected routes require authentication
  /// - All authentication features are active
  ///
  /// Use [authEnabledProvider] to read/write this value at runtime
  static bool isEnabled(WidgetRef ref) {
    return ref.watch(authEnabledProvider);
  }
}

/// Provider for authentication enabled/disabled state
///
/// This allows runtime toggling of authentication from settings
final authEnabledProvider = StateProvider<bool>((ref) {
  return AuthConfig.isEnabledByDefault;
});
