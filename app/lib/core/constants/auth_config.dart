// Dart SDK
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Authentication configuration with development mode support
///
/// Use [authModeProvider] for runtime mode selection (production/development)
/// Use [AuthConfig.isEnabledByDefault] for compile-time default
enum AuthMode {
  /// Production mode: Full authentication with production backend
  production,

  /// Development mode: Mock server, offline-capable authentication
  development,
}

/// Authentication configuration
class AuthConfig {
  AuthConfig._();

  /// Default authentication mode (compile-time constant)
  ///
  /// Set to production mode for full authentication with production backend
  /// Note: This can be overridden at runtime using [authModeProvider]
  static const AuthMode defaultMode = AuthMode.production;

  /// Check if authentication is enabled for given mode
  static bool isEnabled(WidgetRef ref) {
    final mode = ref.watch(authModeProvider);
    switch (mode) {
      case AuthMode.production:
        return true;
      case AuthMode.development:
        return true; // Development mode still authenticates, just uses mock backend
      default:
        return defaultMode == AuthMode.production;
    }
  }
}

/// Provider for authentication mode selection (production/development)
final authModeProvider = StateProvider<AuthMode>((ref) {
  return AuthConfig.defaultMode;
});

/// Provider for authentication enabled state (always true by default)
final authEnabledProvider = StateProvider<bool>((ref) {
  return true;
});
