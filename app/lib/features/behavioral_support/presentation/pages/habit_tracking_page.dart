import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/features/behavioral_support/presentation/providers/behavioral_providers.dart';
import 'package:health_app/features/behavioral_support/presentation/widgets/habit_card_widget.dart';
import 'package:health_app/features/behavioral_support/presentation/pages/add_habit_dialog.dart';
import 'package:health_app/features/behavioral_support/domain/usecases/track_habit.dart';
import 'package:health_app/features/behavioral_support/presentation/providers/behavioral_repository_provider.dart';
import 'package:health_app/features/behavioral_support/domain/entities/habit.dart';

/// Page for tracking habits and viewing streaks
class HabitTrackingPage extends ConsumerWidget {
  const HabitTrackingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final habitsAsync = ref.watch(habitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracking'),
      ),
      body: habitsAsync.when(
        data: (habits) {
          if (habits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: UIConstants.spacingMd),
                  Text(
                    'No habits yet',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: UIConstants.spacingSm),
                  Text(
                    'Tap the + button to add a habit',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(UIConstants.screenPaddingHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'My Habits',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: UIConstants.spacingMd),
                ...habits.map((habit) => HabitCardWidget(
                      habit: habit,
                      onToggleCompletion: () => _toggleHabitCompletion(context, ref, habit),
                    )),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading habits: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHabitDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const AddHabitDialog(),
    );
  }

  void _toggleHabitCompletion(BuildContext context, WidgetRef ref, Habit habit) {
    final repository = ref.read(behavioralRepositoryProvider);
    final useCase = TrackHabitUseCase(repository);

    useCase.call(habitId: habit.id).then((result) {
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${failure.message}')),
          );
        },
        (_) {
          ref.invalidate(habitsProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Habit updated')),
          );
        },
      );
    });
  }
}

