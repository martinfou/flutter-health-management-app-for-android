// Dart SDK
import 'package:flutter/material.dart';

// Packages
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/widgets/empty_state_widget.dart';
import 'package:health_app/features/health_tracking/presentation/providers/health_metrics_provider.dart';
import 'package:health_app/features/analytics/presentation/widgets/weekly_review_insights_widget.dart';

/// Analytics/Progress page showing health trends and insights
class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final metricsAsync = ref.watch(healthMetricsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress & Analytics'),
      ),
      body: metricsAsync.when(
        data: (metrics) {
          if (metrics.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.trending_up,
              title: 'No Data Yet',
              description: 'Start tracking your health metrics to see progress and analytics.',
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(UIConstants.screenPaddingHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const WeeklyReviewInsightsWidget(),
                const SizedBox(height: UIConstants.spacingLg),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(UIConstants.cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Progress Overview',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: UIConstants.spacingMd),
                        Text(
                          'Analytics features are coming soon. In the meantime, '
                          'you can view detailed trends in each feature module.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: UIConstants.spacingLg),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(UIConstants.cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Metrics Recorded',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: UIConstants.spacingSm),
                        Text(
                          '${metrics.length}',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(UIConstants.spacingLg),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(UIConstants.spacingLg),
            child: Text(
              'Error loading analytics: ${error.toString()}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

