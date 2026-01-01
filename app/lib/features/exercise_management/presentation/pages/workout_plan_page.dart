// Dart SDK
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Packages
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/widgets/custom_button.dart';
import 'package:health_app/features/exercise_management/domain/entities/exercise.dart';
import 'package:health_app/features/exercise_management/domain/entities/workout_plan.dart';
import 'package:health_app/features/exercise_management/presentation/providers/exercise_providers.dart';
import 'package:health_app/features/exercise_management/presentation/widgets/exercise_selection_dialog.dart';

/// Workout plan page for creating and managing workout plans
class WorkoutPlanPage extends ConsumerStatefulWidget {
  const WorkoutPlanPage({super.key});

  @override
  ConsumerState<WorkoutPlanPage> createState() => _WorkoutPlanPageState();
}

class _WorkoutPlanPageState extends ConsumerState<WorkoutPlanPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController(text: '4');
  
  final Set<String> _selectedDays = {};
  final Map<String, List<String>> _dayExercises = {}; // Stores Exercise IDs
  final Map<String, Exercise> _exerciseCache = {}; // Cache of Exercise ID -> Exercise entity
  final Map<String, String?> _dayFocus = {};
  final Map<String, int?> _dayDuration = {};
  
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;
  WorkoutPlan? _createdPlan;

  static const List<String> _weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];


  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _toggleDay(String day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
        _dayExercises.remove(day);
        _dayFocus.remove(day);
        _dayDuration.remove(day);
      } else {
        _selectedDays.add(day);
        _dayExercises[day] = [];
        _dayFocus[day] = null;
        _dayDuration[day] = null;
      }
      _errorMessage = null;
      _successMessage = null;
    });
  }

  Future<void> _addExerciseToDay(String day) async {
    final result = await showDialog<Exercise>(
      context: context,
      builder: (context) => const ExerciseSelectionDialog(),
    );

    if (result != null) {
      setState(() {
        // Store Exercise ID
        _dayExercises[day] = [...(_dayExercises[day] ?? []), result.id];
        // Cache Exercise entity for display
        _exerciseCache[result.id] = result;
        _errorMessage = null;
        _successMessage = null;
      });
    }
  }

  void _removeExerciseFromDay(String day, int index) {
    setState(() {
      _dayExercises[day]?.removeAt(index);
      _errorMessage = null;
      _successMessage = null;
    });
  }

  Future<void> _setDayFocus(String day) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _FocusSelectorDialog(
        currentFocus: _dayFocus[day],
      ),
    );

    if (result != null) {
      setState(() {
        _dayFocus[day] = result.isEmpty ? null : result;
        _errorMessage = null;
        _successMessage = null;
      });
    }
  }

  Future<void> _setDayDuration(String day) async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => _DurationInputDialog(
        currentDuration: _dayDuration[day],
      ),
    );

    if (result != null) {
      setState(() {
        _dayDuration[day] = result > 0 ? result : null;
        _errorMessage = null;
        _successMessage = null;
      });
    }
  }

  Future<void> _savePlan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDays.isEmpty) {
      setState(() {
        _errorMessage = 'Please select at least one day';
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

    // Build workout days
    final workoutDays = _selectedDays.map((dayName) {
      return WorkoutDay(
        dayName: dayName,
        exerciseIds: _dayExercises[dayName] ?? [],
        focus: _dayFocus[dayName],
        estimatedDuration: _dayDuration[dayName],
      );
    }).toList();

    // Use CreateWorkoutPlanUseCase to validate and create plan
    final useCase = ref.read(createWorkoutPlanUseCaseProvider);
    final durationWeeks = int.tryParse(_durationController.text) ?? 4;
    
    final result = useCase.call(
      userId: userId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      days: workoutDays,
      durationWeeks: durationWeeks,
    );

    result.fold(
      (failure) {
        setState(() {
          _isSaving = false;
          _errorMessage = failure.message;
        });
      },
      (plan) {
        setState(() {
          _isSaving = false;
          _createdPlan = plan;
          _successMessage = 'Workout plan created successfully! '
              'Note: Workout plan persistence is not yet implemented in MVP.';
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Workout Plan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.screenPaddingHorizontal),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Plan name input
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(UIConstants.cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Plan Name',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingSm),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'e.g., Push/Pull Split',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a plan name';
                          }
                          return null;
                        },
                        onChanged: (_) {
                          setState(() {
                            _errorMessage = null;
                            _successMessage = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: UIConstants.spacingMd),

              // Description input
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(UIConstants.cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description (Optional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingSm),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          hintText: 'Describe your workout plan...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        onChanged: (_) {
                          setState(() {
                            _errorMessage = null;
                            _successMessage = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: UIConstants.spacingMd),

              // Duration input
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(UIConstants.cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Duration (Weeks)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingSm),
                      TextFormField(
                        controller: _durationController,
                        decoration: const InputDecoration(
                          hintText: '4',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter duration';
                          }
                          final weeks = int.tryParse(value);
                          if (weeks == null || weeks < 1 || weeks > 52) {
                            return 'Duration must be between 1 and 52 weeks';
                          }
                          return null;
                        },
                        onChanged: (_) {
                          setState(() {
                            _errorMessage = null;
                            _successMessage = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: UIConstants.spacingMd),

              // Day selector
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(UIConstants.cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Days',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingSm),
                      Wrap(
                        spacing: UIConstants.spacingSm,
                        runSpacing: UIConstants.spacingSm,
                        children: _weekDays.map((day) {
                          final isSelected = _selectedDays.contains(day);
                          return FilterChip(
                            label: Text(day),
                            selected: isSelected,
                            onSelected: (_) => _toggleDay(day),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: UIConstants.spacingMd),

              // Weekly schedule view
              if (_selectedDays.isNotEmpty) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(UIConstants.cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Weekly Schedule',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: UIConstants.spacingSm),
                        ..._selectedDays.map((day) {
                          return _DayScheduleCard(
                            day: day,
                            exerciseIds: _dayExercises[day] ?? [],
                            exerciseCache: _exerciseCache,
                            focus: _dayFocus[day],
                            duration: _dayDuration[day],
                            onAddExercise: () => _addExerciseToDay(day),
                            onRemoveExercise: (index) => _removeExerciseFromDay(day, index),
                            onSetFocus: () => _setDayFocus(day),
                            onSetDuration: () => _setDayDuration(day),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: UIConstants.spacingMd),
              ],

              // Plan overview (if created)
              if (_createdPlan != null) ...[
                Card(
                  color: theme.colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(UIConstants.cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Plan Overview',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: UIConstants.spacingSm),
                        Text('Name: ${_createdPlan!.name}'),
                        if (_createdPlan!.description != null)
                          Text('Description: ${_createdPlan!.description}'),
                        Text('Duration: ${_createdPlan!.durationWeeks} weeks'),
                        Text('Days: ${_createdPlan!.days.length}'),
                        Text('Start Date: ${_createdPlan!.startDate.toString().split(' ')[0]}'),
                        Text('End Date: ${_createdPlan!.endDate.toString().split(' ')[0]}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: UIConstants.spacingMd),
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

              // Save button
              CustomButton(
                label: 'Create Plan',
                onPressed: _isSaving ? null : _savePlan,
                isLoading: _isSaving,
                width: double.infinity,
              ),
              const SizedBox(height: UIConstants.spacingMd),
            ],
          ),
        ),
      ),
    );
  }
}

/// Day schedule card widget
class _DayScheduleCard extends StatelessWidget {
  final String day;
  final List<String> exerciseIds;
  final Map<String, Exercise> exerciseCache;
  final String? focus;
  final int? duration;
  final VoidCallback onAddExercise;
  final ValueChanged<int> onRemoveExercise;
  final VoidCallback onSetFocus;
  final VoidCallback onSetDuration;

  const _DayScheduleCard({
    required this.day,
    required this.exerciseIds,
    required this.exerciseCache,
    required this.focus,
    required this.duration,
    required this.onAddExercise,
    required this.onRemoveExercise,
    required this.onSetFocus,
    required this.onSetDuration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: UIConstants.spacingSm),
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  day,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: onAddExercise,
                      tooltip: 'Add Exercise',
                    ),
                    IconButton(
                      icon: const Icon(Icons.fitness_center),
                      onPressed: onSetFocus,
                      tooltip: 'Set Focus',
                    ),
                    IconButton(
                      icon: const Icon(Icons.timer),
                      onPressed: onSetDuration,
                      tooltip: 'Set Duration',
                    ),
                  ],
                ),
              ],
            ),
            if (focus != null) ...[
              const SizedBox(height: UIConstants.spacingXs),
              Chip(
                label: Text('Focus: $focus'),
                avatar: const Icon(Icons.fitness_center, size: 16),
              ),
            ],
            if (duration != null) ...[
              const SizedBox(height: UIConstants.spacingXs),
              Chip(
                label: Text('Duration: $duration min'),
                avatar: const Icon(Icons.timer, size: 16),
              ),
            ],
            if (exerciseIds.isEmpty)
              Padding(
                padding: const EdgeInsets.all(UIConstants.spacingMd),
                child: Text(
                  'No exercises added. Tap + to add.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              )
            else
              ...exerciseIds.asMap().entries.map((entry) {
                final index = entry.key;
                final exerciseId = entry.value;
                final exercise = exerciseCache[exerciseId];
                return ListTile(
                  dense: true,
                  title: Text(exercise?.name ?? 'Unknown Exercise (ID: $exerciseId)'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => onRemoveExercise(index),
                    tooltip: 'Remove',
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

/// Dialog for adding exercise
class _AddExerciseDialog extends StatefulWidget {
  @override
  State<_AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<_AddExerciseDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Exercise'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Exercise Name',
          hintText: 'e.g., Bench Press',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.trim().isNotEmpty) {
              Navigator.of(context).pop(_controller.text.trim());
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

/// Dialog for selecting focus
class _FocusSelectorDialog extends StatelessWidget {
  final String? currentFocus;

  const _FocusSelectorDialog({this.currentFocus});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Focus'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('None'),
            leading: Radio<String>(
              value: '',
              groupValue: currentFocus ?? '',
              onChanged: (value) => Navigator.of(context).pop(''),
            ),
          ),
          ..._focusOptions.map((focus) {
            return ListTile(
              title: Text(focus),
              leading: Radio<String>(
                value: focus,
                groupValue: currentFocus ?? '',
                onChanged: (value) => Navigator.of(context).pop(value),
              ),
            );
          }),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  static const _focusOptions = [
    'Push',
    'Pull',
    'Legs',
    'Cardio',
    'Full Body',
    'Upper Body',
    'Lower Body',
    'Rest',
  ];
}

/// Dialog for inputting duration
class _DurationInputDialog extends StatefulWidget {
  final int? currentDuration;

  const _DurationInputDialog({this.currentDuration});

  @override
  State<_DurationInputDialog> createState() => _DurationInputDialogState();
}

class _DurationInputDialogState extends State<_DurationInputDialog> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.currentDuration != null) {
      _controller.text = widget.currentDuration.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Duration'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Duration (minutes)',
          hintText: 'e.g., 60',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final duration = int.tryParse(_controller.text);
            Navigator.of(context).pop(duration ?? 0);
          },
          child: const Text('Set'),
        ),
      ],
    );
  }
}

