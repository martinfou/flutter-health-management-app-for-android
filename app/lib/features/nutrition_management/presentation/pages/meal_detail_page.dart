import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/widgets/custom_button.dart';
import 'package:health_app/features/nutrition_management/domain/entities/meal.dart';
import 'package:health_app/features/nutrition_management/domain/entities/meal_type.dart';
import 'package:health_app/features/nutrition_management/domain/entities/eating_reason.dart';
import 'package:health_app/features/nutrition_management/presentation/providers/nutrition_providers.dart';
import 'package:health_app/features/nutrition_management/presentation/widgets/hunger_scale_widget.dart';
import 'package:health_app/features/nutrition_management/presentation/pages/meal_logging_page.dart';
import 'package:health_app/features/nutrition_management/data/repositories/nutrition_repository_impl.dart';
import 'package:health_app/features/nutrition_management/data/datasources/local/nutrition_local_datasource.dart';

/// Meal detail page showing full meal information with edit/delete options
class MealDetailPage extends ConsumerStatefulWidget {
  /// Meal to display
  final Meal meal;

  /// Creates a meal detail page
  const MealDetailPage({
    super.key,
    required this.meal,
  });

  @override
  ConsumerState<MealDetailPage> createState() => _MealDetailPageState();
}

class _MealDetailPageState extends ConsumerState<MealDetailPage> {
  bool _isDeleting = false;

  Future<void> _deleteMeal() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal'),
        content: const Text('Are you sure you want to delete this meal? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    final repository = NutritionRepositoryImpl(NutritionLocalDataSource());
    final result = await repository.deleteMeal(widget.meal.id);

    if (!mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete meal: ${failure.message}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        setState(() {
          _isDeleting = false;
        });
      },
      (_) {
        // Invalidate providers to refresh data
        ref.invalidate(dailyMealsProvider);
        ref.invalidate(macroSummaryProvider);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal deleted successfully')),
        );
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final meal = widget.meal;
    final timeFormat = DateFormat('h:mm a');
    final dateFormat = DateFormat('MMMM d, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(meal.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _isDeleting ? null : _deleteMeal,
            tooltip: 'Delete Meal',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.screenPaddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Meal type and date card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.cardPadding),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      radius: 30,
                      child: Icon(
                        _getMealTypeIcon(meal.mealType),
                        color: theme.colorScheme.onPrimaryContainer,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: UIConstants.spacingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meal.mealType.displayName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: UIConstants.spacingXs),
                          Text(
                            '${dateFormat.format(meal.date)} • ${timeFormat.format(meal.date)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: UIConstants.spacingMd),

            // Macros card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nutrition Information',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingMd),
                    _MacroRow(
                      label: 'Protein',
                      value: meal.protein,
                      unit: 'g',
                      percent: meal.macroPercentages['protein'] ?? 0.0,
                    ),
                    const SizedBox(height: UIConstants.spacingXs),
                    _MacroRow(
                      label: 'Fats',
                      value: meal.fats,
                      unit: 'g',
                      percent: meal.macroPercentages['fats'] ?? 0.0,
                    ),
                    const SizedBox(height: UIConstants.spacingXs),
                    _MacroRow(
                      label: 'Net Carbs',
                      value: meal.netCarbs,
                      unit: 'g',
                      percent: meal.macroPercentages['carbs'] ?? 0.0,
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Calories',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${meal.calories.toStringAsFixed(0)} cal',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: UIConstants.spacingMd),

            // Ingredients card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ingredients',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingSm),
                    if (meal.ingredients.isEmpty)
                      Text(
                        'No ingredients listed',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      )
                    else
                      ...meal.ingredients.map((ingredient) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: UIConstants.spacingXs),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.circle,
                                size: 6,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: UIConstants.spacingSm),
                              Expanded(
                                child: Text(
                                  ingredient,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),

            // Meal Context card (only show if data exists)
            if (meal.hungerLevelBefore != null ||
                meal.hungerLevelAfter != null ||
                (meal.eatingReasons != null && meal.eatingReasons!.isNotEmpty))
              ...[
                const SizedBox(height: UIConstants.spacingMd),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(UIConstants.cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Meal Context',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: UIConstants.spacingMd),
                        
                        // Hunger/Fullness levels
                        if (meal.hungerLevelBefore != null ||
                            meal.hungerLevelAfter != null) ...[
                          Text(
                            'Hunger/Fullness:',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: UIConstants.spacingXs),
                          if (meal.hungerLevelBefore != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: UIConstants.spacingXs),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.restaurant_outlined,
                                    size: 18,
                                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                  const SizedBox(width: UIConstants.spacingXs),
                                  Text(
                                    'Before: ${HungerScaleWidget.getLabelForValue(meal.hungerLevelBefore!)} (${meal.hungerLevelBefore}/10)',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          if (meal.hungerLevelAfter != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: UIConstants.spacingSm),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline,
                                        size: 18,
                                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                                      ),
                                      const SizedBox(width: UIConstants.spacingXs),
                                      Text(
                                        'After: ${HungerScaleWidget.getLabelForValue(meal.hungerLevelAfter!)} (${meal.hungerLevelAfter}/10)',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                  if (meal.fullnessAfterTimestamp != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: UIConstants.spacingMd,
                                        top: UIConstants.spacingXs,
                                      ),
                                      child: Text(
                                        'Measured: ${timeFormat.format(meal.fullnessAfterTimestamp!)}',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          const SizedBox(height: UIConstants.spacingSm),
                        ],
                        
                        // Eating reasons
                        if (meal.eatingReasons != null && meal.eatingReasons!.isNotEmpty) ...[
                          if (meal.hungerLevelBefore != null ||
                              meal.hungerLevelAfter != null)
                            const Divider(),
                          const SizedBox(height: UIConstants.spacingXs),
                          Text(
                            'Eating Reasons:',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: UIConstants.spacingXs),
                          Wrap(
                            spacing: UIConstants.spacingXs,
                            runSpacing: UIConstants.spacingXs,
                            children: meal.eatingReasons!.map((reason) {
                              return Chip(
                                label: Text(reason.displayName),
                                avatar: Icon(
                                  _getIconForReason(reason),
                                  size: 18,
                                ),
                                backgroundColor: theme.colorScheme.primaryContainer,
                                labelStyle: TextStyle(
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],

            const SizedBox(height: UIConstants.spacingLg),

            // Edit button
            CustomButton(
              label: 'Edit Meal',
              onPressed: () {
                // Navigate to meal logging page with meal data pre-filled
                // Note: Full edit functionality would require an edit mode in MealLoggingPage
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MealLoggingPage(),
                  ),
                );
              },
              width: double.infinity,
            ),

            const SizedBox(height: UIConstants.screenPaddingHorizontal),
          ],
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

/// Macro row widget for displaying macro information
class _MacroRow extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final double percent;

  const _MacroRow({
    required this.label,
    required this.value,
    required this.unit,
    required this.percent,
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
          ],
        ),
      ],
    );
  }
}

