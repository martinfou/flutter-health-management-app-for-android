import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/widgets/custom_button.dart';
import 'package:health_app/features/health_tracking/presentation/providers/health_metrics_provider.dart';
import 'package:health_app/features/health_tracking/presentation/providers/moving_average_provider.dart';
import 'package:health_app/features/health_tracking/presentation/widgets/metric_card_widget.dart';
import 'package:health_app/features/health_tracking/presentation/widgets/weight_chart_widget.dart';
import 'package:health_app/features/health_tracking/presentation/pages/weight_entry_page.dart';
import 'package:health_app/features/health_tracking/presentation/pages/measurements_page.dart';
import 'package:health_app/features/health_tracking/presentation/pages/sleep_energy_page.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';

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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(UIConstants.screenPaddingHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Today's Metrics Cards
                Text(
                  'Today\'s Metrics',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: UIConstants.spacingMd),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: UIConstants.spacingMd,
                  mainAxisSpacing: UIConstants.spacingMd,
                  childAspectRatio: 1.2,
                  children: [
                    MetricCardWidget(
                      title: 'Weight',
                      value: latestWeightMetric?.weight != null
                          ? '${latestWeightMetric!.weight!.toStringAsFixed(1)} kg'
                          : '--',
                      icon: Icons.scale,
                      subtitle: movingAverage != null
                          ? 'Avg: ${movingAverage.toStringAsFixed(1)} kg'
                          : null,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const WeightEntryPage(),
                          ),
                        );
                      },
                    ),
                    MetricCardWidget(
                      title: 'Sleep',
                      value: todayMetric?.sleepQuality != null
                          ? '${todayMetric!.sleepQuality}/10'
                          : '--',
                      icon: Icons.bedtime,
                      iconColor: Colors.blue,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SleepEnergyPage(),
                          ),
                        );
                      },
                    ),
                    MetricCardWidget(
                      title: 'Energy',
                      value: todayMetric?.energyLevel != null
                          ? '${todayMetric!.energyLevel}/10'
                          : '--',
                      icon: Icons.bolt,
                      iconColor: Colors.orange,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SleepEnergyPage(),
                          ),
                        );
                      },
                    ),
                    MetricCardWidget(
                      title: 'Heart Rate',
                      value: todayMetric?.restingHeartRate != null
                          ? '${todayMetric!.restingHeartRate} BPM'
                          : '--',
                      icon: Icons.favorite,
                      iconColor: Colors.red,
                    ),
                  ],
                ),

                const SizedBox(height: UIConstants.spacingLg),

                // Weight Trend Chart
                const WeightChartWidget(daysToShow: 30),

                const SizedBox(height: UIConstants.spacingLg),

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: UIConstants.spacingMd),
                CustomButton(
                  label: 'Log Weight',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const WeightEntryPage(),
                      ),
                    );
                  },
                  icon: Icons.add,
                  width: double.infinity,
                ),
                const SizedBox(height: UIConstants.spacingSm),
                CustomButton(
                  label: 'Log Measurements',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MeasurementsPage(),
                      ),
                    );
                  },
                  icon: Icons.straighten,
                  variant: ButtonVariant.secondary,
                  width: double.infinity,
                ),
                const SizedBox(height: UIConstants.spacingSm),
                CustomButton(
                  label: 'Log Sleep & Energy',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SleepEnergyPage(),
                      ),
                    );
                  },
                  icon: Icons.bedtime,
                  variant: ButtonVariant.secondary,
                  width: double.infinity,
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
}

