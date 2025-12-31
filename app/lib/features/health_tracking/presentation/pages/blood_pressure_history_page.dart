import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/widgets/delete_confirmation_dialog.dart';
import 'package:health_app/features/health_tracking/domain/usecases/delete_health_metric.dart';
import 'package:health_app/features/health_tracking/presentation/pages/blood_pressure_entry_page.dart';
import 'package:health_app/features/health_tracking/presentation/providers/health_metrics_provider.dart' as providers;
import 'package:health_app/features/health_tracking/presentation/providers/health_tracking_repository_provider.dart';

/// Blood pressure history page showing all blood pressure entries
class BloodPressureHistoryPage extends ConsumerWidget {
  const BloodPressureHistoryPage({super.key});

  String _getBPInterpretation(int systolic, int diastolic) {
    if (systolic < 120 && diastolic < 80) {
      return 'Normal';
    } else if (systolic >= 120 && systolic <= 129 && diastolic < 80) {
      return 'Elevated';
    } else if ((systolic >= 130 && systolic <= 139) || (diastolic >= 80 && diastolic <= 89)) {
      return 'High Stage 1';
    } else {
      return 'High Stage 2';
    }
  }

  Color _getBPInterpretationColor(int systolic, int diastolic) {
    if (systolic < 120 && diastolic < 80) {
      return Colors.green;
    } else if (systolic >= 120 && systolic <= 129 && diastolic < 80) {
      return Colors.orange;
    } else if ((systolic >= 130 && systolic <= 139) || (diastolic >= 80 && diastolic <= 89)) {
      return Colors.red.shade300;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final metricsAsync = ref.watch(providers.healthMetricsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Pressure History'),
      ),
      body: metricsAsync.when(
        data: (metrics) {
          // Filter to only blood pressure metrics and sort by date descending
          final bpMetrics = metrics
              .where((m) => m.systolicBP != null && m.diastolicBP != null)
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date));

          if (bpMetrics.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.monitor_heart_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: UIConstants.spacingMd),
                  Text(
                    'No blood pressure entries yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: UIConstants.spacingSm),
                  Text(
                    'Start logging your blood pressure to see history here',
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
            itemCount: bpMetrics.length,
            itemBuilder: (context, index) {
              final metric = bpMetrics[index];
              final systolic = metric.systolicBP!;
              final diastolic = metric.diastolicBP!;
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
              final interpretation = _getBPInterpretation(systolic, diastolic);
              final interpretationColor = _getBPInterpretationColor(systolic, diastolic);

              return Card(
                margin: const EdgeInsets.only(bottom: UIConstants.spacingMd),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: interpretationColor.withValues(alpha: 0.2),
                    child: Icon(
                      Icons.monitor_heart,
                      color: interpretationColor,
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        '$systolic/$diastolic',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: UIConstants.spacingSm),
                      Text(
                        'mmHg',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
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
                      const SizedBox(height: UIConstants.spacingXs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: UIConstants.spacingSm,
                          vertical: UIConstants.spacingXs / 2,
                        ),
                        decoration: BoxDecoration(
                          color: interpretationColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(UIConstants.borderRadiusSm),
                        ),
                        child: Text(
                          interpretation,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: interpretationColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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
                            builder: (context) => BloodPressureEntryPage(metricId: metric.id),
                          ),
                        );
                        // Refresh provider after returning from edit
                        ref.invalidate(providers.healthMetricsProvider);
                      } else if (value == 'delete') {
                        // Show delete confirmation
                        final confirmed = await DeleteConfirmationDialog.show(
                          context,
                          title: 'Delete Blood Pressure Entry',
                          message: 'Are you sure you want to delete this blood pressure entry?',
                          details: '$systolic/$diastolic mmHg on ${dateFormat.format(metric.date)}',
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
                                    content: Text('Blood pressure entry deleted successfully'),
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
                        builder: (context) => BloodPressureEntryPage(metricId: metric.id),
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
