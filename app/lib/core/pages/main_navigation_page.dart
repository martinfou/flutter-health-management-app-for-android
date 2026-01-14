// Dart SDK
import 'package:flutter/material.dart';

// Packages
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project
import 'package:health_app/core/pages/home_page.dart';
import 'package:health_app/core/pages/analytics_page.dart';
import 'package:health_app/core/pages/settings_page.dart';
import 'package:health_app/core/sync/background_sync_service.dart';
import 'package:health_app/core/widgets/protected_route.dart';
import 'package:health_app/core/widgets/sync_button_widget.dart';
import 'package:health_app/features/health_tracking/presentation/pages/health_tracking_page.dart';
import 'package:health_app/features/nutrition_management/presentation/pages/nutrition_page.dart';
import 'package:health_app/features/exercise_management/presentation/pages/exercise_page.dart';

/// Navigation item enum
enum NavigationItem {
  home,
  health,
  nutrition,
  exercise,
  progress,
  more;

  String get label {
    switch (this) {
      case NavigationItem.home:
        return 'Home';
      case NavigationItem.health:
        return 'Health';
      case NavigationItem.nutrition:
        return 'Nutrition';
      case NavigationItem.exercise:
        return 'Exercise';
      case NavigationItem.progress:
        return 'Progress';
      case NavigationItem.more:
        return 'More';
    }
  }

  IconData get icon {
    switch (this) {
      case NavigationItem.home:
        return Icons.home;
      case NavigationItem.health:
        return Icons.favorite;
      case NavigationItem.nutrition:
        return Icons.restaurant;
      case NavigationItem.exercise:
        return Icons.fitness_center;
      case NavigationItem.progress:
        return Icons.trending_up;
      case NavigationItem.more:
        return Icons.more_horiz;
    }
  }
}

/// Provider for current navigation index
final navigationIndexProvider = StateProvider<int>((ref) => 0);

/// Main navigation page with bottom navigation bar
class MainNavigationPage extends ConsumerStatefulWidget {
  const MainNavigationPage({super.key});

  @override
  ConsumerState<MainNavigationPage> createState() =>
      _MainNavigationPageState();
}

class _MainNavigationPageState extends ConsumerState<MainNavigationPage> {
  final List<Widget> _pages = const [
    HomePage(),
    HealthTrackingPage(),
    NutritionPage(),
    ExercisePage(),
    AnalyticsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationIndexProvider);

    // Initialize background sync service
    ref.watch(backgroundSyncProvider);

    return ProtectedRoute(
      child: Scaffold(
        appBar: AppBar(
          title: Text(NavigationItem.values[currentIndex].label),
          actions: const [
            SyncButtonWidget(),
          ],
        ),
        body: IndexedStack(
          index: currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            ref.read(navigationIndexProvider.notifier).state = index;
          },
          destinations: NavigationItem.values.map((item) {
            return NavigationDestination(
              icon: Icon(item.icon),
              label: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}

