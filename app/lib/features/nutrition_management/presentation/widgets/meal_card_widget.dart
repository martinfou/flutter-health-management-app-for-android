import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/features/nutrition_management/domain/entities/meal.dart';
import 'package:health_app/features/nutrition_management/domain/entities/meal_type.dart';
import 'package:health_app/features/nutrition_management/domain/entities/eating_reason.dart';
import 'package:health_app/features/nutrition_management/presentation/pages/meal_detail_page.dart';

/// Widget displaying a meal card in the recent meals list
class MealCardWidget extends StatelessWidget {
  /// Meal to display
  final Meal meal;

  /// Creates a meal card widget
  const MealCardWidget({
    super.key,
    required this.meal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('h:mm a');
    
    return Card(
      margin: const EdgeInsets.only(bottom: UIConstants.spacingSm),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MealDetailPage(meal: meal),
            ),
          );
        },
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusMd),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: UIConstants.spacingMd,
            vertical: UIConstants.spacingSm,
          ),
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(
              _getMealTypeIcon(meal.mealType),
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          title: Text(
            meal.name,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: UIConstants.spacingXs),
              Text(
                '${meal.mealType.displayName} • ${timeFormat.format(meal.date)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: UIConstants.spacingXs),
              Row(
                children: [
                  _buildMacroChip(theme, '${meal.protein.toStringAsFixed(0)}g P', Colors.blue),
                  const SizedBox(width: UIConstants.spacingXs),
                  _buildMacroChip(theme, '${meal.fats.toStringAsFixed(0)}g F', Colors.orange),
                  const SizedBox(width: UIConstants.spacingXs),
                  _buildMacroChip(theme, '${meal.netCarbs.toStringAsFixed(0)}g C', Colors.green),
                ],
              ),
              // Optional: Show hunger levels and eating reasons if available
              if (meal.hungerLevelBefore != null ||
                  meal.hungerLevelAfter != null ||
                  (meal.eatingReasons != null && meal.eatingReasons!.isNotEmpty))
                Padding(
                  padding: const EdgeInsets.only(top: UIConstants.spacingXs),
                  child: Row(
                    children: [
                      // Hunger levels (compact format)
                      if (meal.hungerLevelBefore != null || meal.hungerLevelAfter != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (meal.hungerLevelBefore != null)
                              Text(
                                '${meal.hungerLevelBefore}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 10,
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            if (meal.hungerLevelBefore != null && meal.hungerLevelAfter != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: UIConstants.spacingXs,
                                ),
                                child: Icon(
                                  Icons.arrow_forward,
                                  size: 12,
                                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                                ),
                              ),
                            if (meal.hungerLevelAfter != null)
                              Text(
                                '${meal.hungerLevelAfter}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 10,
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            if ((meal.hungerLevelBefore != null || meal.hungerLevelAfter != null) &&
                                meal.eatingReasons != null &&
                                meal.eatingReasons!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: UIConstants.spacingXs),
                                child: Text(
                                  '•',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 10,
                                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      // Eating reasons icons
                      if (meal.eatingReasons != null && meal.eatingReasons!.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: meal.eatingReasons!.take(3).map((reason) {
                            return Padding(
                              padding: const EdgeInsets.only(left: UIConstants.spacingXs),
                              child: Icon(
                                _getIconForReason(reason),
                                size: 14,
                                color: theme.colorScheme.primary,
                              ),
                            );
                          }).toList(),
                        ),
                      if (meal.eatingReasons != null &&
                          meal.eatingReasons!.length > 3)
                        Padding(
                          padding: const EdgeInsets.only(left: UIConstants.spacingXs),
                          child: Text(
                            '+${meal.eatingReasons!.length - 3}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${meal.calories.toStringAsFixed(0)} cal',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getMealTypeIcon(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return Icons.wb_sunny;
      case MealType.lunch:
        return Icons.lunch_dining;
      case MealType.dinner:
        return Icons.dinner_dining;
      case MealType.snack:
        return Icons.cookie;
    }
  }

  Widget _buildMacroChip(ThemeData theme, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.spacingXs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusSm),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  IconData _getIconForReason(EatingReason reason) {
    switch (reason.iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'mood_bad':
        return Icons.mood_bad;
      case 'celebration':
        return Icons.celebration;
      case 'sentiment_dissatisfied':
        return Icons.sentiment_dissatisfied;
      case 'bedtime':
        return Icons.bedtime;
      case 'schedule':
        return Icons.schedule;
      case 'groups':
        return Icons.groups;
      case 'cake':
        return Icons.cake;
      default:
        return Icons.restaurant_menu;
    }
  }
}

