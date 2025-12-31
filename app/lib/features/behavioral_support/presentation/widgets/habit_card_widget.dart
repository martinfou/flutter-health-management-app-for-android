import 'package:flutter/material.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/features/behavioral_support/domain/entities/habit.dart';

/// Widget displaying a habit card in the habits list
class HabitCardWidget extends StatelessWidget {
  /// Habit to display
  final Habit habit;

  /// Callback when habit is tapped
  final VoidCallback? onTap;

  /// Callback when habit completion is toggled
  final VoidCallback? onToggleCompletion;

  /// Creates a habit card widget
  const HabitCardWidget({
    super.key,
    required this.habit,
    this.onTap,
    this.onToggleCompletion,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompletedToday = habit.isCompletedToday();
    
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
                          habit.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (habit.description != null && habit.description!.isNotEmpty) ...[
                          const SizedBox(height: UIConstants.spacingXs),
                          Text(
                            habit.description!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                        const SizedBox(height: UIConstants.spacingSm),
                        Row(
                          children: [
                            _buildStreakChip(
                              theme,
                              'Current: ${habit.currentStreak}',
                              Colors.blue,
                            ),
                            const SizedBox(width: UIConstants.spacingXs),
                            _buildStreakChip(
                              theme,
                              'Best: ${habit.longestStreak}',
                              Colors.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Checkbox(
                    value: isCompletedToday,
                    onChanged: onToggleCompletion != null
                        ? (_) => onToggleCompletion!()
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakChip(ThemeData theme, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.spacingSm,
        vertical: UIConstants.spacingXs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusSm),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

