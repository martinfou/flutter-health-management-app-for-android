import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/widgets/delete_confirmation_dialog.dart';
import 'package:health_app/features/health_tracking/domain/usecases/delete_health_metric.dart';
import 'package:health_app/features/health_tracking/presentation/pages/weight_entry_page.dart';
import 'package:health_app/features/health_tracking/presentation/providers/health_metrics_provider.dart' as providers;
import 'package:health_app/features/health_tracking/presentation/providers/health_tracking_repository_provider.dart';

/// Weight history page showing all weight entries
class WeightHistoryPage extends ConsumerWidget {
  const WeightHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final metricsAsync = ref.watch(providers.healthMetricsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weight History'),
      ),
      body: metricsAsync.when(
        data: (metrics) {
          // Filter to only weight metrics and sort by date descending
          final weightMetrics = metrics
              .where((m) => m.weight != null)
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date));

          if (weightMetrics.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.scale_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: UIConstants.spacingMd),
                  Text(
                    'No weight entries yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: UIConstants.spacingSm),
                  Text(
                    'Start logging your weight to see history here',
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
            itemCount: weightMetrics.length,
            itemBuilder: (context, index) {
              final metric = weightMetrics[index];
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
                      Icons.scale,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(
                    '${metric.weight!.toStringAsFixed(1)} kg',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    isToday
                        ? 'Today at ${timeFormat.format(metric.createdAt)}'
                        : dateFormat.format(metric.date),
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    onSelected: (value) async {
                      if (value == 'edit') {
                        // Navigate to edit mode
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => WeightEntryPage(metricId: metric.id),
                          ),
                        );
                        // Refresh provider after returning from edit
                        ref.invalidate(providers.healthMetricsProvider);
                      } else if (value == 'delete') {
                        // Show delete confirmation
                        final confirmed = await DeleteConfirmationDialog.show(
                          context,
                          title: 'Delete Weight Entry',
                          message: 'Are you sure you want to delete this weight entry?',
                          details: '${metric.weight!.toStringAsFixed(1)} kg on ${dateFormat.format(metric.date)}',
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
                                    content: Text('Weight entry deleted successfully'),
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
                  onTap: () async {
                    // Navigate to edit mode on tap
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => WeightEntryPage(metricId: metric.id),
                      ),
                    );
                    // Refresh provider after returning from edit
                    ref.invalidate(providers.healthMetricsProvider);
                  },
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

