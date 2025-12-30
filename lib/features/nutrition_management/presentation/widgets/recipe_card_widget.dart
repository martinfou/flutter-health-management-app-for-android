import 'package:flutter/material.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/features/nutrition_management/domain/entities/recipe.dart';
import 'package:health_app/features/nutrition_management/domain/entities/recipe_difficulty.dart';

/// Widget displaying a recipe card in the recipe library grid
class RecipeCardWidget extends StatelessWidget {
  /// Recipe to display
  final Recipe recipe;

  /// Callback when card is tapped
  final VoidCallback onTap;

  /// Creates a recipe card widget
  const RecipeCardWidget({
    super.key,
    required this.recipe,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe image placeholder or actual image
            Container(
              height: 120,
              width: double.infinity,
              color: theme.colorScheme.primaryContainer,
              child: recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
                  ? Image.network(
                      recipe.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildImagePlaceholder(theme);
                      },
                    )
                  : _buildImagePlaceholder(theme),
            ),
            
            // Recipe info
            Padding(
              padding: const EdgeInsets.all(UIConstants.spacingSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipe name
                  Text(
                    recipe.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: UIConstants.spacingXs),
                  
                  // Macros (one line)
                  Row(
                    children: [
                      Icon(
                        Icons.restaurant,
                        size: 12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: UIConstants.spacingXs),
                      Expanded(
                        child: Text(
                          '${recipe.protein.toStringAsFixed(0)}g P / '
                          '${recipe.fats.toStringAsFixed(0)}g F / '
                          '${recipe.netCarbs.toStringAsFixed(0)}g C',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: UIConstants.spacingXs),
                  
                  // Time and difficulty
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: UIConstants.spacingXs),
                      Flexible(
                        child: Text(
                          '${recipe.totalTime} min',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: UIConstants.spacingSm),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: UIConstants.spacingXs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(recipe.difficulty, theme)
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(UIConstants.borderRadiusSm),
                          ),
                          child: Text(
                            recipe.difficulty.displayName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _getDifficultyColor(recipe.difficulty, theme),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Calories
                  Padding(
                    padding: const EdgeInsets.only(top: UIConstants.spacingXs),
                    child: Text(
                      '${recipe.calories.toStringAsFixed(0)} cal per serving',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.restaurant_menu,
          size: 48,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Color _getDifficultyColor(RecipeDifficulty difficulty, ThemeData theme) {
    switch (difficulty) {
      case RecipeDifficulty.easy:
        return Colors.green;
      case RecipeDifficulty.medium:
        return Colors.orange;
      case RecipeDifficulty.hard:
        return Colors.red;
    }
  }
}

