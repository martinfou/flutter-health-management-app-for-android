// Dart SDK
import 'package:flutter/material.dart';

// Packages
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/navigation/app_router.dart';
import 'package:health_app/core/widgets/safety_alert_widget.dart';
import 'package:health_app/core/widgets/welcome_card_widget.dart';
import 'package:health_app/core/widgets/what_next_card_widget.dart';
import 'package:health_app/core/widgets/progress_bar_widget.dart';
import 'package:health_app/core/widgets/metric_check_grid_widget.dart';
import 'package:health_app/core/widgets/quick_access_grid_widget.dart';
import 'package:health_app/core/providers/home_screen_providers.dart';
import 'package:health_app/core/entities/recommended_action.dart';
import 'package:health_app/features/health_tracking/presentation/pages/weight_entry_page.dart';
import 'package:health_app/features/health_tracking/presentation/pages/sleep_energy_page.dart';
import 'package:health_app/features/health_tracking/presentation/pages/heart_rate_entry_page.dart';
import 'package:health_app/features/health_tracking/presentation/pages/blood_pressure_entry_page.dart';

/// Home page with priority-based stack layout
/// 
/// Displays:
/// - Safety alerts (if any)
/// - Welcome message
/// - "What's Next?" section with recommended actions
/// - "Today's Progress" section with progress bar and metric grid
/// - "Quick Access" section for feature navigation
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final whatNextAsync = ref.watch(whatNextProvider);
    final progressAsync = ref.watch(dailyProgressProvider);
    final statusAsync = ref.watch(metricStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              AppRouter.navigateTo(context, AppRoutes.settings);
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Invalidate all home screen providers to refresh data
          ref.invalidate(whatNextProvider);
          ref.invalidate(dailyProgressProvider);
          ref.invalidate(metricStatusProvider);
          // Wait for providers to refresh
          await ref.read(whatNextProvider.future);
          await ref.read(dailyProgressProvider.future);
          await ref.read(metricStatusProvider.future);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(UIConstants.screenPaddingHorizontal),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Safety alerts
            const SafetyAlertWidget(),

            const SizedBox(height: UIConstants.spacingLg),

            // Welcome message
            const WelcomeCardWidget(),

            const SizedBox(height: UIConstants.spacingLg),

            // "What's Next?" section
            Text(
              '🎯 What\'s Next?',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: UIConstants.spacingMd),
            whatNextAsync.when(
              data: (actions) {
                if (actions.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(UIConstants.cardPadding),
                      child: Text(
                        'Great job! You\'re all caught up.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return Column(
                  children: actions.map((action) {
                    return WhatNextCardWidget(
                      action: action,
                      onTap: () => _handleRecommendedAction(context, action),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(UIConstants.spacingLg),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(UIConstants.cardPadding),
                  child: Text(
                    'Error loading recommendations: ${error.toString()}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: UIConstants.spacingLg),

            // "Today's Progress" section
            Text(
              '📊 Today\'s Progress',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: UIConstants.spacingMd),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    progressAsync.when(
                      data: (progress) => ProgressBarWidget(progress: progress),
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(UIConstants.spacingMd),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (error, stack) => Text(
                        'Error loading progress',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingMd),
                    statusAsync.when(
                      data: (status) => MetricCheckGridWidget(status: status),
                      loading: () => const SizedBox.shrink(),
                      error: (error, stack) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: UIConstants.spacingLg),

            // "Quick Access" section
            Text(
              '🚀 Quick Access',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: UIConstants.spacingMd),
            const QuickAccessGridWidget(),

            const SizedBox(height: UIConstants.spacingLg),
          ],
          ),
        ),
      ),
    );
  }

  /// Handle recommended action tap
  void _handleRecommendedAction(
    BuildContext context,
    RecommendedAction action,
  ) {
    switch (action.type) {
      case RecommendedActionType.logWeight:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const WeightEntryPage(),
          ),
        );
        break;
      case RecommendedActionType.logSleep:
      case RecommendedActionType.logEnergy:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const SleepEnergyPage(),
          ),
        );
        break;
      case RecommendedActionType.logHeartRate:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const HeartRateEntryPage(),
          ),
        );
        break;
      case RecommendedActionType.logBloodPressure:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const BloodPressureEntryPage(),
          ),
        );
        break;
      case RecommendedActionType.takeMedication:
        // Navigate to medication page
        AppRouter.navigateTo(context, AppRoutes.medication);
        break;
      case RecommendedActionType.logMeal:
        AppRouter.navigateTo(context, AppRoutes.nutrition);
        break;
      case RecommendedActionType.logWorkout:
        AppRouter.navigateTo(context, AppRoutes.exercise);
        break;
      case RecommendedActionType.completeHabit:
        AppRouter.navigateTo(context, AppRoutes.behavioral);
        break;
      case RecommendedActionType.logMeasurements:
        // Navigate to health tracking page for measurements
        AppRouter.navigateTo(context, AppRoutes.healthTracking);
        break;
    }
  }
}
