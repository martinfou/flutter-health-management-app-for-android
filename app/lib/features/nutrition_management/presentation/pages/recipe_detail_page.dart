import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/widgets/custom_button.dart';
import 'package:health_app/features/nutrition_management/domain/entities/recipe.dart';
import 'package:health_app/features/nutrition_management/domain/entities/meal_type.dart';
import 'package:health_app/features/nutrition_management/presentation/providers/nutrition_providers.dart';
import 'package:health_app/features/user_profile/presentation/providers/user_profile_repository_provider.dart';

/// Recipe detail page showing full recipe information
class RecipeDetailPage extends ConsumerStatefulWidget {
  /// Recipe to display
  final Recipe recipe;

  /// Creates a recipe detail page
  const RecipeDetailPage({
    super.key,
    required this.recipe,
  });

  @override
  ConsumerState<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends ConsumerState<RecipeDetailPage> {
  bool _isLogging = false;
  String? _errorMessage;
  String? _successMessage;

  Future<void> _logAsMeal() async {
    setState(() {
      _isLogging = true;
      _errorMessage = null;
      _successMessage = null;
    });

    // Show meal type selector
    final mealType = await showDialog<MealType>(
      context: context,
      builder: (context) => _MealTypeSelectorDialog(),
    );

    if (mealType == null) {
      setState(() {
        _isLogging = false;
      });
      return;
    }

    // Get user ID
    String? userId;
    try {
      final userRepo = ref.read(userProfileRepositoryProvider);
      final userResult = await userRepo.getCurrentUserProfile();
      userId = userResult.fold((_) => null, (profile) => profile.id);
    } catch (e) {
      userId = null;
    }

    if (userId == null) {
      setState(() {
        _isLogging = false;
        _errorMessage = 'User profile not found. Please set up your profile first.';
      });
      return;
    }

    // Log meal using LogMealUseCase
    final useCase = ref.read(logMealUseCaseProvider);
    final result = await useCase.call(
      userId: userId,
      mealType: mealType,
      name: widget.recipe.name,
      protein: widget.recipe.protein,
      fats: widget.recipe.fats,
      netCarbs: widget.recipe.netCarbs,
      calories: widget.recipe.calories,
      ingredients: widget.recipe.ingredients,
      recipeId: widget.recipe.id,
    );

    result.fold(
      (failure) {
        setState(() {
          _isLogging = false;
          _errorMessage = failure.message;
        });
      },
      (savedMeal) {
        setState(() {
          _isLogging = false;
          _successMessage = 'Meal logged successfully!';
        });
        // Invalidate providers to refresh data
        ref.invalidate(dailyMealsProvider);
        ref.invalidate(macroSummaryProvider);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recipe = widget.recipe;

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Recipe image
            if (recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty)
              Image.network(
                recipe.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.restaurant_menu,
                      size: 64,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                  );
                },
              )
            else
              Container(
                height: 200,
                color: theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.restaurant_menu,
                  size: 64,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(UIConstants.screenPaddingHorizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: UIConstants.spacingMd),

                  // Recipe name and description
                  Text(
                    recipe.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (recipe.description != null) ...[
                    const SizedBox(height: UIConstants.spacingSm),
                    Text(
                      recipe.description!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],

                  const SizedBox(height: UIConstants.spacingMd),

                  // Recipe info (time, difficulty, servings)
                  Wrap(
                    spacing: UIConstants.spacingSm,
                    runSpacing: UIConstants.spacingSm,
                    children: [
                      _buildInfoChip(
                        theme,
                        Icons.schedule,
                        '${recipe.totalTime} min',
                      ),
                      _buildInfoChip(
                        theme,
                        Icons.people,
                        '${recipe.servings} serving${recipe.servings > 1 ? 's' : ''}',
                      ),
                      _buildInfoChip(
                        theme,
                        Icons.restaurant_menu,
                        recipe.difficulty.displayName,
                      ),
                    ],
                  ),

                  const SizedBox(height: UIConstants.spacingLg),

                  // Macros card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(UIConstants.cardPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nutrition per Serving',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: UIConstants.spacingMd),
                          _MacroRow(
                            label: 'Protein',
                            value: recipe.protein,
                            unit: 'g',
                          ),
                          const SizedBox(height: UIConstants.spacingXs),
                          _MacroRow(
                            label: 'Fats',
                            value: recipe.fats,
                            unit: 'g',
                          ),
                          const SizedBox(height: UIConstants.spacingXs),
                          _MacroRow(
                            label: 'Net Carbs',
                            value: recipe.netCarbs,
                            unit: 'g',
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Calories',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${recipe.calories.toStringAsFixed(0)} cal',
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

                  const SizedBox(height: UIConstants.spacingLg),

                  // Ingredients
                  Text(
                    'Ingredients',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: UIConstants.spacingSm),
                  ...recipe.ingredients.map((ingredient) {
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

                  const SizedBox(height: UIConstants.spacingLg),

                  // Instructions
                  Text(
                    'Instructions',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: UIConstants.spacingSm),
                  ...recipe.instructions.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final instruction = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: UIConstants.spacingSm),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$index',
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: UIConstants.spacingSm),
                          Expanded(
                            child: Text(
                              instruction,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: UIConstants.spacingLg),

                  // Tags
                  if (recipe.tags.isNotEmpty) ...[
                    Wrap(
                      spacing: UIConstants.spacingXs,
                      runSpacing: UIConstants.spacingXs,
                      children: recipe.tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          labelStyle: theme.textTheme.bodySmall,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: UIConstants.spacingLg),
                  ],

                  // Error message
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: UIConstants.spacingSm),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: theme.colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Success message
                  if (_successMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: UIConstants.spacingSm),
                      child: Text(
                        _successMessage!,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Log as Meal button
                  CustomButton(
                    label: 'Log as Meal',
                    onPressed: _isLogging ? null : _logAsMeal,
                    isLoading: _isLogging,
                    width: double.infinity,
                  ),

                  const SizedBox(height: UIConstants.screenPaddingHorizontal),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(ThemeData theme, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.spacingSm,
        vertical: UIConstants.spacingXs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          const SizedBox(width: UIConstants.spacingXs),
          Text(
            label,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Macro row widget for displaying macro information
class _MacroRow extends StatelessWidget {
  final String label;
  final double value;
  final String unit;

  const _MacroRow({
    required this.label,
    required this.value,
    required this.unit,
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
        Text(
          '${value.toStringAsFixed(1)}$unit',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Dialog for selecting meal type
class _MealTypeSelectorDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Meal Type'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 300),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: MealType.values.map((type) {
              return ListTile(
                title: Text(type.displayName),
                onTap: () {
                  Navigator.of(context).pop(type);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

