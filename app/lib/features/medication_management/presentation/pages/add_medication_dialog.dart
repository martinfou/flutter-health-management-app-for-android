import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/widgets/custom_button.dart';
import 'package:health_app/features/medication_management/domain/usecases/add_medication.dart';
import 'package:health_app/features/medication_management/domain/entities/medication_frequency.dart';
import 'package:health_app/features/medication_management/domain/entities/time_of_day.dart' as app_time;
import 'package:health_app/features/medication_management/presentation/providers/medication_repository_provider.dart';
import 'package:health_app/features/medication_management/presentation/providers/medication_providers.dart';
import 'package:health_app/features/user_profile/presentation/providers/user_profile_repository_provider.dart';

/// Dialog for adding a new medication
class AddMedicationDialog extends ConsumerStatefulWidget {
  const AddMedicationDialog({super.key});

  @override
  ConsumerState<AddMedicationDialog> createState() => _AddMedicationDialogState();
}

class _AddMedicationDialogState extends ConsumerState<AddMedicationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  MedicationFrequency _frequency = MedicationFrequency.daily;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _reminderEnabled = true;
  List<app_time.TimeOfDay> _times = [app_time.TimeOfDay(hour: 8, minute: 0)];
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final frequencyOptions = MedicationFrequency.values;

    return AlertDialog(
      title: const Text('Add Medication'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Medication Name',
                  hintText: 'e.g., Aspirin',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter medication name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: UIConstants.spacingMd),
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosage',
                  hintText: 'e.g., 100mg, 1 tablet',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter dosage';
                  }
                  return null;
                },
              ),
              const SizedBox(height: UIConstants.spacingMd),
              DropdownButtonFormField<MedicationFrequency>(
                value: _frequency,
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                ),
                items: frequencyOptions.map((frequency) {
                  return DropdownMenuItem(
                    value: frequency,
                    child: Text(frequency.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _frequency = value;
                      _updateTimesForFrequency(value);
                    });
                  }
                },
              ),
              const SizedBox(height: UIConstants.spacingMd),
              _buildTimesSection(theme, context),
              const SizedBox(height: UIConstants.spacingMd),
              Row(
                children: [
                  Expanded(
                    child: Text('Start Date: ${_formatDate(_startDate)}'),
                  ),
                  TextButton(
                    onPressed: () => _selectStartDate(context),
                    child: const Text('Change'),
                  ),
                ],
              ),
              SwitchListTile(
                title: const Text('Reminder Enabled'),
                value: _reminderEnabled,
                onChanged: (value) {
                  setState(() {
                    _reminderEnabled = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        CustomButton(
          label: _isLoading ? 'Adding...' : 'Add',
          onPressed: _isLoading ? null : _saveMedication,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Widget _buildTimesSection(ThemeData theme, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Times',
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: UIConstants.spacingSm),
        ..._times.asMap().entries.map((entry) {
          final index = entry.key;
          final time = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: UIConstants.spacingSm),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTimeForIndex(context, index),
                    child: Container(
                      padding: const EdgeInsets.all(UIConstants.spacingSm),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colorScheme.outline),
                        borderRadius: BorderRadius.circular(UIConstants.borderRadiusSm),
                      ),
                      child: Text(time.toString()),
                    ),
                  ),
                ),
                if (_times.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _times.removeAt(index);
                      });
                    },
                  ),
              ],
            ),
          );
        }),
        if (_times.length < 4)
          TextButton.icon(
            onPressed: _addTime,
            icon: const Icon(Icons.add),
            label: const Text('Add Time'),
          ),
      ],
    );
  }

  Future<void> _selectTimeForIndex(BuildContext context, int index) async {
    final currentTime = _times[index];
    final flutterTimeOfDay = TimeOfDay(
      hour: currentTime.hour,
      minute: currentTime.minute,
    );
    
    final picked = await showTimePicker(
      context: context,
      initialTime: flutterTimeOfDay,
    );
    
    if (picked != null) {
      setState(() {
        _times[index] = app_time.TimeOfDay(hour: picked.hour, minute: picked.minute);
      });
    }
  }

  void _updateTimesForFrequency(MedicationFrequency frequency) {
    switch (frequency) {
      case MedicationFrequency.daily:
        _times = [app_time.TimeOfDay(hour: 8, minute: 0)];
        break;
      case MedicationFrequency.twiceDaily:
        _times = [
          app_time.TimeOfDay(hour: 8, minute: 0),
          app_time.TimeOfDay(hour: 20, minute: 0),
        ];
        break;
      case MedicationFrequency.threeTimesDaily:
        _times = [
          app_time.TimeOfDay(hour: 8, minute: 0),
          app_time.TimeOfDay(hour: 14, minute: 0),
          app_time.TimeOfDay(hour: 20, minute: 0),
        ];
        break;
      case MedicationFrequency.weekly:
      case MedicationFrequency.asNeeded:
        if (_times.isEmpty) {
          _times = [app_time.TimeOfDay(hour: 8, minute: 0)];
        }
        break;
    }
  }

  void _addTime() {
    setState(() {
      _times.add(app_time.TimeOfDay(hour: 12, minute: 0));
    });
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _saveMedication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userProfileRepo = ref.read(userProfileRepositoryProvider);
      final userResult = await userProfileRepo.getCurrentUserProfile();

      final userId = userResult.fold(
        (failure) => null,
        (profile) => profile.id,
      );

      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not found')),
          );
        }
        return;
      }

      final repository = ref.read(medicationRepositoryProvider);
      final useCase = AddMedicationUseCase(repository);

      final result = await useCase.call(
        userId: userId,
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        frequency: _frequency,
        times: _times,
        startDate: _startDate,
        endDate: _endDate,
        reminderEnabled: _reminderEnabled,
      );

      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${failure.message}')),
            );
          }
        },
        (_) {
          ref.invalidate(medicationsProvider);
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Medication added successfully')),
            );
          }
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

