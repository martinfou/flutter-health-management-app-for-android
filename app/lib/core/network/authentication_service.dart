// Dart SDK
import 'dart:convert';
import 'package:http/http.dart' as http;

// Project
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/network/token_storage.dart';
import 'package:fpdart/fpdart.dart';

/// Result type for authentication operations
typedef AuthResult<T> = Result<T>;

/// User model for authentication
class AuthUser {
  final String id;
  final String email;
  final String? name;

  AuthUser({
    required this.id,
    required this.email,
    this.name,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      if (name != null) 'name': name,
    };
  }
}

/// Authentication tokens response
class AuthTokens {
  final String accessToken;
  final String refreshToken;

  AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }
}

/// Authentication service for user registration, login, and token management
class AuthenticationService {
  AuthenticationService._();

  // Mock server URL for development
  // For Android emulator: use 'http://10.0.2.2:3000/api'
  // For iOS simulator: use 'http://localhost:3000/api'
  // For physical device: use your computer's IP address, e.g., 'http://192.168.1.100:3000/api'
  // TODO: Replace with actual backend URL for production
  static const String _baseUrl = 'http://192.168.5.17:3000/api'; // Android emulator default
  static const String _registerEndpoint = '/auth/register';
  static const String _loginEndpoint = '/auth/login';
  static const String _refreshEndpoint = '/auth/refresh';
  static const String _logoutEndpoint = '/auth/logout';
  static const String _profileEndpoint = '/user/profile';
  static const String _passwordResetRequestEndpoint = '/auth/password-reset/request';
  static const String _passwordResetVerifyEndpoint = '/auth/password-reset/verify';
  static const String _deleteAccountEndpoint = '/user/account';

  /// Register a new user
  static Future<AuthResult<AuthUser>> register({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_registerEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          if (name != null) 'name': name,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final tokens = AuthTokens.fromJson(data);
        final user = AuthUser.fromJson(data['user'] as Map<String, dynamic>);

        // Save tokens
        await TokenStorage.saveAccessToken(tokens.accessToken);
        await TokenStorage.saveRefreshToken(tokens.refreshToken);

        return Right(user);
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        return Left(ValidationFailure(
          error['message'] as String? ?? 'Registration failed',
        ));
      } else {
        return Left(NetworkFailure(
          'Registration failed: ${response.statusCode}',
          response.statusCode,
        ));
      }
    } catch (e) {
      return Left(NetworkFailure('Network error: ${e.toString()}'));
    }
  }

  /// Login with email and password
  static Future<AuthResult<AuthUser>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_loginEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final tokens = AuthTokens.fromJson(data);
        final user = AuthUser.fromJson(data['user'] as Map<String, dynamic>);

        // Save tokens
        await TokenStorage.saveAccessToken(tokens.accessToken);
        await TokenStorage.saveRefreshToken(tokens.refreshToken);

        return Right(user);
      } else if (response.statusCode == 401) {
        return Left(AuthenticationFailure('Invalid email or password'));
      } else {
        return Left(NetworkFailure(
          'Login failed: ${response.statusCode}',
          response.statusCode,
        ));
      }
    } catch (e) {
      return Left(NetworkFailure('Network error: ${e.toString()}'));
    }
  }

  /// Refresh access token using refresh token
  static Future<AuthResult<String>> refreshToken() async {
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken == null) {
        return Left(AuthenticationFailure('No refresh token available'));
      }

      final response = await http.post(
        Uri.parse('$_baseUrl$_refreshEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final tokens = AuthTokens.fromJson(data);

        // Save new tokens
        await TokenStorage.saveAccessToken(tokens.accessToken);
        await TokenStorage.saveRefreshToken(tokens.refreshToken);

        return Right(tokens.accessToken);
      } else if (response.statusCode == 401) {
        // Refresh token expired, clear tokens
        await TokenStorage.clearTokens();
        return Left(AuthenticationFailure('Session expired. Please login again'));
      } else {
        return Left(NetworkFailure(
          'Token refresh failed: ${response.statusCode}',
          response.statusCode,
        ));
      }
    } catch (e) {
      return Left(NetworkFailure('Network error: ${e.toString()}'));
    }
  }

  /// Logout user and clear tokens
  static Future<AuthResult<void>> logout() async {
    try {
      final accessToken = await TokenStorage.getAccessToken();
      if (accessToken != null) {
        // Try to call logout endpoint (optional, may fail if token expired)
        try {
          await http.post(
            Uri.parse('$_baseUrl$_logoutEndpoint'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
          );
        } catch (_) {
          // Ignore errors - we'll clear tokens anyway
        }
      }

      // Clear tokens locally
      await TokenStorage.clearTokens();
      return const Right(null);
    } catch (e) {
      // Even if logout fails, clear tokens locally
      await TokenStorage.clearTokens();
      return Left(NetworkFailure('Logout error: ${e.toString()}'));
    }
  }

  /// Get user profile
  static Future<AuthResult<AuthUser>> getProfile() async {
    try {
      final accessToken = await TokenStorage.getAccessToken();
      if (accessToken == null) {
        return Left(AuthenticationFailure('Not authenticated'));
      }

      final response = await http.get(
        Uri.parse('$_baseUrl$_profileEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final user = AuthUser.fromJson(data);
        return Right(user);
      } else if (response.statusCode == 401) {
        // Token expired, try to refresh
        final refreshResult = await refreshToken();
        if (refreshResult.isLeft()) {
          return Left(AuthenticationFailure('Session expired. Please login again'));
        }
        // Retry with new token
        return getProfile();
      } else {
        return Left(NetworkFailure(
          'Failed to get profile: ${response.statusCode}',
          response.statusCode,
        ));
      }
    } catch (e) {
      return Left(NetworkFailure('Network error: ${e.toString()}'));
    }
  }

  /// Update user profile
  static Future<AuthResult<AuthUser>> updateProfile({
    String? email,
    String? name,
  }) async {
    try {
      final accessToken = await TokenStorage.getAccessToken();
      if (accessToken == null) {
        return Left(AuthenticationFailure('Not authenticated'));
      }

      final body = <String, dynamic>{};
      if (email != null) body['email'] = email;
      if (name != null) body['name'] = name;

      final response = await http.put(
        Uri.parse('$_baseUrl$_profileEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final user = AuthUser.fromJson(data);
        return Right(user);
      } else if (response.statusCode == 401) {
        // Token expired, try to refresh
        final refreshResult = await refreshToken();
        if (refreshResult.isLeft()) {
          return Left(AuthenticationFailure('Session expired. Please login again'));
        }
        // Retry with new token
        return updateProfile(email: email, name: name);
      } else {
        return Left(NetworkFailure(
          'Failed to update profile: ${response.statusCode}',
          response.statusCode,
        ));
      }
    } catch (e) {
      return Left(NetworkFailure('Network error: ${e.toString()}'));
    }
  }

  /// Request password reset
  static Future<AuthResult<void>> requestPasswordReset({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_passwordResetRequestEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        return const Right(null);
      } else {
        return Left(NetworkFailure(
          'Failed to request password reset: ${response.statusCode}',
          response.statusCode,
        ));
      }
    } catch (e) {
      return Left(NetworkFailure('Network error: ${e.toString()}'));
    }
  }

  /// Verify password reset token and set new password
  static Future<AuthResult<void>> verifyPasswordReset({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_passwordResetVerifyEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return const Right(null);
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        return Left(ValidationFailure(
          error['message'] as String? ?? 'Invalid or expired token',
        ));
      } else {
        return Left(NetworkFailure(
          'Failed to reset password: ${response.statusCode}',
          response.statusCode,
        ));
      }
    } catch (e) {
      return Left(NetworkFailure('Network error: ${e.toString()}'));
    }
  }

  /// Delete user account
  static Future<AuthResult<void>> deleteAccount() async {
    try {
      final accessToken = await TokenStorage.getAccessToken();
      if (accessToken == null) {
        return Left(AuthenticationFailure('Not authenticated'));
      }

      final response = await http.delete(
        Uri.parse('$_baseUrl$_deleteAccountEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Clear tokens after successful deletion
        await TokenStorage.clearTokens();
        return const Right(null);
      } else if (response.statusCode == 401) {
        return Left(AuthenticationFailure('Session expired. Please login again'));
      } else {
        return Left(NetworkFailure(
          'Failed to delete account: ${response.statusCode}',
          response.statusCode,
        ));
      }
    } catch (e) {
      return Left(NetworkFailure('Network error: ${e.toString()}'));
    }
  }

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    return await TokenStorage.hasTokens();
  }
}

