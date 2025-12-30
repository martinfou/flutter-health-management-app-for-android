// Dart SDK
import 'package:flutter/material.dart';

// Project
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/entities/recommended_action.dart';

/// Widget for displaying a recommended action card in "What's Next?" section
class WhatNextCardWidget extends StatelessWidget {
  /// The recommended action to display
  final RecommendedAction action;

  /// Callback when user taps "Log Now" / "Quick Log"
  final VoidCallback onTap;

  /// Creates WhatNextCardWidget
  const WhatNextCardWidget({
    super.key,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: UIConstants.spacingMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusMd),
        child: Padding(
          padding: const EdgeInsets.all(UIConstants.cardPadding),
          child: Row(
            children: [
              // Status icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getStatusColor(theme).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getStatusIcon(),
                  color: _getStatusColor(theme),
                  size: UIConstants.iconSizeMd,
                ),
              ),
              const SizedBox(width: UIConstants.spacingMd),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingXs),
                    Text(
                      action.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              // Action button
              TextButton(
                onPressed: onTap,
                child: Text(
                  action.priority == 1 ? 'Log Now' : 'Quick Log',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get status icon based on action type
  IconData _getStatusIcon() {
    switch (action.type) {
      case RecommendedActionType.takeMedication:
        return Icons.medication_liquid;
      case RecommendedActionType.logWeight:
        return Icons.monitor_weight;
      case RecommendedActionType.logSleep:
        return Icons.bedtime;
      case RecommendedActionType.logEnergy:
        return Icons.battery_charging_full;
      case RecommendedActionType.logMeal:
        return Icons.restaurant;
      case RecommendedActionType.logWorkout:
        return Icons.fitness_center;
      case RecommendedActionType.logHeartRate:
        return Icons.favorite;
      case RecommendedActionType.logBloodPressure:
        return Icons.favorite;
      case RecommendedActionType.logMeasurements:
        return Icons.straighten;
      case RecommendedActionType.completeHabit:
        return Icons.check_circle;
    }
  }

  /// Get status color based on priority
  Color _getStatusColor(ThemeData theme) {
    if (action.priority == 1) {
      // Urgent (medication)
      return theme.colorScheme.error;
    } else {
      // Normal
      return theme.colorScheme.primary;
    }
  }
}

