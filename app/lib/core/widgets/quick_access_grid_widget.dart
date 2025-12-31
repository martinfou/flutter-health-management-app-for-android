// Dart SDK
import 'package:flutter/material.dart';

// Project
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/navigation/app_router.dart';
import 'package:health_app/features/behavioral_support/presentation/pages/habit_tracking_page.dart';
import 'package:health_app/features/health_tracking/presentation/pages/weight_entry_page.dart';
import 'package:health_app/features/health_tracking/presentation/pages/sleep_energy_page.dart';

/// Widget for displaying quick access grid to all features
class QuickAccessGridWidget extends StatelessWidget {
  /// Creates QuickAccessGridWidget
  const QuickAccessGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: UIConstants.spacingMd,
      crossAxisSpacing: UIConstants.spacingMd,
      childAspectRatio: 1.0,
      children: [
        _buildQuickAccessButton(
          context,
          'Weight',
          Icons.monitor_weight,
          () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const WeightEntryPage(),
              ),
            );
          },
        ),
        _buildQuickAccessButton(
          context,
          'Sleep',
          Icons.bedtime,
          () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SleepEnergyPage(),
              ),
            );
          },
        ),
        _buildQuickAccessButton(
          context,
          'Health',
          Icons.favorite,
          () => AppRouter.navigateTo(context, AppRoutes.healthTracking),
        ),
        _buildQuickAccessButton(
          context,
          'Meals',
          Icons.restaurant,
          () => AppRouter.navigateTo(context, AppRoutes.nutrition),
        ),
        _buildQuickAccessButton(
          context,
          'Workout',
          Icons.fitness_center,
          () => AppRouter.navigateTo(context, AppRoutes.exercise),
        ),
        _buildQuickAccessButton(
          context,
          'Medication',
          Icons.medication_liquid,
          () => AppRouter.navigateTo(context, AppRoutes.medication),
        ),
        _buildQuickAccessButton(
          context,
          'Habits',
          Icons.check_circle,
          () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const HabitTrackingPage(),
              ),
            );
          },
        ),
        _buildQuickAccessButton(
          context,
          'Analytics',
          Icons.analytics,
          () => AppRouter.navigateTo(context, AppRoutes.analytics),
        ),
      ],
    );
  }

  Widget _buildQuickAccessButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(UIConstants.borderRadiusMd),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusMd),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: UIConstants.iconSizeLg,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: UIConstants.spacingSm),
            Text(
              label,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

