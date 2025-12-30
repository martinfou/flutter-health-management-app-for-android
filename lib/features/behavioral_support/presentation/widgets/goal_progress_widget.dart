import 'package:flutter/material.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/features/behavioral_support/domain/entities/goal.dart';
import 'package:health_app/features/behavioral_support/domain/entities/goal_status.dart';

/// Widget displaying goal progress
class GoalProgressWidget extends StatelessWidget {
  /// Goal to display
  final Goal goal;

  /// Callback when goal is tapped
  final VoidCallback? onTap;

  /// Creates a goal progress widget
  const GoalProgressWidget({
    super.key,
    required this.goal,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = goal.progressPercentage / 100.0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: UIConstants.spacingSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusMd),
        child: Padding(
          padding: const EdgeInsets.all(UIConstants.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.description,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: UIConstants.spacingXs),
                        Text(
                          goal.type.displayName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: UIConstants.spacingSm,
                      vertical: UIConstants.spacingXs,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(goal.status).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(UIConstants.borderRadiusSm),
                    ),
                    child: Text(
                      goal.status.displayName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(goal.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: UIConstants.spacingMd),
              if (goal.targetValue != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      '${goal.progressPercentage.toStringAsFixed(1)}%',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: UIConstants.spacingSm),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: UIConstants.spacingXs),
                Text(
                  '${goal.currentValue.toStringAsFixed(1)} / ${goal.targetValue!.toStringAsFixed(1)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(GoalStatus status) {
    switch (status) {
      case GoalStatus.inProgress:
        return Colors.blue;
      case GoalStatus.completed:
        return Colors.green;
      case GoalStatus.paused:
        return Colors.orange;
      case GoalStatus.cancelled:
        return Colors.grey;
    }
  }
}

