// Dart SDK
import 'package:flutter/material.dart';

// Project
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/usecases/calculate_daily_progress.dart';

/// Widget for displaying metric status grid with checkmarks
class MetricCheckGridWidget extends StatelessWidget {
  /// Daily metric status
  final DailyMetricStatus status;

  /// Creates MetricCheckGridWidget
  const MetricCheckGridWidget({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: UIConstants.spacingMd,
      runSpacing: UIConstants.spacingMd,
      children: [
        _buildMetricItem(theme, 'Weight', status.weight),
        _buildMetricItem(theme, 'Sleep', status.sleep),
        _buildMetricItem(theme, 'Energy', status.energy),
        _buildMetricItem(theme, 'Macros', status.macros),
        _buildMetricItem(theme, 'Heart', status.heartRate),
        _buildMetricItem(theme, 'Meds', status.medication),
      ],
    );
  }

  Widget _buildMetricItem(
    ThemeData theme,
    String label,
    MetricStatus metricStatus,
  ) {
    IconData icon;
    Color color;

    switch (metricStatus) {
      case MetricStatus.completed:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case MetricStatus.partial:
        icon = Icons.warning;
        color = Colors.orange;
        break;
      case MetricStatus.notLogged:
        icon = Icons.circle_outlined;
        color = theme.colorScheme.onSurface.withValues(alpha: 0.3);
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color,
          size: UIConstants.iconSizeMd,
        ),
        const SizedBox(width: UIConstants.spacingXs),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: metricStatus == MetricStatus.notLogged
                ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                : theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

