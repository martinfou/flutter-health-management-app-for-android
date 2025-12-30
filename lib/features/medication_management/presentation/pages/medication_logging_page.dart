import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/widgets/custom_button.dart';
import 'package:health_app/features/medication_management/domain/entities/medication.dart';
import 'package:health_app/features/medication_management/domain/usecases/log_medication_dose.dart';
import 'package:health_app/features/medication_management/presentation/providers/medication_repository_provider.dart';
import 'package:intl/intl.dart';

/// Page for logging medication doses
class MedicationLoggingPage extends ConsumerStatefulWidget {
  /// Medication to log doses for
  final Medication medication;

  const MedicationLoggingPage({
    super.key,
    required this.medication,
  });

  @override
  ConsumerState<MedicationLoggingPage> createState() => _MedicationLoggingPageState();
}

class _MedicationLoggingPageState extends ConsumerState<MedicationLoggingPage> {
  final _formKey = GlobalKey<FormState>();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _takenAt = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, y');
    final timeFormat = DateFormat('h:mm a');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medication.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.screenPaddingHorizontal),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Medication info card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(UIConstants.cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.medication.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingSm),
                      Text('Dosage: ${widget.medication.dosage}'),
                      Text('Frequency: ${widget.medication.frequency.displayName}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: UIConstants.spacingLg),

              // Log form
              Text(
                'Log Medication Dose',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: UIConstants.spacingMd),

              TextFormField(
                controller: _dosageController,
                decoration: InputDecoration(
                  labelText: 'Dosage',
                  hintText: widget.medication.dosage,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter dosage';
                  }
                  return null;
                },
              ),
              const SizedBox(height: UIConstants.spacingMd),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date: ${dateFormat.format(_takenAt)}',
                          style: theme.textTheme.bodyLarge,
                        ),
                        TextButton(
                          onPressed: _selectDate,
                          child: const Text('Change Date'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Time: ${timeFormat.format(_takenAt)}',
                          style: theme.textTheme.bodyLarge,
                        ),
                        TextButton(
                          onPressed: _selectTime,
                          child: const Text('Change Time'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: UIConstants.spacingMd),

              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'Add any notes...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: UIConstants.spacingLg),

              CustomButton(
                label: _isLoading ? 'Logging...' : 'Log Dose',
                onPressed: _isLoading ? null : _logDose,
                isLoading: _isLoading,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _takenAt,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _takenAt = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _takenAt.hour,
          _takenAt.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_takenAt),
    );
    if (picked != null) {
      setState(() {
        _takenAt = DateTime(
          _takenAt.year,
          _takenAt.month,
          _takenAt.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _logDose() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(medicationRepositoryProvider);
      final useCase = LogMedicationDoseUseCase(repository);

      final result = await useCase.call(
        medicationId: widget.medication.id,
        dosage: _dosageController.text.trim(),
        takenAt: _takenAt,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
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
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Medication dose logged successfully')),
            );
            _dosageController.clear();
            _notesController.clear();
            setState(() {
              _takenAt = DateTime.now();
            });
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

