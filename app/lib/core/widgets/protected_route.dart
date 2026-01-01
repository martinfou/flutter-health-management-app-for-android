// Flutter
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project
import 'package:health_app/core/providers/auth_provider.dart';
import 'package:health_app/core/constants/auth_config.dart';
import 'package:health_app/core/pages/login_page.dart';

/// Protected route wrapper that requires authentication
class ProtectedRoute extends ConsumerWidget {
  final Widget child;

  const ProtectedRoute({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If authentication is disabled, allow access without checking
    if (!AuthConfig.isEnabled(ref)) {
      return child;
    }

    final authState = ref.watch(authStateProvider);

    // Show loading while checking authentication
    if (authState.isLoading && !authState.isAuthenticated) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Redirect to login if not authenticated
    if (!authState.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Use pushReplacementNamed to avoid back button issues
        if (Navigator.canPop(context)) {
          Navigator.of(context).pushReplacementNamed('/login');
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const LoginPage(),
            ),
          );
        }
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // User is authenticated, show the protected content
    return child;
  }
}

