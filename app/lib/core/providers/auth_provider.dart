// Dart SDK
import 'package:riverpod/riverpod.dart';

// Project
import 'package:health_app/core/network/authentication_service.dart';
import 'package:health_app/core/network/token_storage.dart';

/// Authentication state
class AuthState {
  final bool isAuthenticated;
  final AuthUser? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    required this.isAuthenticated,
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    AuthUser? user,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Authentication state notifier
class AuthStateNotifier extends StateNotifier<AuthState> {
  AuthStateNotifier() : super(const AuthState(isAuthenticated: false)) {
    _checkAuthStatus();
  }

  /// Check authentication status on initialization
  Future<void> _checkAuthStatus() async {
    final isAuthenticated = await TokenStorage.hasTokens();
    if (isAuthenticated) {
      // Try to get user profile
      final profileResult = await AuthenticationService.getProfile();
      profileResult.fold(
        (failure) {
          // If profile fetch fails, user is not authenticated
          state = AuthState(isAuthenticated: false);
        },
        (user) {
          state = AuthState(isAuthenticated: true, user: user);
        },
      );
    } else {
      state = const AuthState(isAuthenticated: false);
    }
  }

  /// Register a new user
  Future<void> register({
    required String email,
    required String password,
    String? name,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await AuthenticationService.register(
      email: email,
      password: password,
      name: name,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
          isAuthenticated: false,
        );
      },
      (user) {
        state = AuthState(
          isAuthenticated: true,
          user: user,
          isLoading: false,
        );
      },
    );
  }

  /// Login with email and password
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await AuthenticationService.login(
      email: email,
      password: password,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
          isAuthenticated: false,
        );
      },
      (user) {
        state = AuthState(
          isAuthenticated: true,
          user: user,
          isLoading: false,
        );
      },
    );
  }

  /// Login with Google OAuth
  Future<void> loginWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await AuthenticationService.loginWithGoogle();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
          isAuthenticated: false,
        );
      },
      (user) {
        state = AuthState(
          isAuthenticated: true,
          user: user,
          isLoading: false,
        );
      },
    );
  }

  /// Logout user
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    await AuthenticationService.logout();

    state = AuthState(
      isAuthenticated: false,
      isLoading: false,
      user: null,
    );
  }

  /// Refresh user profile
  Future<void> refreshProfile() async {
    final result = await AuthenticationService.getProfile();
    result.fold(
      (failure) {
        // If profile fetch fails, logout user
        state = state.copyWith(isAuthenticated: false, clearUser: true);
      },
      (user) {
        state = state.copyWith(user: user);
      },
    );
  }

  /// Update user profile
  Future<void> updateProfile({
    String? email,
    String? name,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await AuthenticationService.updateProfile(
      email: email,
      name: name,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (user) {
        state = state.copyWith(
          user: user,
          isLoading: false,
        );
      },
    );
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Authentication state provider
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>(
  (ref) => AuthStateNotifier(),
);

/// Convenience provider for authentication status
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isAuthenticated;
});

/// Convenience provider for current user
final currentUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authStateProvider).user;
});
