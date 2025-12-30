import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/widgets/custom_button.dart';
import 'package:health_app/features/behavioral_support/presentation/providers/behavioral_providers.dart';
import 'package:health_app/features/behavioral_support/presentation/pages/habit_tracking_page.dart';
import 'package:health_app/features/behavioral_support/domain/entities/goal_status.dart';

/// Main behavioral support page showing overview of habits and goals
class BehavioralSupportPage extends ConsumerWidget {
  const BehavioralSupportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final habitsAsync = ref.watch(habitsProvider);
    final goalsAsync = ref.watch(goalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Behavioral Support'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.screenPaddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Habits Overview
            habitsAsync.when(
              data: (habits) {
                final activeHabits = habits.length;
                final totalStreaks = habits.fold<int>(
                  0,
                  (sum, habit) => sum + habit.currentStreak,
                );
                
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(UIConstants.cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Habits',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const HabitTrackingPage(),
                                  ),
                                );
                              },
                              child: const Text('View All'),
                            ),
                          ],
                        ),
                        const SizedBox(height: UIConstants.spacingMd),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatColumn(
                              theme,
                              'Active Habits',
                              activeHabits.toString(),
                              Icons.check_circle,
                            ),
                            _buildStatColumn(
                              theme,
                              'Total Streaks',
                              totalStreaks.toString(),
                              Icons.local_fire_department,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(UIConstants.cardPadding),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, stack) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(UIConstants.cardPadding),
                  child: Text('Error loading habits: $error'),
                ),
              ),
            ),

            const SizedBox(height: UIConstants.spacingMd),

            // Goals Overview
            goalsAsync.when(
              data: (goals) {
                final activeGoals = goals.where((g) => g.status == GoalStatus.inProgress).length;
                final completedGoals = goals.where((g) => g.status == GoalStatus.completed).length;
                
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(UIConstants.cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Goals',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: UIConstants.spacingMd),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatColumn(
                              theme,
                              'Active Goals',
                              activeGoals.toString(),
                              Icons.flag,
                            ),
                            _buildStatColumn(
                              theme,
                              'Completed',
                              completedGoals.toString(),
                              Icons.check_circle_outline,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(UIConstants.cardPadding),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, stack) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(UIConstants.cardPadding),
                  child: Text('Error loading goals: $error'),
                ),
              ),
            ),

            const SizedBox(height: UIConstants.spacingLg),

            // Quick Actions
            Text(
              'Quick Actions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: UIConstants.spacingMd),
            CustomButton(
              label: 'View Habits',
              icon: Icons.check_circle,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const HabitTrackingPage(),
                  ),
                );
              },
              width: double.infinity,
            ),
            const SizedBox(height: UIConstants.spacingSm),
            CustomButton(
              label: 'Create Goal',
              icon: Icons.flag,
              variant: ButtonVariant.secondary,
              onPressed: () {
                // TODO: Navigate to goal creation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Goal creation coming soon')),
                );
              },
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(ThemeData theme, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: theme.colorScheme.primary),
        const SizedBox(height: UIConstants.spacingXs),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

