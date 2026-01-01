// Dart SDK
import 'package:flutter/material.dart';

// Packages
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project
import 'package:health_app/core/navigation/app_router.dart';
import 'package:health_app/core/pages/main_navigation_page.dart';
import 'package:health_app/core/pages/login_page.dart';
import 'package:health_app/core/providers/database_initializer.dart';
import 'package:health_app/core/providers/auth_provider.dart';
import 'package:health_app/core/constants/auth_config.dart';
import 'package:health_app/core/errors/error_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive database
  final initResult = await DatabaseInitializer.initialize();
  initResult.fold(
    (failure) {
      // Log error but don't crash - app can still run
      ErrorHandler.logError(
        failure,
        context: 'main',
      );
    },
    (_) {
      // Database initialized successfully
    },
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If authentication is disabled, skip auth check and go directly to main navigation
    if (!AuthConfig.isEnabled(ref)) {
      return MaterialApp(
        title: 'Health Management App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MainNavigationPage(),
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: AppRoutes.home,
      );
    }

    // Watch authentication state to determine initial route
    final authState = ref.watch(authStateProvider);

    // Show loading screen while checking authentication
    if (authState.isLoading && !authState.isAuthenticated) {
      return MaterialApp(
        title: 'Health Management App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Health Management App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Show login page if not authenticated, otherwise show main navigation
      home: authState.isAuthenticated
          ? const MainNavigationPage()
          : const LoginPage(),
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: authState.isAuthenticated
          ? AppRoutes.home
          : AppRoutes.login,
    );
  }
}

