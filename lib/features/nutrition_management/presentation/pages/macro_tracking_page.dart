import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/widgets/empty_state_widget.dart';
import 'package:health_app/features/nutrition_management/presentation/providers/nutrition_providers.dart';

/// Macro targets (percentages of calories)
const double kTargetProteinPercent = 35.0;
const double kTargetFatsPercent = 55.0;
const double kTargetCarbsMaxGrams = 40.0;
const double kTolerance = 5.0; // Percentage tolerance for "close to target"

/// Macro tracking page showing daily macro summary with progress bars
class MacroTrackingPage extends ConsumerWidget {
  /// Date to show macros for (defaults to today)
  final DateTime? date;

  /// Creates a macro tracking page
  const MacroTrackingPage({
    super.key,
    this.date,
  });

  /// Get color for macro progress based on target
  Color _getProgressColor(double percent, double target, bool isCarbs, double carbsGrams) {
    if (isCarbs) {
      // For carbs, check absolute grams first (must be < 40g)
      if (carbsGrams > kTargetCarbsMaxGrams) {
        return Colors.red;
      }
      // Then check percentage
      final difference = (percent - target).abs();
      if (difference <= kTolerance) {
        return Colors.green;
      } else if (difference <= kTolerance * 2) {
        return Colors.orange;
      } else {
        return Colors.red;
      }
    }
    
    final difference = (percent - target).abs();
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
      return Scaffold(
        appBar: AppBar(
          title: const Text('Macro Tracking'),
        ),
        body: const EmptyStateWidget(
          title: 'No nutrition data',
          description: 'Log meals to see your macro tracking',
          icon: Icons.track_changes,
        ),
      );
    }

    final proteinColor = _getProgressColor(
      macroSummary.proteinPercent,
      kTargetProteinPercent,
      false,
      0.0,
    );
    final fatsColor = _getProgressColor(
      macroSummary.fatsPercent,
      kTargetFatsPercent,
      false,
      0.0,
    );
    final carbsColor = _getProgressColor(
      macroSummary.carbsPercent,
      10.0, // Target carbs percent
      true,
      macroSummary.netCarbs,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Macro Tracking'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.screenPaddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Daily macro summary card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Summary',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingMd),
                    
                    // Total calories
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Calories',
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          '${macroSummary.calories.toStringAsFixed(0)} cal',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    
                    const Divider(),
                    
                    // Macro totals
                    _MacroSummaryRow(
                      label: 'Protein',
                      value: macroSummary.protein,
                      unit: 'g',
                      percent: macroSummary.proteinPercent,
                      target: '${kTargetProteinPercent.toStringAsFixed(0)}%',
                    ),
                    const SizedBox(height: UIConstants.spacingXs),
                    _MacroSummaryRow(
                      label: 'Fats',
                      value: macroSummary.fats,
                      unit: 'g',
                      percent: macroSummary.fatsPercent,
                      target: '${kTargetFatsPercent.toStringAsFixed(0)}%',
                    ),
                    const SizedBox(height: UIConstants.spacingXs),
                    _MacroSummaryRow(
                      label: 'Net Carbs',
                      value: macroSummary.netCarbs,
                      unit: 'g',
                      percent: macroSummary.carbsPercent,
                      target: '< ${kTargetCarbsMaxGrams.toStringAsFixed(0)}g',
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: UIConstants.spacingLg),
            
            // Protein progress bar
            Card(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: proteinColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: UIConstants.spacingXs),
                            Text(
                              'Protein',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${macroSummary.proteinPercent.toStringAsFixed(1)}% / ${kTargetProteinPercent.toStringAsFixed(0)}%',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: UIConstants.spacingSm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(UIConstants.borderRadiusMd),
                      child: LinearProgressIndicator(
                        value: (macroSummary.proteinPercent / 100).clamp(0.0, 1.0),
                        minHeight: 12,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(proteinColor),
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingXs),
                    Text(
                      '${macroSummary.protein.toStringAsFixed(1)}g',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: UIConstants.spacingMd),
            
            // Fats progress bar
            Card(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: fatsColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: UIConstants.spacingXs),
                            Text(
                              'Fats',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${macroSummary.fatsPercent.toStringAsFixed(1)}% / ${kTargetFatsPercent.toStringAsFixed(0)}%',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: UIConstants.spacingSm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(UIConstants.borderRadiusMd),
                      child: LinearProgressIndicator(
                        value: (macroSummary.fatsPercent / 100).clamp(0.0, 1.0),
                        minHeight: 12,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(fatsColor),
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingXs),
                    Text(
                      '${macroSummary.fats.toStringAsFixed(1)}g',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: UIConstants.spacingMd),
            
            // Net Carbs progress bar
            Card(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: carbsColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: UIConstants.spacingXs),
                            Text(
                              'Net Carbs',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${macroSummary.netCarbs.toStringAsFixed(1)}g / ${kTargetCarbsMaxGrams.toStringAsFixed(0)}g',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: macroSummary.netCarbs > kTargetCarbsMaxGrams
                                ? theme.colorScheme.error
                                : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: UIConstants.spacingSm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(UIConstants.borderRadiusMd),
                      child: LinearProgressIndicator(
                        value: (macroSummary.netCarbs / kTargetCarbsMaxGrams).clamp(0.0, 1.0),
                        minHeight: 12,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(carbsColor),
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingXs),
                    Text(
                      '${macroSummary.carbsPercent.toStringAsFixed(1)}% of calories',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    if (macroSummary.netCarbs > kTargetCarbsMaxGrams) ...[
                      const SizedBox(height: UIConstants.spacingXs),
                      Row(
                        children: [
                          Icon(
                            Icons.warning,
                            size: 16,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(width: UIConstants.spacingXs),
                          Expanded(
                            child: Text(
                              'Net carbs exceed the 40g limit',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: UIConstants.spacingLg),
            
            // Legend
            Card(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Target Indicators',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingSm),
                    _buildLegendItem(theme, Colors.green, 'On Target'),
                    const SizedBox(height: UIConstants.spacingXs),
                    _buildLegendItem(theme, Colors.orange, 'Close to Target'),
                    const SizedBox(height: UIConstants.spacingXs),
                    _buildLegendItem(theme, Colors.red, 'Off Target'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: UIConstants.spacingLg),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(ThemeData theme, Color color, String label) {
    return Row(
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
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

/// Macro summary row widget
class _MacroSummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final double percent;
  final String target;

  const _MacroSummaryRow({
    required this.label,
    required this.value,
    required this.unit,
    required this.percent,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium,
        ),
        Row(
          children: [
            Text(
              '${value.toStringAsFixed(1)}$unit',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: UIConstants.spacingSm),
            Text(
              '(${percent.toStringAsFixed(1)}%)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(width: UIConstants.spacingSm),
            Text(
              'Target: $target',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

