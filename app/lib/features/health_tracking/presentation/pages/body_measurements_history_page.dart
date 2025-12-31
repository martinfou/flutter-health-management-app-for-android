import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/widgets/delete_confirmation_dialog.dart';
import 'package:health_app/features/health_tracking/domain/usecases/delete_health_metric.dart';
import 'package:health_app/features/health_tracking/presentation/pages/measurements_page.dart';
import 'package:health_app/features/health_tracking/presentation/providers/health_metrics_provider.dart' as providers;
import 'package:health_app/features/health_tracking/presentation/providers/health_tracking_repository_provider.dart';
import 'package:health_app/core/providers/user_preferences_provider.dart';
import 'package:health_app/core/utils/format_utils.dart';

/// Body measurements history page showing all body measurement entries
class BodyMeasurementsHistoryPage extends ConsumerWidget {
  const BodyMeasurementsHistoryPage({super.key});

  String _getMeasurementLabel(String key) {
    switch (key.toLowerCase()) {
      case 'waist':
        return 'Waist';
      case 'hips':
        return 'Hips';
      case 'neck':
        return 'Neck';
      case 'chest':
        return 'Chest';
      case 'thigh':
        return 'Thigh';
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final metricsAsync = ref.watch(providers.healthMetricsProvider);
    final useImperial = ref.watch(unitPreferenceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Measurements History'),
      ),
      body: metricsAsync.when(
        data: (metrics) {
          // Filter to only body measurement metrics and sort by date descending
          final measurementMetrics = metrics
              .where((m) => m.bodyMeasurements != null && m.bodyMeasurements!.isNotEmpty)
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date));

          if (measurementMetrics.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.straighten_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: UIConstants.spacingMd),
                  Text(
                    'No body measurement entries yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: UIConstants.spacingSm),
                  Text(
                    'Start logging your body measurements to see history here',
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
            itemCount: measurementMetrics.length,
            itemBuilder: (context, index) {
              final metric = measurementMetrics[index];
              final measurements = metric.bodyMeasurements!;
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

              // Sort measurement keys for consistent display
              final sortedKeys = measurements.keys.toList()
                ..sort((a, b) => a.compareTo(b));

              return InkWell(
                onTap: () async {
                  // Navigate to edit mode on tap
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MeasurementsPage(metricId: metric.id),
                    ),
                  );
                  // Refresh provider after returning from edit
                  ref.invalidate(providers.healthMetricsProvider);
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: UIConstants.spacingMd),
                  child: Padding(
                    padding: const EdgeInsets.all(UIConstants.cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date header
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: theme.colorScheme.primaryContainer,
                              child: Icon(
                                Icons.straighten,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(width: UIConstants.spacingMd),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isToday
                                        ? 'Today at ${timeFormat.format(metric.createdAt)}'
                                        : dateFormat.format(metric.date),
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (!isToday)
                                    Text(
                                      timeFormat.format(metric.createdAt),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                            icon: Icon(
                              Icons.more_vert,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            onSelected: (value) async {
                              if (value == 'edit') {
                                // Navigate to edit mode
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => MeasurementsPage(metricId: metric.id),
                                  ),
                                );
                                // Refresh provider after returning from edit
                                ref.invalidate(providers.healthMetricsProvider);
                              } else if (value == 'delete') {
                                // Show delete confirmation
                                final measurementsText = sortedKeys
                                    .map((key) => '${_getMeasurementLabel(key)}: ${FormatUtils.formatLengthValue(measurements[key]!, useImperial)}')
                                    .join(', ');
                                
                                final confirmed = await DeleteConfirmationDialog.show(
                                  context,
                                  title: 'Delete Body Measurements Entry',
                                  message: 'Are you sure you want to delete this entry?',
                                  details: '${measurementsText} • ${dateFormat.format(metric.date)}',
                                );

                                if (confirmed && context.mounted) {
                                  // Delete the metric
                                  final repository = ref.read(healthTrackingRepositoryProvider);
                                  final useCase = DeleteHealthMetricUseCase(repository);
                                  final result = await useCase(metric.id);

                                  result.fold(
                                    (failure) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Failed to delete: ${failure.message}'),
                                            backgroundColor: theme.colorScheme.error,
                                          ),
                                        );
                                      }
                                    },
                                    (_) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Entry deleted successfully'),
                                          ),
                                        );
                                      }
                                      // Refresh provider
                                      ref.invalidate(providers.healthMetricsProvider);
                                    },
                                  );
                                }
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem<String>(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit),
                                    SizedBox(width: UIConstants.spacingSm),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      color: theme.colorScheme.error,
                                    ),
                                    const SizedBox(width: UIConstants.spacingSm),
                                    Text(
                                      'Delete',
                                      style: TextStyle(color: theme.colorScheme.error),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: UIConstants.spacingMd),
                      // Measurements grid
                      Wrap(
                        spacing: UIConstants.spacingMd,
                        runSpacing: UIConstants.spacingMd,
                        children: sortedKeys.map((key) {
                          final value = measurements[key]!;
                          return Container(
                            padding: const EdgeInsets.all(UIConstants.spacingSm),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(UIConstants.borderRadiusSm),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _getMeasurementLabel(key),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                                Text(
                                  FormatUtils.formatLengthValue(value, useImperial),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      // Notes if available
                      if (metric.notes != null && metric.notes!.isNotEmpty) ...[
                        const SizedBox(height: UIConstants.spacingMd),
                        Container(
                          padding: const EdgeInsets.all(UIConstants.spacingSm),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(UIConstants.borderRadiusSm),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.note_outlined,
                                size: 16,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: UIConstants.spacingXs),
                              Expanded(
                                child: Text(
                                  metric.notes!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      ],
                    ),
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
