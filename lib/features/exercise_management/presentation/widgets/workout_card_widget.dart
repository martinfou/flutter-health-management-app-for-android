// Dart SDK
import 'package:flutter/material.dart';

// Packages

// Project
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/features/exercise_management/domain/entities/workout_plan.dart';

/// Workout card widget for displaying workout plan information
class WorkoutCardWidget extends StatelessWidget {
  final WorkoutPlan plan;

  const WorkoutCardWidget({
    super.key,
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    plan.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (plan.isActive)
                  Chip(
                    label: const Text('Active'),
                    avatar: const Icon(Icons.check_circle, size: 16),
                    backgroundColor: theme.colorScheme.primaryContainer,
                  ),
              ],
            ),
            if (plan.description != null) ...[
              const SizedBox(height: UIConstants.spacingXs),
              Text(
                plan.description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: UIConstants.spacingSm),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: UIConstants.spacingXs),
                Text(
                  '${plan.durationWeeks} weeks',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(width: UIConstants.spacingMd),
                Icon(
                  Icons.event,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: UIConstants.spacingXs),
                Text(
                  '${plan.days.length} days/week',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

