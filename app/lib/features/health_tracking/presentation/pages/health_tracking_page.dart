import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/features/health_tracking/presentation/providers/health_metrics_provider.dart';
import 'package:health_app/features/health_tracking/presentation/providers/moving_average_provider.dart';
import 'package:health_app/features/health_tracking/presentation/widgets/dashboard_metric_card_widget.dart';
import 'package:health_app/features/health_tracking/presentation/widgets/weight_chart_widget.dart';
import 'package:health_app/features/health_tracking/presentation/pages/weight_entry_page.dart';
import 'package:health_app/features/health_tracking/presentation/pages/measurements_page.dart';
import 'package:health_app/features/health_tracking/presentation/pages/sleep_energy_page.dart';
import 'package:health_app/features/health_tracking/presentation/pages/heart_rate_entry_page.dart';
import 'package:health_app/features/health_tracking/presentation/pages/blood_pressure_entry_page.dart';
import 'package:health_app/features/health_tracking/presentation/pages/heart_rate_history_page.dart';
import 'package:health_app/features/health_tracking/presentation/pages/blood_pressure_history_page.dart';
import 'package:health_app/features/health_tracking/presentation/pages/sleep_energy_history_page.dart';
import 'package:health_app/features/health_tracking/presentation/pages/body_measurements_history_page.dart';
import 'package:health_app/features/health_tracking/presentation/pages/weight_history_page.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';
import 'package:health_app/features/health_tracking/domain/usecases/calculate_baseline_heart_rate.dart';
import 'package:health_app/core/widgets/safety_alert_widget.dart';

/// Main health tracking page with overview
class HealthTrackingPage extends ConsumerWidget {
  const HealthTrackingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final metricsAsync = ref.watch(healthMetricsProvider);
    final movingAverage = ref.watch(movingAverageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Tracking'),
      ),
      body: metricsAsync.when(
        data: (metrics) {
          final today = DateTime.now();
          final todayDate = DateTime(today.year, today.month, today.day);
          
          // Get all metrics for today
          final todayMetrics = metrics.where((m) {
            final metricDate = DateTime(m.date.year, m.date.month, m.date.day);
            return metricDate == todayDate;
          }).toList();
          
          // Get latest metric for each type for today (sorted by createdAt desc)
          HealthMetric? todaySleepEnergyMetric;
          HealthMetric? todayHeartRateMetric;
          HealthMetric? todayBloodPressureMetric;
          
          if (todayMetrics.isNotEmpty) {
            
            // Latest sleep/energy for today
            final sleepEnergyMetrics = todayMetrics
                .where((m) => m.sleepQuality != null || m.energyLevel != null)
                .toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
            todaySleepEnergyMetric = sleepEnergyMetrics.isNotEmpty ? sleepEnergyMetrics.first : null;
            
            // Latest heart rate for today
            final heartRateMetrics = todayMetrics
                .where((m) => m.restingHeartRate != null)
                .toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
            todayHeartRateMetric = heartRateMetrics.isNotEmpty ? heartRateMetrics.first : null;
            
            // Latest blood pressure for today
            final bpMetrics = todayMetrics
                .where((m) => m.systolicBP != null && m.diastolicBP != null)
                .toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
            todayBloodPressureMetric = bpMetrics.isNotEmpty ? bpMetrics.first : null;
          }

          final latestWeight = metrics
              .where((m) => m.weight != null)
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date));
          final latestWeightMetric = latestWeight.isNotEmpty ? latestWeight.first : null;

          // Calculate heart rate baseline
          final baselineUseCase = CalculateBaselineHeartRateUseCase();
          final baselineResult = baselineUseCase.call(metrics);
          final baselineHR = baselineResult.fold(
            (_) => null,
            (value) => value.round(),
          );

          // Find latest body measurements
          final latestMeasurements = metrics
              .where((m) => m.bodyMeasurements != null && m.bodyMeasurements!.isNotEmpty)
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date));
          final latestMeasurementsMetric = latestMeasurements.isNotEmpty ? latestMeasurements.first : null;
          final measurementsDate = latestMeasurementsMetric != null
              ? DateTime.now().difference(latestMeasurementsMetric.date).inDays
              : null;

          // Format blood pressure
          String? bpDisplay;
          if (todayBloodPressureMetric?.systolicBP != null && todayBloodPressureMetric?.diastolicBP != null) {
            final systolic = todayBloodPressureMetric!.systolicBP!;
            final diastolic = todayBloodPressureMetric.diastolicBP!;
            bpDisplay = '$systolic/$diastolic mmHg';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(UIConstants.screenPaddingHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Safety alerts
                const SafetyAlertWidget(),
                
                const SizedBox(height: UIConstants.spacingLg),

                // Today's Overview Card
                Card(
                  elevation: 2,
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  child: Padding(
                    padding: const EdgeInsets.all(UIConstants.cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today\'s Overview',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: UIConstants.spacingMd),
                        Wrap(
                          spacing: UIConstants.spacingSm,
                          runSpacing: UIConstants.spacingSm,
                          alignment: WrapAlignment.start,
                          crossAxisAlignment: WrapCrossAlignment.start,
                          children: [
                            // Weight - always show (use latest weight overall, not just today)
                            () {
                              if (latestWeightMetric?.weight != null) {
                                final weight = latestWeightMetric!.weight!;
                                final avg = movingAverage;
                                return _buildOverviewItem(
                                  theme,
                                  'Weight',
                                  '${weight.toStringAsFixed(1)} kg',
                                  avg != null
                                      ? '↓ ${(weight - avg).abs().toStringAsFixed(1)} kg'
                                      : null,
                                  isEmpty: false,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => const WeightEntryPage(),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return _buildOverviewItem(
                                  theme,
                                  'Weight',
                                  '--',
                                  null,
                                  isEmpty: true,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => const WeightEntryPage(),
                                      ),
                                    );
                                  },
                                );
                              }
                            }(),
                            // Sleep - always show
                            _buildOverviewItem(
                              theme,
                              'Sleep',
                              todaySleepEnergyMetric?.sleepQuality != null
                                  ? '${todaySleepEnergyMetric!.sleepQuality}/10'
                                  : '--',
                              null,
                              isEmpty: todaySleepEnergyMetric?.sleepQuality == null,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const SleepEnergyPage(),
                                  ),
                                );
                              },
                            ),
                            // Energy - always show
                            _buildOverviewItem(
                              theme,
                              'Energy',
                              todaySleepEnergyMetric?.energyLevel != null
                                  ? '${todaySleepEnergyMetric!.energyLevel}/10'
                                  : '--',
                              null,
                              isEmpty: todaySleepEnergyMetric?.energyLevel == null,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const SleepEnergyPage(),
                                  ),
                                );
                              },
                            ),
                            // Heart Rate - always show
                            _buildOverviewItem(
                              theme,
                              'Heart Rate',
                              todayHeartRateMetric?.restingHeartRate != null
                                  ? '${todayHeartRateMetric!.restingHeartRate} BPM'
                                  : '--',
                              null,
                              isEmpty: todayHeartRateMetric?.restingHeartRate == null,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const HeartRateEntryPage(),
                                  ),
                                );
                              },
                            ),
                            // Blood Pressure - always show
                            _buildOverviewItem(
                              theme,
                              'Blood Pressure',
                              bpDisplay ?? '--',
                              null,
                              isEmpty: bpDisplay == null,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const BloodPressureEntryPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: UIConstants.spacingLg),

                // Weight Trend Chart
                const WeightChartWidget(daysToShow: 30),

                const SizedBox(height: UIConstants.spacingLg),

                // Weight Card
                DashboardMetricCardWidget(
                  title: 'Weight',
                  value: () {
                    final weight = latestWeightMetric?.weight;
                    return weight != null ? '${weight.toStringAsFixed(1)} kg' : null;
                  }(),
                  icon: Icons.scale,
                  subtitle: movingAverage != null
                      ? '7-Day Avg: ${movingAverage.toStringAsFixed(1)} kg'
                      : null,
                  additionalInfo: () {
                    final weight = latestWeightMetric?.weight;
                    final avg = movingAverage;
                    if (weight != null && avg != null) {
                      final diff = (weight - avg).abs();
                      final trend = weight > avg ? '↑' : weight < avg ? '↓' : '→';
                      return 'Trend: $trend ${diff.toStringAsFixed(1)} kg';
                    }
                    return null;
                  }(),
                  onQuickLog: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const WeightEntryPage(),
                      ),
                    );
                  },
                  onViewDetails: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const WeightHistoryPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: UIConstants.spacingMd),

                // Heart Rate Card
                DashboardMetricCardWidget(
                  title: 'Heart Rate',
                  value: () {
                    final hr = todayHeartRateMetric?.restingHeartRate;
                    return hr != null ? '$hr BPM' : null;
                  }(),
                  icon: Icons.favorite,
                  iconColor: Colors.red,
                  subtitle: baselineHR != null
                      ? 'Baseline: $baselineHR BPM'
                      : null,
                  additionalInfo: () {
                    final hr = todayHeartRateMetric?.restingHeartRate;
                    final baseline = baselineHR;
                    if (hr != null && baseline != null) {
                      final diff = hr - baseline;
                      return 'Current: ${diff >= 0 ? '+' : ''}$diff BPM from baseline';
                    }
                    return null;
                  }(),
                  onQuickLog: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const HeartRateEntryPage(),
                      ),
                    );
                  },
                  onViewDetails: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const HeartRateHistoryPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: UIConstants.spacingMd),

                // Blood Pressure Card
                DashboardMetricCardWidget(
                  title: 'Blood Pressure',
                  value: bpDisplay,
                  icon: Icons.monitor_heart,
                  iconColor: Colors.purple,
                  onQuickLog: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const BloodPressureEntryPage(),
                      ),
                    );
                  },
                  onViewDetails: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const BloodPressureHistoryPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: UIConstants.spacingMd),

                // Sleep & Energy Card
                DashboardMetricCardWidget(
                  title: 'Sleep & Energy',
                  icon: Icons.bedtime,
                  iconColor: Colors.blue,
                  customContent: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (todaySleepEnergyMetric?.sleepQuality != null || todaySleepEnergyMetric?.energyLevel != null) ...[
                        Row(
                          children: [
                            if (todaySleepEnergyMetric?.sleepQuality != null) ...[
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
                                    Text(
                                      '${todaySleepEnergyMetric!.sleepQuality}/10',
                                      style: theme.textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (todaySleepEnergyMetric?.energyLevel != null) ...[
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
                                      '${todaySleepEnergyMetric!.energyLevel}/10',
                                      style: theme.textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ] else ...[
                        Text(
                          'No data',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                  onQuickLog: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SleepEnergyPage(),
                      ),
                    );
                  },
                  onViewDetails: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SleepEnergyHistoryPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: UIConstants.spacingMd),

                // Body Measurements Card
                DashboardMetricCardWidget(
                  title: 'Body Measurements',
                  icon: Icons.straighten,
                  iconColor: Colors.teal,
                  value: measurementsDate != null
                      ? measurementsDate == 0
                          ? 'Today'
                          : measurementsDate == 1
                              ? 'Yesterday'
                              : '$measurementsDate days ago'
                      : null,
                  subtitle: measurementsDate == null
                      ? 'No measurements logged'
                      : null,
                  onQuickLog: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MeasurementsPage(),
                      ),
                    );
                  },
                  onViewDetails: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const BodyMeasurementsHistoryPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading data: $error'),
        ),
      ),
    );
  }

  Widget _buildOverviewItem(
    ThemeData theme,
    String label,
    String value,
    String? trend, {
    bool isEmpty = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(UIConstants.borderRadiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.spacingSm,
          vertical: UIConstants.spacingXs,
        ),
        decoration: BoxDecoration(
          color: isEmpty
              ? theme.colorScheme.surface.withValues(alpha: 0.5)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusSm),
          border: Border.all(
            color: isEmpty
                ? theme.colorScheme.outline.withValues(alpha: 0.3)
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            style: isEmpty ? BorderStyle.solid : BorderStyle.solid,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(
                  alpha: isEmpty ? 0.5 : 0.7,
                ),
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isEmpty
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                    : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (trend != null)
              Text(
                trend,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontSize: 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}

