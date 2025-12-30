import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/features/health_tracking/presentation/providers/health_metrics_provider.dart' as providers;

/// Heart rate history page showing all heart rate entries
class HeartRateHistoryPage extends ConsumerWidget {
  const HeartRateHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final metricsAsync = ref.watch(providers.healthMetricsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Heart Rate History'),
      ),
      body: metricsAsync.when(
        data: (metrics) {
          // Filter to only heart rate metrics and sort by date descending
          final heartRateMetrics = metrics
              .where((m) => m.restingHeartRate != null)
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date));

          if (heartRateMetrics.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_outline,
                    size: 64,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: UIConstants.spacingMd),
                  Text(
                    'No heart rate entries yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: UIConstants.spacingSm),
                  Text(
                    'Start logging your heart rate to see history here',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(UIConstants.screenPaddingHorizontal),
            itemCount: heartRateMetrics.length,
            itemBuilder: (context, index) {
              final metric = heartRateMetrics[index];
              final dateFormat = DateFormat('MMMM d, yyyy');
              final timeFormat = DateFormat('h:mm a');
              final isToday = DateTime(
                metric.date.year,
                metric.date.month,
                metric.date.day,
              ) ==
                  DateTime(
                    DateTime.now().year,
                    DateTime.now().month,
                    DateTime.now().day,
                  );

              return Card(
                margin: const EdgeInsets.only(bottom: UIConstants.spacingMd),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.errorContainer,
                    child: Icon(
                      Icons.favorite,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                  title: Text(
                    '${metric.restingHeartRate} BPM',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isToday
                            ? 'Today at ${timeFormat.format(metric.createdAt)}'
                            : dateFormat.format(metric.date),
                      ),
                      if (metric.notes != null && metric.notes!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: UIConstants.spacingXs),
                          child: Text(
                            metric.notes!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                    ],
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading data: $error'),
        ),
      ),
    );
  }
}
