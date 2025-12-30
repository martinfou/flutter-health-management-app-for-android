// Dart SDK
import 'package:flutter/material.dart';

// Packages
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/navigation/app_router.dart';
import 'package:health_app/core/widgets/safety_alert_widget.dart';
import 'package:health_app/features/behavioral_support/presentation/pages/habit_tracking_page.dart';
import 'package:health_app/features/health_tracking/presentation/providers/health_metrics_provider.dart';
import 'package:health_app/features/nutrition_management/presentation/providers/nutrition_providers.dart';
import 'package:health_app/features/nutrition_management/domain/usecases/calculate_macros.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';

/// Home page with overview of health metrics and quick actions
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final metricsAsync = ref.watch(healthMetricsProvider);
    final today = DateTime.now();
    final dateOnly = DateTime(today.year, today.month, today.day);

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.screenPaddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Safety alerts
            const SafetyAlertWidget(),
            
            // Welcome message
            Card(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingSm),
                    Text(
                      'Today is a great day to track your progress.',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: UIConstants.spacingLg),

            // Quick Actions
            Text(
              'Quick Actions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: UIConstants.spacingMd),
            _buildQuickActions(context),

            const SizedBox(height: UIConstants.spacingLg),

            // Today's Summary
            Text(
              'Today\'s Summary',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: UIConstants.spacingMd),
            metricsAsync.when(
              data: (metrics) {
                final macroSummary = ref.watch(macroSummaryProvider(dateOnly));
                return _buildTodaySummary(
                  context,
                  metrics,
                  macroSummary,
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
                    'Error loading summary: ${error.toString()}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: UIConstants.spacingMd,
      crossAxisSpacing: UIConstants.spacingMd,
      childAspectRatio: 1.0,
      children: [
        _buildQuickActionButton(
          context,
          'Weight',
          Icons.monitor_weight,
          () => AppRouter.navigateTo(context, AppRoutes.healthTracking),
        ),
        _buildQuickActionButton(
          context,
          'Sleep',
          Icons.bedtime,
          () => AppRouter.navigateTo(context, AppRoutes.healthTracking),
        ),
        _buildQuickActionButton(
          context,
          'Energy',
          Icons.battery_charging_full,
          () => AppRouter.navigateTo(context, AppRoutes.healthTracking),
        ),
        _buildQuickActionButton(
          context,
          'Meals',
          Icons.restaurant,
          () => AppRouter.navigateTo(context, AppRoutes.nutrition),
        ),
        _buildQuickActionButton(
          context,
          'Workout',
          Icons.fitness_center,
          () => AppRouter.navigateTo(context, AppRoutes.exercise),
        ),
        _buildQuickActionButton(
          context,
          'Medication',
          Icons.medication_liquid,
          () => AppRouter.navigateTo(context, AppRoutes.medication),
        ),
        _buildQuickActionButton(
          context,
          'Habits',
          Icons.check_circle,
          () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const HabitTrackingPage(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(UIConstants.borderRadiusMd),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusMd),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: UIConstants.spacingSm),
            Text(
              label,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySummary(
    BuildContext context,
    List<HealthMetric> metrics,
    MacroSummary macroSummary,
  ) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    HealthMetric? todayMetric;
    try {
      todayMetric = metrics.firstWhere(
        (m) {
          final metricDate = DateTime(m.date.year, m.date.month, m.date.day);
          return metricDate == todayDate;
        },
      );
    } catch (_) {
      todayMetric = null;
    }

    final latestWeight = metrics
        .where((m) => m.weight != null)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final latestWeightMetric = latestWeight.isNotEmpty ? latestWeight.first : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (latestWeightMetric != null) ...[
              _buildSummaryRow(
                context,
                'Weight',
                latestWeightMetric.weight != null
                    ? '${latestWeightMetric.weight!.toStringAsFixed(1)} kg'
                    : 'Not recorded',
              ),
              const Divider(),
            ],
            _buildSummaryRow(
              context,
              'Macros',
              '${macroSummary.protein.toStringAsFixed(0)}g P | '
              '${macroSummary.fats.toStringAsFixed(0)}g F | '
              '${macroSummary.netCarbs.toStringAsFixed(0)}g C',
            ),
            const Divider(),
            if (todayMetric != null) ...[
              if (todayMetric.sleepQuality != null)
                _buildSummaryRow(
                  context,
                  'Sleep',
                  '${todayMetric.sleepQuality!.toStringAsFixed(1)}/10',
                ),
              if (todayMetric.energyLevel != null) ...[
                if (todayMetric.sleepQuality != null) const Divider(),
                _buildSummaryRow(
                  context,
                  'Energy',
                  '${todayMetric.energyLevel!.toStringAsFixed(0)}/10',
                ),
              ],
            ] else
              Text(
                'No metrics recorded today',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: UIConstants.spacingXs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning!';
    } else if (hour < 17) {
      return 'Good Afternoon!';
    } else {
      return 'Good Evening!';
    }
  }
}

