// Dart SDK
import 'package:flutter/material.dart';

// Packages
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/widgets/custom_button.dart';
import 'package:health_app/core/widgets/loading_indicator.dart';
import 'package:health_app/core/widgets/error_widget.dart' as core_error;
import 'package:health_app/features/exercise_management/domain/entities/exercise.dart';
import 'package:health_app/features/exercise_management/presentation/providers/exercise_providers.dart';
import 'package:health_app/features/exercise_management/presentation/pages/exercise_library_page.dart';
import 'package:health_app/features/exercise_management/presentation/pages/workout_plan_page.dart';
import 'package:health_app/features/exercise_management/presentation/pages/workout_logging_page.dart';
import 'package:health_app/features/exercise_management/presentation/widgets/workout_card_widget.dart';
import 'package:health_app/features/exercise_management/presentation/widgets/exercise_list_widget.dart';
import 'package:health_app/features/exercise_management/presentation/widgets/ai_workout_adaptation_widget.dart';

/// Main exercise page showing overview of workouts and activity
class ExercisePage extends ConsumerWidget {
  const ExercisePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final startDate = DateTime(today.year, today.month, today.day).subtract(const Duration(days: 7));
    final endDate = DateTime(today.year, today.month, today.day).add(const Duration(days: 1));

    final workoutPlansAsync = ref.watch(workoutPlansProvider);
    final workoutHistoryParams = WorkoutHistoryParams(
      startDate: startDate,
      endDate: endDate,
    );
    final recentWorkoutsAsync = ref.watch(workoutHistoryProvider(workoutHistoryParams));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise'),
        actions: [
          IconButton(
            icon: const Icon(Icons.library_books),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ExerciseLibraryPage(),
                ),
              );
            },
            tooltip: 'Exercise Library',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.screenPaddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Activity summary card (basic display for MVP)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Activity Summary',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingMd),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildActivityStat(
                          theme,
                          'Steps',
                          '--',
                          Icons.directions_walk,
                          Colors.blue,
                        ),
                        _buildActivityStat(
                          theme,
                          'Active Min',
                          '--',
                          Icons.timer,
                          Colors.orange,
                        ),
                        _buildActivityStat(
                          theme,
                          'Calories',
                          '--',
                          Icons.local_fire_department,
                          Colors.red,
                        ),
                      ],
                    ),
                    const SizedBox(height: UIConstants.spacingSm),
                    Text(
                      'Note: Full Google Fit/Health Connect integration coming in post-MVP',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: UIConstants.spacingMd),

            // Workout plans section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Workout Plans',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const WorkoutPlanPage(),
                      ),
                    );
                  },
                  child: const Text('Create Plan'),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.spacingSm),
            workoutPlansAsync.when(
              data: (plans) {
                if (plans.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(UIConstants.cardPadding),
                      child: Column(
                        children: [
                          Icon(
                            Icons.fitness_center,
                            size: 48,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: UIConstants.spacingSm),
                          Text(
                            'No workout plans yet',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: UIConstants.spacingSm),
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const WorkoutPlanPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Create Plan'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Column(
                  children: plans.map((plan) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: UIConstants.spacingSm),
                      child: WorkoutCardWidget(plan: plan),
                    );
                  }).toList(),
                );
              },
              loading: () => const LoadingIndicator(),
              error: (error, stack) => core_error.ErrorWidget(
                message: 'Failed to load workout plans',
              ),
            ),

            const SizedBox(height: UIConstants.spacingLg),

            // Recent workouts section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Workouts',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to full workout history page
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.spacingSm),
            recentWorkoutsAsync.when(
              data: (exercises) {
                if (exercises.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(UIConstants.cardPadding),
                      child: Column(
                        children: [
                          Icon(
                            Icons.sports_gymnastics,
                            size: 48,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: UIConstants.spacingSm),
                          Text(
                            'No workouts logged yet',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                // Remove duplicates by ID and take most recent 5
                final uniqueExercises = <String, Exercise>{};
                for (final exercise in exercises) {
                  if (!uniqueExercises.containsKey(exercise.id)) {
                    uniqueExercises[exercise.id] = exercise;
                  }
                }
                final recentUnique = uniqueExercises.values
                    .where((e) => e.date != null) // Filter out templates
                    .toList()
                  ..sort((a, b) => b.date!.compareTo(a.date!));
                
                return Column(
                  children: [
                    ExerciseListWidget(
                      exercises: recentUnique.take(5).toList(),
                    ),
                    const SizedBox(height: UIConstants.spacingMd),
                    AiWorkoutAdaptationWidget(
                      selectedExercise: recentUnique.isNotEmpty ? recentUnique.first : null,
                    ),
                  ],
                );
              },
              loading: () => const LoadingIndicator(),
              error: (error, stack) => core_error.ErrorWidget(
                message: 'Failed to load recent workouts',
              ),
            ),

            const SizedBox(height: UIConstants.spacingLg),

            // Quick actions
            Text(
              'Quick Actions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: UIConstants.spacingMd),
            CustomButton(
              label: 'Log Workout',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const WorkoutLoggingPage(),
                  ),
                );
              },
              icon: Icons.add,
              width: double.infinity,
            ),
            const SizedBox(height: UIConstants.spacingSm),
            CustomButton(
              label: 'Create Workout Plan',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const WorkoutPlanPage(),
                  ),
                );
              },
              icon: Icons.fitness_center,
              variant: ButtonVariant.secondary,
              width: double.infinity,
            ),
            const SizedBox(height: UIConstants.spacingMd),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityStat(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: UIConstants.spacingXs),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

