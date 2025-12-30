import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/widgets/empty_state_widget.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';
import 'package:health_app/features/health_tracking/domain/usecases/calculate_moving_average.dart';
import 'package:health_app/features/health_tracking/presentation/providers/health_metrics_provider.dart';

/// Widget displaying weight trend chart with 7-day moving average
class WeightChartWidget extends ConsumerWidget {
  /// Number of days to display (default: 30)
  final int daysToShow;

  /// Creates a weight chart widget
  const WeightChartWidget({
    super.key,
    this.daysToShow = 30,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(healthMetricsProvider);
    final theme = Theme.of(context);

    return metricsAsync.when(
      data: (metrics) {
        if (metrics.isEmpty) {
          return const EmptyStateWidget(
            title: 'No weight data',
            description: 'Start logging your weight to see trends',
            icon: Icons.show_chart,
          );
        }

        return _buildChart(context, metrics, theme);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => const EmptyStateWidget(
        title: 'Error loading chart',
        description: 'Failed to load weight data',
        icon: Icons.error_outline,
      ),
    );
  }

  Widget _buildChart(BuildContext context, List<HealthMetric> metrics, ThemeData theme) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = today.subtract(Duration(days: daysToShow - 1));

    // Filter metrics to date range with weight data
    final weightMetrics = metrics
        .where((m) {
          final metricDate = DateTime(m.date.year, m.date.month, m.date.day);
          return !metricDate.isBefore(startDate) &&
              !metricDate.isAfter(today) &&
              m.weight != null;
        })
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (weightMetrics.isEmpty) {
      return const EmptyStateWidget(
        title: 'No weight data in this period',
        description: 'Log your weight to see trends',
        icon: Icons.show_chart,
      );
    }

    // Calculate 7-day moving averages for each point
    final movingAverageUseCase = CalculateMovingAverageUseCase();
    final chartData = <ChartDataPoint>[];
    final movingAverageData = <ChartDataPoint>[];

    for (int i = 0; i < weightMetrics.length; i++) {
      final metric = weightMetrics[i];
      final date = metric.date;
      final weight = metric.weight!;

      // Get metrics up to this point for moving average
      final metricsUpToDate = weightMetrics
          .where((m) => !m.date.isAfter(date))
          .toList();

      chartData.add(ChartDataPoint(
        date: date,
        value: weight,
      ));

      // Calculate moving average if we have enough data
      final movingAvgResult = movingAverageUseCase(metricsUpToDate);
      movingAvgResult.fold(
        (_) => null, // Not enough data for moving average
        (avg) => movingAverageData.add(ChartDataPoint(
          date: date,
          value: avg,
        )),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weight Trend (Last $daysToShow Days)',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: UIConstants.spacingMd),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: theme.colorScheme.surfaceContainerHighest,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() % 5 == 0 && value.toInt() < chartData.length) {
                            final date = chartData[value.toInt()].date;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                DateFormat('M/d').format(date),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  minX: 0,
                  maxX: (chartData.length - 1).toDouble(),
                  minY: _getMinWeight(chartData) - 2,
                  maxY: _getMaxWeight(chartData) + 2,
                  lineBarsData: [
                    // Weight data line
                    LineChartBarData(
                      spots: chartData.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.value);
                      }).toList(),
                      isCurved: true,
                      color: theme.colorScheme.primary,
                      barWidth: 2,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: theme.colorScheme.primary,
                            strokeWidth: 2,
                            strokeColor: theme.colorScheme.surface,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(show: false),
                    ),
                    // Moving average line
                    if (movingAverageData.isNotEmpty)
                      LineChartBarData(
                        spots: movingAverageData.asMap().entries.map((entry) {
                          final index = chartData.indexWhere(
                            (d) => d.date.year == entry.value.date.year &&
                                d.date.month == entry.value.date.month &&
                                d.date.day == entry.value.date.day,
                          );
                          if (index == -1) return FlSpot(0, 0);
                          return FlSpot(index.toDouble(), entry.value.value);
                        }).where((spot) => spot.y > 0).toList(),
                        isCurved: true,
                        color: theme.colorScheme.secondary,
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                        dashArray: [5, 5],
                        belowBarData: BarAreaData(show: false),
                      ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((spot) {
                          final index = spot.x.toInt();
                          if (index >= 0 && index < chartData.length) {
                            final dataPoint = chartData[index];
                            return LineTooltipItem(
                              '${dataPoint.value.toStringAsFixed(1)} kg\n${DateFormat('MMM d').format(dataPoint.date)}',
                              TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }
                          return null;
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: UIConstants.spacingSm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(theme, theme.colorScheme.primary, 'Weight'),
                const SizedBox(width: UIConstants.spacingLg),
                _buildLegendItem(theme, theme.colorScheme.secondary, '7-Day Average'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(ThemeData theme, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 2,
          color: color,
        ),
        const SizedBox(width: UIConstants.spacingXs),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  double _getMinWeight(List<ChartDataPoint> data) {
    if (data.isEmpty) return 0;
    return data.map((d) => d.value).reduce((a, b) => a < b ? a : b) - 1;
  }

  double _getMaxWeight(List<ChartDataPoint> data) {
    if (data.isEmpty) return 100;
    return data.map((d) => d.value).reduce((a, b) => a > b ? a : b) + 1;
  }
}

/// Data point for chart
class ChartDataPoint {
  final DateTime date;
  final double value;

  ChartDataPoint({
    required this.date,
    required this.value,
  });
}

