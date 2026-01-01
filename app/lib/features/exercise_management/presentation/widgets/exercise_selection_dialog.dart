// Dart SDK
import 'package:flutter/material.dart';

// Packages
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/widgets/loading_indicator.dart';
import 'package:health_app/features/exercise_management/domain/entities/exercise.dart';
import 'package:health_app/features/exercise_management/domain/entities/exercise_type.dart';
import 'package:health_app/features/exercise_management/presentation/providers/exercise_providers.dart';
import 'package:health_app/features/exercise_management/presentation/widgets/exercise_template_form.dart';

/// Exercise selection dialog
/// 
/// Allows users to select an exercise from the exercise library or create a new one.
/// Returns the selected Exercise entity or null if cancelled.
class ExerciseSelectionDialog extends ConsumerStatefulWidget {
  const ExerciseSelectionDialog({super.key});

  @override
  ConsumerState<ExerciseSelectionDialog> createState() =>
      _ExerciseSelectionDialogState();
}

class _ExerciseSelectionDialogState
    extends ConsumerState<ExerciseSelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _createNewExercise() async {
    final formKey = GlobalKey<FormState>();
    final formWidgetKey = GlobalKey<ExerciseTemplateFormState>();
    
    final result = await showDialog<Exercise>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create Exercise'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 600),
          child: SingleChildScrollView(
            child: ExerciseTemplateForm(
              key: formWidgetKey,
              formKey: formKey,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) {
                return;
              }

              final formState = formWidgetKey.currentState;
              if (formState == null) return;

              final exerciseData = formState.getExerciseData();
              if (exerciseData == null) return;

              final userId = await ref.read(currentUserIdProvider.future);
              if (userId == null) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User profile not found'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                return;
              }

              final useCase = ref.read(createExerciseTemplateUseCaseProvider);
              final createResult = await useCase.call(
                userId: userId,
                name: exerciseData['name'] as String,
                type: exerciseData['type'] as ExerciseType,
                sets: exerciseData['sets'] as int?,
                reps: exerciseData['reps'] as int?,
                weight: exerciseData['weight'] as double?,
                duration: exerciseData['duration'] as int?,
                distance: exerciseData['distance'] as double?,
                muscleGroups: exerciseData['muscleGroups'] as List<String>,
                equipment: exerciseData['equipment'] as List<String>,
                notes: exerciseData['notes'] as String?,
              );

              createResult.fold(
                (failure) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to create exercise: ${failure.message}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                (exercise) {
                  if (mounted) {
                    Navigator.of(dialogContext).pop(exercise);
                  }
                },
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      // Refresh library and return the newly created exercise
      ref.invalidate(exerciseLibraryProvider);
      Navigator.of(context).pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exercisesAsync = ref.watch(exerciseLibraryProvider);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(UIConstants.screenPaddingHorizontal),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Select Exercise',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.screenPaddingHorizontal,
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search exercises',
                  hintText: 'Search by name, type, muscle groups...',
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                ),
                autofocus: true,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),

            const SizedBox(height: UIConstants.spacingSm),

            // Create new exercise button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.screenPaddingHorizontal,
              ),
              child: OutlinedButton.icon(
                onPressed: _createNewExercise,
                icon: const Icon(Icons.add),
                label: const Text('Create New Exercise'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),

            const SizedBox(height: UIConstants.spacingSm),
            const Divider(),

            // Exercise list
            Flexible(
              child: exercisesAsync.when(
                data: (exercises) {
                  // Filter exercises based on search query
                  final filteredExercises = exercises.where((exercise) {
                    if (_searchQuery.isEmpty) return true;
                    final query = _searchQuery;
                    return exercise.name.toLowerCase().contains(query) ||
                        exercise.type.displayName.toLowerCase().contains(query) ||
                        exercise.muscleGroups
                            .any((mg) => mg.toLowerCase().contains(query)) ||
                        exercise.equipment
                            .any((eq) => eq.toLowerCase().contains(query));
                  }).toList();

                  if (filteredExercises.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(UIConstants.spacingLg),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.fitness_center,
                            size: 48,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: UIConstants.spacingMd),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No exercises in library'
                                : 'No exercises found',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: UIConstants.spacingSm),
                          Text(
                            _searchQuery.isEmpty
                                ? 'Create your first exercise to get started'
                                : 'Try a different search term',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(UIConstants.spacingSm),
                    shrinkWrap: true,
                    itemCount: filteredExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = filteredExercises[index];
                      return _ExerciseSelectionItem(
                        exercise: exercise,
                        onTap: () {
                          Navigator.of(context).pop(exercise);
                        },
                      );
                    },
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(UIConstants.spacingLg),
                  child: LoadingIndicator(),
                ),
                error: (error, stack) => Padding(
                  padding: const EdgeInsets.all(UIConstants.spacingLg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: UIConstants.spacingMd),
                      Text(
                        'Failed to load exercises',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingSm),
                      TextButton(
                        onPressed: () {
                          ref.invalidate(exerciseLibraryProvider);
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Cancel button
            Padding(
              padding: const EdgeInsets.all(UIConstants.screenPaddingHorizontal),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Exercise selection item widget
class _ExerciseSelectionItem extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onTap;

  const _ExerciseSelectionItem({
    required this.exercise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: UIConstants.spacingXs),
      child: ListTile(
        title: Text(exercise.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: UIConstants.spacingXs),
            Text(
              'Type: ${exercise.type.displayName}',
              style: theme.textTheme.bodySmall,
            ),
            if (exercise.muscleGroups.isNotEmpty)
              Text(
                'Muscles: ${exercise.muscleGroups.join(", ")}',
                style: theme.textTheme.bodySmall,
              ),
            if (exercise.equipment.isNotEmpty)
              Text(
                'Equipment: ${exercise.equipment.join(", ")}',
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
        onTap: onTap,
        isThreeLine: exercise.muscleGroups.isNotEmpty ||
            exercise.equipment.isNotEmpty,
      ),
    );
  }
}

