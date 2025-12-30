import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/features/health_tracking/presentation/providers/health_metrics_provider.dart' as providers;

/// Sleep and energy history page showing all sleep/energy entries
class SleepEnergyHistoryPage extends ConsumerWidget {
  const SleepEnergyHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final metricsAsync = ref.watch(providers.healthMetricsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep & Energy History'),
      ),
      body: metricsAsync.when(
        data: (metrics) {
          // Filter to only sleep/energy metrics and sort by date descending
          final sleepEnergyMetrics = metrics
              .where((m) => m.sleepQuality != null || m.energyLevel != null)
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date));

          if (sleepEnergyMetrics.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bedtime_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: UIConstants.spacingMd),
                  Text(
                    'No sleep & energy entries yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: UIConstants.spacingSm),
                  Text(
                    'Start logging your sleep and energy to see history here',
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
            itemCount: sleepEnergyMetrics.length,
            itemBuilder: (context, index) {
              final metric = sleepEnergyMetrics[index];
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
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.bedtime,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Row(
                    children: [
                      if (metric.sleepQuality != null || metric.sleepHours != null) ...[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sleep',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                              if (metric.sleepQuality != null)
                                Text(
                                  '${metric.sleepQuality}/10',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              if (metric.sleepHours != null) ...[
                                Text(
                                  () {
                                    final hours = metric.sleepHours!;
                                    final hoursInt = hours.toInt();
                                    final minutes = (hours - hoursInt) * 60;
                                    if (minutes == 0) {
                                      return '$hoursInt hours';
                                    } else {
                                      return '$hours hours';
                                    }
                                  }(),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                      if (metric.energyLevel != null) ...[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Energy',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                              Text(
                                '${metric.energyLevel}/10',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
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
