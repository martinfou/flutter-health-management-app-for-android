// Dart SDK
import 'package:flutter/material.dart';

// Project
import 'package:health_app/core/constants/ui_constants.dart';

/// Widget for displaying daily progress bar
class ProgressBarWidget extends StatelessWidget {
  /// Progress value (0.0 to 1.0, where 1.0 = 100%)
  final double progress;

  /// Creates ProgressBarWidget
  const ProgressBarWidget({
    super.key,
    required this.progress,
  }) : assert(progress >= 0.0 && progress <= 1.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = (progress * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$percentage%',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: UIConstants.spacingSm),
        ClipRRect(
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusSm),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getProgressColor(theme, progress),
            ),
          ),
        ),
      ],
    );
  }

  /// Get progress color based on completion percentage
  Color _getProgressColor(ThemeData theme, double progress) {
    if (progress >= 0.8) {
      // 80%+ = green
      return Colors.green;
    } else if (progress >= 0.5) {
      // 50-79% = yellow/orange
      return Colors.orange;
    } else {
      // <50% = red/orange
      return Colors.red;
    }
  }
}

