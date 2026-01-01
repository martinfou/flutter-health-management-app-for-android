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

/// Exercise library page
/// 
/// Displays all exercise templates and allows users to create, edit, and delete them.
class ExerciseLibraryPage extends ConsumerStatefulWidget {
  const ExerciseLibraryPage({super.key});

  @override
  ConsumerState<ExerciseLibraryPage> createState() =>
      _ExerciseLibraryPageState();
}

class _ExerciseLibraryPageState extends ConsumerState<ExerciseLibraryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _createExercise() async {
    final result = await showDialog<Exercise>(
      context: context,
      builder: (context) => _ExerciseTemplateDialog(),
    );

    if (result != null && mounted) {
      // Refresh the library
      ref.invalidate(exerciseLibraryProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exercise created successfully')),
      );
    }
  }

  Future<void> _editExercise(Exercise exercise) async {
    final result = await showDialog<Exercise>(
      context: context,
      builder: (context) => _ExerciseTemplateDialog(initialExercise: exercise),
    );

    if (result != null && mounted) {
      // Refresh the library
      ref.invalidate(exerciseLibraryProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exercise updated successfully')),
      );
    }
  }

  Future<void> _deleteExercise(Exercise exercise) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Exercise'),
        content: Text('Are you sure you want to delete "${exercise.name}"?'),
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

    if (confirmed == true && mounted) {
      final useCase = ref.read(deleteExerciseTemplateUseCaseProvider);
      final result = await useCase.call(exerciseId: exercise.id);

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete exercise: ${failure.message}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        },
        (_) {
          // Refresh the library
          ref.invalidate(exerciseLibraryProvider);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Exercise deleted successfully')),
            );
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exercisesAsync = ref.watch(exerciseLibraryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Library'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(UIConstants.screenPaddingHorizontal),
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
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Exercise list
          Expanded(
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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 64,
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
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(UIConstants.screenPaddingHorizontal),
                  itemCount: filteredExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = filteredExercises[index];
                    return _ExerciseListItem(
                      exercise: exercise,
                      onEdit: () => _editExercise(exercise),
                      onDelete: () => _deleteExercise(exercise),
                    );
                  },
                );
              },
              loading: () => const LoadingIndicator(),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createExercise,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Exercise list item widget
class _ExerciseListItem extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExerciseListItem({
    required this.exercise,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: UIConstants.spacingSm),
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
            if (exercise.sets != null && exercise.reps != null)
              Text(
                '${exercise.sets} sets × ${exercise.reps} reps',
                style: theme.textTheme.bodySmall,
              ),
            if (exercise.weight != null)
              Text(
                'Weight: ${exercise.weight} kg',
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
              tooltip: 'Delete',
              color: theme.colorScheme.error,
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}

/// Dialog for creating/editing exercise template
class _ExerciseTemplateDialog extends ConsumerStatefulWidget {
  final Exercise? initialExercise;

  const _ExerciseTemplateDialog({this.initialExercise});

  @override
  ConsumerState<_ExerciseTemplateDialog> createState() =>
      _ExerciseTemplateDialogState();
}

class _ExerciseTemplateDialogState
    extends ConsumerState<_ExerciseTemplateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _formWidgetKey = GlobalKey<ExerciseTemplateFormState>();

  void _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final formState = _formWidgetKey.currentState;
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

    if (widget.initialExercise == null) {
      // Create new exercise
      final useCase = ref.read(createExerciseTemplateUseCaseProvider);
      final result = await useCase.call(
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

      result.fold(
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
            Navigator.of(context).pop(exercise);
          }
        },
      );
    } else {
      // Update existing exercise
      final useCase = ref.read(updateExerciseTemplateUseCaseProvider);
      final updatedExercise = widget.initialExercise!.copyWith(
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

      final result = await useCase.call(exercise: updatedExercise);

      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to update exercise: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (exercise) {
          if (mounted) {
            Navigator.of(context).pop(exercise);
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialExercise == null
          ? 'Create Exercise'
          : 'Edit Exercise'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 600),
        child: SingleChildScrollView(
          child: ExerciseTemplateForm(
            key: _formWidgetKey,
            initialExercise: widget.initialExercise,
            formKey: _formKey,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: Text(widget.initialExercise == null ? 'Create' : 'Save'),
        ),
      ],
    );
  }
}

