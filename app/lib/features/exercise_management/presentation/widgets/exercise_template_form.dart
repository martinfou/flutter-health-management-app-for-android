// Dart SDK
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/features/exercise_management/domain/entities/exercise.dart';
import 'package:health_app/features/exercise_management/domain/entities/exercise_type.dart';

/// Exercise template form widget
/// 
/// A form for creating or editing exercise templates.
/// This form is similar to the workout logging exercise form but is specifically
/// designed for exercise templates (no date field).
class ExerciseTemplateForm extends StatefulWidget {
  /// Initial exercise to edit (null for new exercise)
  final Exercise? initialExercise;

  /// Form key
  final GlobalKey<FormState>? formKey;

  /// Creates an ExerciseTemplateForm
  const ExerciseTemplateForm({
    super.key,
    this.initialExercise,
    this.formKey,
  });

  @override
  State<ExerciseTemplateForm> createState() =>
      ExerciseTemplateFormState();
}

/// State class for ExerciseTemplateForm
class ExerciseTemplateFormState extends State<ExerciseTemplateForm> {

  /// Get exercise data from form
  /// 
  /// Returns null if validation fails, otherwise returns exercise data as map.
  Map<String, dynamic>? getExerciseData() {
    if (widget.formKey?.currentState?.validate() ?? false) {
      final name = _nameController.text.trim();
      if (name.isEmpty) {
        return null;
      }

      final muscleGroupsText = _muscleGroupsController.text.trim();
      final muscleGroups = muscleGroupsText.isEmpty
          ? <String>[]
          : muscleGroupsText
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();

      final equipmentText = _equipmentController.text.trim();
      final equipment = equipmentText.isEmpty
          ? <String>[]
          : equipmentText
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();

      return {
        'name': name,
        'type': _selectedType,
        'sets': int.tryParse(_setsController.text),
        'reps': int.tryParse(_repsController.text),
        'weight': double.tryParse(_weightController.text),
        'duration': int.tryParse(_durationController.text),
        'distance': double.tryParse(_distanceController.text),
        'muscleGroups': muscleGroups,
        'equipment': equipment,
        'notes': _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      };
    }
    return null;
  }

  late final TextEditingController _nameController;
  late final TextEditingController _setsController;
  late final TextEditingController _repsController;
  late final TextEditingController _weightController;
  late final TextEditingController _durationController;
  late final TextEditingController _distanceController;
  late final TextEditingController _notesController;
  late final TextEditingController _muscleGroupsController;
  late final TextEditingController _equipmentController;

  late ExerciseType _selectedType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _setsController = TextEditingController();
    _repsController = TextEditingController();
    _weightController = TextEditingController();
    _durationController = TextEditingController();
    _distanceController = TextEditingController();
    _notesController = TextEditingController();
    _muscleGroupsController = TextEditingController();
    _equipmentController = TextEditingController();

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
    } else {
      _selectedType = ExerciseType.strength;
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


  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
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

          // Muscle groups
          TextFormField(
            controller: _muscleGroupsController,
            decoration: const InputDecoration(
              labelText: 'Muscle Groups',
              hintText: 'e.g., Chest, Shoulders, Triceps',
              border: OutlineInputBorder(),
              helperText: 'Separate multiple groups with commas',
            ),
          ),
          const SizedBox(height: UIConstants.spacingSm),

          // Equipment
          TextFormField(
            controller: _equipmentController,
            decoration: const InputDecoration(
              labelText: 'Equipment',
              hintText: 'e.g., Barbell, Dumbbells',
              border: OutlineInputBorder(),
              helperText: 'Separate multiple items with commas',
            ),
          ),
          const SizedBox(height: UIConstants.spacingSm),

          // Sets and Reps (for strength exercises)
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
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
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
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.spacingSm),

          // Weight
          TextFormField(
            controller: _weightController,
            decoration: const InputDecoration(
              labelText: 'Weight (kg)',
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
          ),
          const SizedBox(height: UIConstants.spacingSm),

          // Duration
          TextFormField(
            controller: _durationController,
            decoration: const InputDecoration(
              labelText: 'Duration (minutes)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          const SizedBox(height: UIConstants.spacingSm),

          // Distance
          TextFormField(
            controller: _distanceController,
            decoration: const InputDecoration(
              labelText: 'Distance (km)',
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
          ),
          const SizedBox(height: UIConstants.spacingSm),

          // Notes
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes',
              hintText: 'Additional notes...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}

