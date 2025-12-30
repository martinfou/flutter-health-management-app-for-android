import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/features/nutrition_management/presentation/pages/nutrition_page.dart';
import 'package:health_app/features/nutrition_management/presentation/pages/meal_logging_page.dart';
import 'package:health_app/features/nutrition_management/presentation/pages/recipe_library_page.dart';
import 'package:health_app/features/nutrition_management/presentation/pages/macro_tracking_page.dart';

/// Sprint 5 Demo Page - Nutrition UI Features
class Sprint5DemoPage extends ConsumerWidget {
  const Sprint5DemoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sprint 5: Nutrition UI Demo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(UIConstants.screenPaddingHorizontal),
        children: [
          // Header
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(UIConstants.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sprint 5: Nutrition UI',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: UIConstants.spacingSm),
                  Text(
                    'Complete nutrition tracking interface with meal logging, recipe library, macro tracking, and visualization.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: UIConstants.spacingLg),

          // Main Nutrition Page
          _buildDemoCard(
            context,
            theme,
            'Main Nutrition Page',
            'Overview of daily nutrition with macro summary, recent meals, and quick actions.',
            Icons.restaurant_menu,
            Colors.blue,
            () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NutritionPage(),
                ),
              );
            },
          ),

          const SizedBox(height: UIConstants.spacingMd),

          // Meal Logging Page
          _buildDemoCard(
            context,
            theme,
            'Meal Logging',
            'Log meals with macro information. Add food items, select meal type, and save meals.',
            Icons.add_circle_outline,
            Colors.green,
            () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MealLoggingPage(),
                ),
              );
            },
          ),

          const SizedBox(height: UIConstants.spacingMd),

          // Recipe Library Page
          _buildDemoCard(
            context,
            theme,
            'Recipe Library',
            'Browse and search recipes. Filter by difficulty and prep time. View recipe details and log as meal.',
            Icons.menu_book,
            Colors.orange,
            () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const RecipeLibraryPage(),
                ),
              );
            },
          ),

          const SizedBox(height: UIConstants.spacingMd),

          // Macro Tracking Page
          _buildDemoCard(
            context,
            theme,
            'Macro Tracking',
            'View daily macro summary with progress bars. Track protein, fats, and net carbs against targets.',
            Icons.track_changes,
            Colors.purple,
            () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MacroTrackingPage(),
                ),
              );
            },
          ),

          const SizedBox(height: UIConstants.spacingLg),

          // Features List
          Card(
            child: Padding(
              padding: const EdgeInsets.all(UIConstants.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Completed Features',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: UIConstants.spacingMd),
                  _buildFeatureItem(theme, '✅ Nutrition Providers (Riverpod)'),
                  _buildFeatureItem(theme, '✅ Meal Logging Page with food items'),
                  _buildFeatureItem(theme, '✅ Macro Chart Widget (stacked bars)'),
                  _buildFeatureItem(theme, '✅ Recipe Library with search & filters'),
                  _buildFeatureItem(theme, '✅ Recipe Detail Page'),
                  _buildFeatureItem(theme, '✅ Macro Tracking Page with progress bars'),
                  _buildFeatureItem(theme, '✅ Nutrition Main Page with overview'),
                  _buildFeatureItem(theme, '✅ Meal Card Widget'),
                  _buildFeatureItem(theme, '✅ Recipe Card Widget'),
                ],
              ),
            ),
          ),

          const SizedBox(height: UIConstants.spacingLg),
        ],
      ),
    );
  }

  Widget _buildDemoCard(
    BuildContext context,
    ThemeData theme,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusMd),
        child: Padding(
          padding: const EdgeInsets.all(UIConstants.cardPadding),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: UIConstants.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingXs),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UIConstants.spacingXs),
      child: Row(
        children: [
          const SizedBox(width: UIConstants.spacingSm),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

