import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:health_app/core/pages/login_page.dart';
import 'package:health_app/core/providers/auth_provider.dart';
import 'package:health_app/core/utils/validation_utils.dart';

@GenerateNiceMocks([MockSpec<AuthStateNotifier>()])
void main() {
  late MockAuthStateNotifier mockAuthProvider;
  late NavigatorObserver mockNavigator;

  setUp(() {
    mockAuthProvider = MockAuthStateNotifier();
    mockNavigator = MockNavigatorObserver();
  });

  tearDown(() {
    mockAuthProvider.dispose();
  });

  group('LoginPage Widget Tests', () {
    testWidgets('displays login form', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: const LoginPage(),
      ));

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in to continue'), findsOneWidget);
      expect(find.byType(TextFormField), findsWidgets);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('email validation shows error when empty', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: const LoginPage(),
      ));

      await tester.enterText(find.byKey(const Key('emailField')), '');
      await tester.tap(find.byType(ElevatedButton));

      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('password validation shows error when empty', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: const LoginPage(),
      ));

      final passwordField = find.byKey(const Key('passwordField'));
      await tester.enterText(passwordField, '');

      await tester.tap(find.byType(ElevatedButton));

      await tester.pumpAndSettle();

      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('loading state shows when authenticating', (tester) async {
      when(() => mockAuthProvider.stream).thenAnswer(
          (_) => const AuthState(isAuthenticated: false, isLoading: true));

      await tester.pumpWidget(MaterialApp(
        home: const LoginPage(),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Signing in...'), findsNothing);
    });

    testWidgets('shows error when login fails', (tester) async {
      const errorMessage = 'Invalid email or password';

      when(() => mockAuthProvider.stream).thenAnswer((_) => const AuthState(
            isAuthenticated: false,
            isLoading: false,
            error: errorMessage,
          ));

      await tester.pumpWidget(MaterialApp(
        home: const LoginPage(),
      ));

      await tester.pumpAndSettle();

      expect(find.text(errorMessage), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('forgot password link navigates to reset page', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: const LoginPage(),
      ));

      await tester.tap(find.text('Forgot Password?'));

      await tester.pumpAndSettle();

      expect(
          mockNavigator.pushNamedAndRemoveUntil(
              any, any, '/password-reset-request'),
          calledOnce);
    });

    testWidgets('sign up link navigates to registration page', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: const LoginPage(),
      ));

      await tester.tap(find.text('Sign Up'));

      await tester.pumpAndSettle();

      expect(mockNavigator.pushNamedAndRemoveUntil(any, any, '/registration'),
          calledOnce);
    });
  });
}
