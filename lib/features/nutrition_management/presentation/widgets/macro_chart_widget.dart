import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/widgets/empty_state_widget.dart';
import 'package:health_app/features/nutrition_management/presentation/providers/nutrition_providers.dart';

/// Macro targets (percentages of calories)
const double kTargetProteinPercent = 35.0;
const double kTargetFatsPercent = 55.0;
const double kTargetCarbsPercent = 10.0; // Should be < 40g absolute
const double kTolerance = 5.0; // Percentage tolerance for "close to target"

/// Widget displaying daily macro breakdown as a stacked bar chart
class MacroChartWidget extends ConsumerWidget {
  /// Date to show macros for (defaults to today)
  final DateTime? date;

  /// Creates a macro chart widget
  const MacroChartWidget({
    super.key,
    this.date,
  });

  /// Get color for macro based on target
  Color _getMacroColor(double percent, double target, bool isCarbs) {
    final difference = (percent - target).abs();
    
    if (isCarbs) {
      // For carbs, we check the absolute value (should be < 40g)
      // This is handled separately in the chart data
      return Colors.orange;
    }
    
    if (difference <= kTolerance) {
      return Colors.green; // On target
    } else if (difference <= kTolerance * 2) {
      return Colors.orange; // Close to target
    } else {
      return Colors.red; // Off target
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final targetDate = date ?? DateTime.now();
    final dateOnly = DateTime(targetDate.year, targetDate.month, targetDate.day);
    
    final macroSummary = ref.watch(macroSummaryProvider(dateOnly));
    
    // Check if we have data
    if (macroSummary.calories == 0.0) {
      return const EmptyStateWidget(
        title: 'No nutrition data',
        description: 'Log meals to see your macro breakdown',
        icon: Icons.bar_chart,
      );
    }

    // Check if net carbs exceed limit
    final carbsOverLimit = macroSummary.netCarbs > 40.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Macro Breakdown',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: UIConstants.spacingMd),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  minY: 0,
                  groupsSpace: 20,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final macroName = rodIndex == 0
                            ? 'Protein'
                            : rodIndex == 1
                                ? 'Fats'
                                : 'Net Carbs';
                        final value = rod.toY;
                        return BarTooltipItem(
                          '$macroName\n${value.toStringAsFixed(1)}%',
                          TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
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
                          return Text(
                            'Today',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          );
                        },
                        reservedSize: 40,
                        interval: 25,
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 25,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: theme.colorScheme.surfaceContainerHighest,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      groupVertically: true,
                      barRods: [
                        // Protein bar (bottom, from 0 to proteinPercent)
                        BarChartRodData(
                          fromY: 0,
                          toY: macroSummary.proteinPercent,
                          color: _getMacroColor(
                            macroSummary.proteinPercent,
                            kTargetProteinPercent,
                            false,
                          ),
                          width: 40,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: 100,
                            color: theme.colorScheme.surfaceContainerHighest,
                          ),
                        ),
                        // Fats bar (middle, from proteinPercent to proteinPercent + fatsPercent)
                        BarChartRodData(
                          fromY: macroSummary.proteinPercent,
                          toY: macroSummary.proteinPercent + macroSummary.fatsPercent,
                          color: _getMacroColor(
                            macroSummary.fatsPercent,
                            kTargetFatsPercent,
                            false,
                          ),
                          width: 40,
                          borderRadius: BorderRadius.zero,
                        ),
                        // Net Carbs bar (top, from proteinPercent + fatsPercent to 100)
                        BarChartRodData(
                          fromY: macroSummary.proteinPercent + macroSummary.fatsPercent,
                          toY: macroSummary.proteinPercent +
                              macroSummary.fatsPercent +
                              macroSummary.carbsPercent,
                          color: carbsOverLimit
                              ? Colors.red
                              : _getMacroColor(
                                  macroSummary.carbsPercent,
                                  kTargetCarbsPercent,
                                  true,
                                ),
                          width: 40,
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: UIConstants.spacingMd),
            // Legend and totals
            Column(
              children: [
                // Macro breakdown with values
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMacroLegendItem(
                      theme,
                      Colors.blue,
                      'Protein',
                      macroSummary.protein,
                      macroSummary.proteinPercent,
                      'g',
                    ),
                    _buildMacroLegendItem(
                      theme,
                      Colors.orange,
                      'Fats',
                      macroSummary.fats,
                      macroSummary.fatsPercent,
                      'g',
                    ),
                    _buildMacroLegendItem(
                      theme,
                      carbsOverLimit ? Colors.red : Colors.green,
                      'Net Carbs',
                      macroSummary.netCarbs,
                      macroSummary.carbsPercent,
                      'g',
                    ),
                  ],
                ),
                const SizedBox(height: UIConstants.spacingSm),
                // Warning if carbs over limit
                if (carbsOverLimit)
                  Padding(
                    padding: const EdgeInsets.only(top: UIConstants.spacingXs),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.warning,
                          size: 16,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(width: UIConstants.spacingXs),
                        Text(
                          'Net carbs exceed 40g limit (${macroSummary.netCarbs.toStringAsFixed(1)}g)',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroLegendItem(
    ThemeData theme,
    Color color,
    String label,
    double value,
    double percent,
    String unit,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: UIConstants.spacingXs),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: UIConstants.spacingXs),
        Text(
          '${value.toStringAsFixed(1)}$unit',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '${percent.toStringAsFixed(1)}%',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

