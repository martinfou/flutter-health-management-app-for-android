// Dart SDK
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// Packages
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/widgets/custom_button.dart';
import 'package:health_app/features/exercise_management/domain/entities/exercise_type.dart';
import 'package:health_app/features/exercise_management/presentation/providers/exercise_providers.dart';

/// Exercise entry model for workout logging
class ExerciseEntry {
  final String name;
  final ExerciseType type;
  final int? sets;
  final int? reps;
  final double? weight;
  final int? duration;
  final double? distance;
  final List<String> muscleGroups;
  final List<String> equipment;
  final String? notes;

  ExerciseEntry({
    required this.name,
    required this.type,
    this.sets,
    this.reps,
    this.weight,
    this.duration,
    this.distance,
    this.muscleGroups = const [],
    this.equipment = const [],
    this.notes,
  });

  ExerciseEntry copyWith({
    String? name,
    ExerciseType? type,
    int? sets,
    int? reps,
    double? weight,
    int? duration,
    double? distance,
    List<String>? muscleGroups,
    List<String>? equipment,
    String? notes,
  }) {
    return ExerciseEntry(
      name: name ?? this.name,
      type: type ?? this.type,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      duration: duration ?? this.duration,
      distance: distance ?? this.distance,
      muscleGroups: muscleGroups ?? this.muscleGroups,
      equipment: equipment ?? this.equipment,
      notes: notes ?? this.notes,
    );
  }
}

/// Workout logging page for logging exercises
class WorkoutLoggingPage extends ConsumerStatefulWidget {
  const WorkoutLoggingPage({super.key});

  @override
  ConsumerState<WorkoutLoggingPage> createState() => _WorkoutLoggingPageState();
}

class _WorkoutLoggingPageState extends ConsumerState<WorkoutLoggingPage> {
  DateTime _selectedDate = DateTime.now();
  final List<ExerciseEntry> _exercises = [];
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _errorMessage = null;
        _successMessage = null;
      });
    }
  }

  Future<void> _addExercise() async {
    final result = await showDialog<ExerciseEntry>(
      context: context,
      builder: (context) => _ExerciseEntryDialog(),
    );

    if (result != null) {
      setState(() {
        _exercises.add(result);
        _errorMessage = null;
        _successMessage = null;
      });
    }
  }

  Future<void> _editExercise(int index) async {
    final exercise = _exercises[index];
    final result = await showDialog<ExerciseEntry>(
      context: context,
      builder: (context) => _ExerciseEntryDialog(initialExercise: exercise),
    );

    if (result != null) {
      setState(() {
        _exercises[index] = result;
        _errorMessage = null;
        _successMessage = null;
      });
    }
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
      _errorMessage = null;
      _successMessage = null;
    });
  }

  Future<void> _saveWorkout() async {
    if (_exercises.isEmpty) {
      setState(() {
        _errorMessage = 'Please add at least one exercise';
      });
      return;
    }

    // Get user ID
    String? userId;
    try {
      userId = await ref.read(currentUserIdProvider.future);
    } catch (e) {
      userId = null;
    }

    if (userId == null) {
      setState(() {
        _errorMessage = 'User profile not found. Please set up your profile first.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _successMessage = null;
    });

    // Save each exercise
    final useCase = ref.read(logWorkoutUseCaseProvider);
    int successCount = 0;
    String? lastError;

    for (final exercise in _exercises) {
      final result = await useCase.call(
        userId: userId,
        name: exercise.name,
        type: exercise.type,
        date: _selectedDate,
        sets: exercise.sets,
        reps: exercise.reps,
        weight: exercise.weight,
        duration: exercise.duration,
        distance: exercise.distance,
        muscleGroups: exercise.muscleGroups,
        equipment: exercise.equipment,
        notes: exercise.notes,
      );

      result.fold(
        (failure) {
          lastError = failure.message;
        },
        (_) {
          successCount++;
        },
      );
    }

    setState(() {
      _isSaving = false;
      if (successCount == _exercises.length) {
        _successMessage = 'Workout saved successfully!';
        _exercises.clear();
      } else if (successCount > 0) {
        _errorMessage = 'Some exercises saved. Error: ${lastError ?? "Unknown error"}';
      } else {
        _errorMessage = lastError ?? 'Failed to save workout';
      }
    });

    // Invalidate providers to refresh data
    if (successCount > 0) {
      ref.invalidate(workoutHistoryProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Workout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.screenPaddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date picker card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.cardPadding),
                child: Column(
                  children: [
                    const Text(
                      'Workout Date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingSm),
                    OutlinedButton.icon(
                      onPressed: _selectDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        DateFormat('MMMM d, yyyy').format(_selectedDate),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: UIConstants.spacingMd),

            // Exercises list card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Exercises',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addExercise,
                          tooltip: 'Add Exercise',
                        ),
                      ],
                    ),
                    const SizedBox(height: UIConstants.spacingSm),
                    if (_exercises.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(UIConstants.spacingMd),
                        child: Text(
                          'No exercises added yet. Tap the + button to add.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _exercises.length,
                        itemBuilder: (context, index) {
                          final exercise = _exercises[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: UIConstants.spacingSm),
                            child: ListTile(
                              title: Text(exercise.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Type: ${exercise.type.displayName}'),
                                  if (exercise.sets != null && exercise.reps != null)
                                    Text('${exercise.sets} sets × ${exercise.reps} reps'),
                                  if (exercise.weight != null)
                                    Text('Weight: ${exercise.weight} kg'),
                                  if (exercise.duration != null)
                                    Text('Duration: ${exercise.duration} min'),
                                  if (exercise.distance != null)
                                    Text('Distance: ${exercise.distance} km'),
                                  if (exercise.notes != null && exercise.notes!.isNotEmpty)
                                    Text('Notes: ${exercise.notes}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _editExercise(index),
                                    tooltip: 'Edit',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _removeExercise(index),
                                    tooltip: 'Remove',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: UIConstants.spacingMd),

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

            // Save button
            CustomButton(
              label: 'Save Workout',
              onPressed: _isSaving ? null : _saveWorkout,
              isLoading: _isSaving,
              width: double.infinity,
            ),
            const SizedBox(height: UIConstants.spacingMd),
          ],
        ),
      ),
    );
  }
}

/// Dialog for adding/editing exercise entry
class _ExerciseEntryDialog extends StatefulWidget {
  final ExerciseEntry? initialExercise;

  const _ExerciseEntryDialog({this.initialExercise});

  @override
  State<_ExerciseEntryDialog> createState() => _ExerciseEntryDialogState();
}

class _ExerciseEntryDialogState extends State<_ExerciseEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  final _durationController = TextEditingController();
  final _distanceController = TextEditingController();
  final _notesController = TextEditingController();
  final _muscleGroupsController = TextEditingController();
  final _equipmentController = TextEditingController();

  ExerciseType _selectedType = ExerciseType.strength;

  @override
  void initState() {
    super.initState();
    if (widget.initialExercise != null) {
      final ex = widget.initialExercise!;
      _nameController.text = ex.name;
      _selectedType = ex.type;
      _setsController.text = ex.sets?.toString() ?? '';
      _repsController.text = ex.reps?.toString() ?? '';
      _weightController.text = ex.weight?.toString() ?? '';
      _durationController.text = ex.duration?.toString() ?? '';
      _distanceController.text = ex.distance?.toString() ?? '';
      _notesController.text = ex.notes ?? '';
      _muscleGroupsController.text = ex.muscleGroups.join(', ');
      _equipmentController.text = ex.equipment.join(', ');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _durationController.dispose();
    _distanceController.dispose();
    _notesController.dispose();
    _muscleGroupsController.dispose();
    _equipmentController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      return;
    }

    final muscleGroupsText = _muscleGroupsController.text.trim();
    final muscleGroups = muscleGroupsText.isEmpty
        ? <String>[]
        : muscleGroupsText.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList().cast<String>();

    final equipmentText = _equipmentController.text.trim();
    final equipment = equipmentText.isEmpty
        ? <String>[]
        : equipmentText.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList().cast<String>();

    final exercise = ExerciseEntry(
      name: name,
      type: _selectedType,
      sets: int.tryParse(_setsController.text),
      reps: int.tryParse(_repsController.text),
      weight: double.tryParse(_weightController.text),
      duration: int.tryParse(_durationController.text),
      distance: double.tryParse(_distanceController.text),
      muscleGroups: muscleGroups,
      equipment: equipment,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    Navigator.of(context).pop(exercise);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialExercise == null ? 'Add Exercise' : 'Edit Exercise'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 600),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Exercise name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Exercise Name',
                    hintText: 'e.g., Bench Press',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter exercise name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: UIConstants.spacingSm),

                // Exercise type
                DropdownButtonFormField<ExerciseType>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Exercise Type',
                    border: OutlineInputBorder(),
                  ),
                  items: ExerciseType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: UIConstants.spacingSm),

                // Sets and Reps (for strength)
                if (_selectedType == ExerciseType.strength) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _setsController,
                          decoration: const InputDecoration(
                            labelText: 'Sets',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            final num = int.tryParse(value);
                            if (num == null || num < 1) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: UIConstants.spacingSm),
                      Expanded(
                        child: TextFormField(
                          controller: _repsController,
                          decoration: const InputDecoration(
                            labelText: 'Reps',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            final num = int.tryParse(value);
                            if (num == null || num < 1) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: UIConstants.spacingSm),
                  TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                  ),
                ],

                // Duration (for cardio/flexibility)
                if (_selectedType == ExerciseType.cardio ||
                    _selectedType == ExerciseType.flexibility) ...[
                  TextFormField(
                    controller: _durationController,
                    decoration: const InputDecoration(
                      labelText: 'Duration (minutes)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final num = int.tryParse(value);
                      if (num == null || num < 1) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: UIConstants.spacingSm),
                ],

                // Distance (for cardio)
                if (_selectedType == ExerciseType.cardio) ...[
                  TextFormField(
                    controller: _distanceController,
                    decoration: const InputDecoration(
                      labelText: 'Distance (km)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                  ),
                  const SizedBox(height: UIConstants.spacingSm),
                ],

                // Muscle groups
                TextFormField(
                  controller: _muscleGroupsController,
                  decoration: const InputDecoration(
                    labelText: 'Muscle Groups (comma-separated)',
                    hintText: 'e.g., chest, triceps',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: UIConstants.spacingSm),

                // Equipment
                TextFormField(
                  controller: _equipmentController,
                  decoration: const InputDecoration(
                    labelText: 'Equipment (comma-separated)',
                    hintText: 'e.g., barbell, bench',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: UIConstants.spacingSm),

                // Notes
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
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
          child: const Text('Save'),
        ),
      ],
    );
  }
}

