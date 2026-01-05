import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:health_app/core/network/authentication_service.dart';
import 'package:health_app/core/network/token_storage.dart';

@GenerateMocks([TokenStorage])
void main() {
  group('AuthenticationService - Registration', () {
    test('register successful saves tokens', () async {
      final mockStorage = MockTokenStorage();

      when(mockStorage.saveAccessToken(any)).thenAnswer((_) async {});
      when(mockStorage.saveRefreshToken(any)).thenAnswer((_) async {});
      when(mockStorage.hasTokens()).thenAnswer((_) async => true);

      when(mockStorage.getAccessToken()).thenAnswer((_) async => 'test-token');

      final result = await AuthenticationService.register(
        email: 'test@example.com',
        password: 'SecurePass123!',
        name: 'Test User',
      );

      expect(result.isRight(), true);
    });

    test('register with existing email returns validation failure', () async {
      final mockStorage = MockTokenStorage();

      when(mockStorage.hasTokens()).thenAnswer((_) async => false);

      final result = await AuthenticationService.register(
        email: 'test@example.com',
        password: 'SecurePass123!',
      );

      expect(result.isLeft(), true);
      expect(result.getLeft(), isA<ValidationFailure>());
      expect(result.getLeft().message, contains('already registered'));
    });
  });

  group('AuthenticationService - Login', () {
    test('login successful saves tokens', () async {
      final mockStorage = MockTokenStorage();

      when(mockStorage.saveAccessToken(any)).thenAnswer((_) async {});
      when(mockStorage.saveRefreshToken(any)).thenAnswer((_) async {});

      final result = await AuthenticationService.login(
        email: 'test@example.com',
        password: 'SecurePass123!',
      );

      expect(result.isRight(), true);
    });

    test('login with invalid credentials returns authentication failure',
        () async {
      final result = await AuthenticationService.login(
        email: 'test@example.com',
        password: 'WrongPassword!',
      );

      expect(result.isLeft(), true);
      expect(result.getLeft(), isA<AuthenticationFailure>());
    });

    test('login with network error returns network failure', () async {
      final result = await AuthenticationService.login(
        email: 'test@example.com',
        password: 'SecurePass123!',
      );

      expect(result.isLeft(), true);
      expect(result.getLeft(), isA<NetworkFailure>());
    });
  });

  group('AuthenticationService - Token Refresh', () {
    test('refresh token successful saves new tokens', () async {
      final mockStorage = MockTokenStorage();

      final newToken = 'new-access-token-123';
      final newRefreshToken = 'new-refresh-token-456';

      when(mockStorage.getRefreshToken())
          .thenAnswer((_) async => 'old-refresh-token');
      when(mockStorage.saveAccessToken(any)).thenAnswer((_) async {});
      when(mockStorage.saveRefreshToken(any)).thenAnswer((_) async {});

      final result = await AuthenticationService.refreshToken();

      expect(result.isRight(), true);
      expect(result.getRight(), equals(newToken));
    });

    test('refresh token with invalid token returns authentication failure',
        () async {
      final mockStorage = MockTokenStorage();

      when(mockStorage.getRefreshToken())
          .thenAnswer((_) async => 'invalid-refresh-token');

      final result = await AuthenticationService.refreshToken();

      expect(result.isLeft(), true);
      verify(mockStorage.saveAccessToken(any)).called(1);
    });

    test('refresh token with no refresh token returns authentication failure',
        () async {
      final mockStorage = MockTokenStorage();

      when(mockStorage.getRefreshToken()).thenAnswer((_) async => null);

      final result = await AuthenticationService.refreshToken();

      expect(result.isLeft(), true);
      expect(result.getLeft(), isA<AuthenticationFailure>());
    });
  });

  group('AuthenticationService - Logout', () {
    test('logout clears tokens', () async {
      final mockStorage = MockTokenStorage();

      when(mockStorage.clearTokens()).thenAnswer((_) async {});

      final result = await AuthenticationService.logout();

      expect(result.isRight(), true);
      verify(mockStorage.clearTokens()).called(1);
    });
  });

  group('AuthenticationService - Profile Management', () {
    test('getProfile successful returns user', () async {
      final mockStorage = MockTokenStorage();

      when(mockStorage.getAccessToken()).thenAnswer((_) async => 'valid-token');

      final result = await AuthenticationService.getProfile();

      expect(result.isRight(), true);
      expect(result.getRight()!.id, equals('1'));
      expect(result.getRight()!.email, equals('test@example.com'));
    });

    test('getProfile without token returns authentication failure', () async {
      final mockStorage = MockTokenStorage();

      when(mockStorage.getAccessToken()).thenAnswer((_) async => null);

      final result = await AuthenticationService.getProfile();

      expect(result.isLeft(), true);
      expect(result.getLeft(), isA<AuthenticationFailure>());
    });

    test('updateProfile successful returns updated user', () async {
      final mockStorage = MockTokenStorage();

      when(mockStorage.getAccessToken()).thenAnswer((_) async => 'valid-token');

      final result = await AuthenticationService.updateProfile(
        name: 'Updated Name',
      );

      expect(result.isRight(), true);
      expect(result.getRight()!.name, equals('Updated Name'));
    });
  });

  group('AuthenticationService - Password Reset', () {
    test('requestPasswordReset successful', () async {
      final result = await AuthenticationService.requestPasswordReset(
        email: 'test@example.com',
      );

      expect(result.isRight(), true);
    });

    test('verifyPasswordReset successful', () async {
      final result = await AuthenticationService.verifyPasswordReset(
        token: 'reset-token-123',
        newPassword: 'NewSecurePass456!',
      );

      expect(result.isRight(), true);
    });

    test('verifyPasswordReset with invalid token returns validation failure',
        () async {
      final result = await AuthenticationService.verifyPasswordReset(
        token: 'invalid-token',
        newPassword: 'NewPass123!',
      );

      expect(result.isLeft(), true);
      expect(result.getLeft(), isA<ValidationFailure>());
    });
  });

  group('AuthenticationService - Account Deletion', () {
    test('deleteAccount successful', () async {
      final mockStorage = MockTokenStorage();

      when(mockStorage.getAccessToken()).thenAnswer((_) async => 'valid-token');

      final result = await AuthenticationService.deleteAccount();

      expect(result.isRight(), true);
      verify(mockStorage.clearTokens()).called(1);
    });

    test('deleteAccount without token returns authentication failure',
        () async {
      final mockStorage = MockTokenStorage();

      when(mockStorage.getAccessToken()).thenAnswer((_) async => null);

      final result = await AuthenticationService.deleteAccount();

      expect(result.isLeft(), true);
      expect(result.getLeft(), isA<AuthenticationFailure>());
    });
  });

  group('AuthenticationService - isAuthenticated', () {
    test('isAuthenticated returns true when tokens exist', () async {
      final mockStorage = MockTokenStorage();

      when(mockStorage.hasTokens()).thenAnswer((_) async => true);

      final result = await AuthenticationService.isAuthenticated();

      expect(result, true);
    });

    test('isAuthenticated returns false when no tokens', () async {
      final mockStorage = MockTokenStorage();

      when(mockStorage.hasTokens()).thenAnswer((_) async => false);

      final result = await AuthenticationService.isAuthenticated();

      expect(result, false);
    });
  });
}
