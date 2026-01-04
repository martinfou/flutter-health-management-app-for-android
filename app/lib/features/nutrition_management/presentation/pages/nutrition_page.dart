import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/widgets/loading_indicator.dart';
import 'package:health_app/shared/widgets/ai_provider_indicator.dart';
import 'package:health_app/features/nutrition_management/presentation/providers/nutrition_providers.dart';
import 'package:health_app/features/nutrition_management/presentation/pages/meal_logging_page.dart';
import 'package:health_app/features/nutrition_management/presentation/pages/recipe_library_page.dart';
import 'package:health_app/features/nutrition_management/presentation/pages/macro_tracking_page.dart';
import 'package:health_app/features/nutrition_management/presentation/widgets/macro_chart_widget.dart';
import 'package:health_app/features/nutrition_management/presentation/widgets/meal_card_widget.dart';
import 'package:health_app/features/nutrition_management/presentation/widgets/ai_meal_suggestion_widget.dart';

/// Main nutrition page showing overview of daily nutrition
class NutritionPage extends ConsumerWidget {
  const NutritionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final dateOnly = DateTime(today.year, today.month, today.day);

    final mealsAsync = ref.watch(dailyMealsProvider(dateOnly));
    final macroSummary = ref.watch(macroSummaryProvider(dateOnly));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: AiProviderIndicator(showLabel: false),
          ),
        ],
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Today\'s Macros',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const MacroTrackingPage(),
                              ),
                            );
                          },
                          child: const Text('View Details'),
                        ),
                      ],
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

                    // Macro breakdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMacroColumn(
                          theme,
                          'Protein',
                          macroSummary.protein,
                          'g',
                          macroSummary.proteinPercent,
                          Colors.blue,
                        ),
                        _buildMacroColumn(
                          theme,
                          'Fats',
                          macroSummary.fats,
                          'g',
                          macroSummary.fatsPercent,
                          Colors.orange,
                        ),
                        _buildMacroColumn(
                          theme,
                          'Net Carbs',
                          macroSummary.netCarbs,
                          'g',
                          macroSummary.carbsPercent,
                          Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: UIConstants.spacingMd),

            // Macro chart
            const MacroChartWidget(),

            const SizedBox(height: UIConstants.spacingMd),

            // Quick actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingMd),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.add_circle_outline,
                            label: 'Log Meal',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const MealLoggingPage(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: UIConstants.spacingMd),
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.restaurant_menu,
                            label: 'Recipes',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const RecipeLibraryPage(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: UIConstants.spacingMd),
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.track_changes,
                            label: 'Macros',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const MacroTrackingPage(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: UIConstants.spacingMd),

            // AI Meal Suggestions
            const AiMealSuggestionWidget(),

            const SizedBox(height: UIConstants.spacingMd),

            // Recent meals
            Card(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Today\'s Meals',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const MealLoggingPage(),
                              ),
                            );
                          },
                          child: const Text('Add Meal'),
                        ),
                      ],
                    ),
                    const SizedBox(height: UIConstants.spacingSm),
                    mealsAsync.when(
                      data: (meals) {
                        if (meals.isEmpty) {
                          return Padding(
                            padding:
                                const EdgeInsets.all(UIConstants.spacingMd),
                            child: Text(
                              'No meals logged today. Tap "Add Meal" to get started!',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        // Sort meals by date (most recent first)
                        final sortedMeals = List<dynamic>.from(meals)
                          ..sort((a, b) => b.date.compareTo(a.date));

                        return Column(
                          children: sortedMeals.take(5).map((meal) {
                            return MealCardWidget(meal: meal);
                          }).toList(),
                        );
                      },
                      loading: () => const LoadingIndicator(),
                      error: (error, stack) => Padding(
                        padding: const EdgeInsets.all(UIConstants.spacingMd),
                        child: Text(
                          'Failed to load meals',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
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

  Widget _buildMacroColumn(
    ThemeData theme,
    String label,
    double value,
    String unit,
    double percent,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${percent.toStringAsFixed(0)}%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: UIConstants.spacingXs),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
        Text(
          '${value.toStringAsFixed(1)}$unit',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Quick action button widget
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(UIConstants.borderRadiusMd),
      child: Container(
        padding: const EdgeInsets.all(UIConstants.spacingMd),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusMd),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: UIConstants.spacingXs),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
