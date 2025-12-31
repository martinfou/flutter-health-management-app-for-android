// Dart SDK
import 'package:flutter/material.dart';

// Project
import 'package:health_app/core/pages/main_navigation_page.dart';
import 'package:health_app/features/health_tracking/presentation/pages/health_tracking_page.dart';
import 'package:health_app/features/nutrition_management/presentation/pages/nutrition_page.dart';
import 'package:health_app/features/exercise_management/presentation/pages/exercise_page.dart';
import 'package:health_app/features/medication_management/presentation/pages/medication_page.dart';
import 'package:health_app/features/behavioral_support/presentation/pages/behavioral_support_page.dart';
import 'package:health_app/core/pages/settings_page.dart';
import 'package:health_app/core/pages/analytics_page.dart';
import 'package:health_app/core/pages/export_page.dart';
import 'package:health_app/core/pages/import_page.dart';

/// Route names for navigation
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String healthTracking = '/health-tracking';
  static const String nutrition = '/nutrition';
  static const String exercise = '/exercise';
  static const String medication = '/medication';
  static const String behavioral = '/behavioral';
  static const String analytics = '/analytics';
  static const String settings = '/settings';
  static const String export = '/export';
  static const String import = '/import';
}

/// App router configuration for navigation
class AppRouter {
  AppRouter._();

  /// Get route configuration for MaterialApp
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const MainNavigationPage(),
          settings: settings,
        );
      case AppRoutes.healthTracking:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const HealthTrackingPage(),
          settings: settings,
        );
      case AppRoutes.nutrition:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const NutritionPage(),
          settings: settings,
        );
      case AppRoutes.exercise:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const ExercisePage(),
          settings: settings,
        );
      case AppRoutes.medication:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const MedicationPage(),
          settings: settings,
        );
      case AppRoutes.behavioral:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const BehavioralSupportPage(),
          settings: settings,
        );
      case AppRoutes.analytics:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const AnalyticsPage(),
          settings: settings,
        );
      case AppRoutes.settings:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const SettingsPage(),
          settings: settings,
        );
      case AppRoutes.export:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const ExportPage(),
          settings: settings,
        );
      case AppRoutes.import:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const ImportPage(),
          settings: settings,
        );
      default:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const MainNavigationPage(),
          settings: settings,
        );
    }
  }

  /// Navigate to a route by name
  static void navigateTo(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  /// Navigate to a route and replace current route
  static void navigateToReplacement(BuildContext context, String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }

  /// Navigate back
  static void navigateBack(BuildContext context) {
    Navigator.pop(context);
  }
}

