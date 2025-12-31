import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/widgets/custom_button.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';
import 'package:health_app/features/health_tracking/domain/usecases/save_health_metric.dart';
import 'package:health_app/features/health_tracking/presentation/providers/health_metrics_provider.dart' as providers;
import 'package:health_app/features/health_tracking/presentation/providers/health_tracking_repository_provider.dart';
import 'package:health_app/features/health_tracking/presentation/widgets/measurement_form_widget.dart';
import 'package:health_app/features/user_profile/presentation/providers/user_profile_repository_provider.dart';
import 'package:health_app/features/user_profile/domain/entities/user_profile.dart';
import 'package:health_app/features/user_profile/domain/entities/gender.dart';

/// Body measurements entry page
class MeasurementsPage extends ConsumerStatefulWidget {
  const MeasurementsPage({super.key});

  @override
  ConsumerState<MeasurementsPage> createState() => _MeasurementsPageState();
}

class _MeasurementsPageState extends ConsumerState<MeasurementsPage> {
  final Map<String, TextEditingController> _controllers = {
    'waist': TextEditingController(),
    'hips': TextEditingController(),
    'neck': TextEditingController(),
    'chest': TextEditingController(),
    'thigh': TextEditingController(),
  };
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

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
      });
    }
  }

  Map<String, double>? _getLastMeasurements() {
    final metricsAsync = ref.read(providers.healthMetricsProvider);
    final metrics = metricsAsync.value;
    if (metrics == null) return null;
    
    final selectedDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final matchingMetrics = metrics.where((m) {
      final metricDate = DateTime(m.date.year, m.date.month, m.date.day);
      return metricDate.isBefore(selectedDate) && m.bodyMeasurements != null;
    }).toList();
    
    if (matchingMetrics.isEmpty) return null;
    
    matchingMetrics.sort((a, b) => b.date.compareTo(a.date));
    return matchingMetrics.first.bodyMeasurements;
  }

  String _getChangeIndicator(String key, double current, double? last) {
    if (last == null) return '';
    final change = current - last;
    if (change.abs() < 0.1) return '→';
    return change > 0 ? '↑' : '↓';
  }

  Future<void> _saveMeasurements() async {
    final measurements = <String, double>{};
    for (final entry in _controllers.entries) {
      final value = entry.value.text.trim();
      if (value.isNotEmpty) {
        final numValue = double.tryParse(value);
        if (numValue != null && numValue > 0) {
          measurements[entry.key] = numValue;
        }
      }
    }

    if (measurements.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter at least one measurement';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _successMessage = null;
    });

    String? userId;
    try {
      userId = await ref.read(providers.currentUserIdProvider.future);
    } catch (e) {
      userId = null;
    }
    
    // Create default user profile if none exists
    if (userId == null) {
      final userRepo = ref.read(userProfileRepositoryProvider);
      final now = DateTime.now();
      final defaultProfile = UserProfile(
        id: 'user-${now.millisecondsSinceEpoch}',
        name: 'User',
        email: 'user@example.com',
        dateOfBirth: DateTime(1990, 1, 1),
        gender: Gender.other,
        height: 175.0,
        targetWeight: 70.0,
        syncEnabled: false,
        createdAt: now,
        updatedAt: now,
      );
      
      final profileResult = await userRepo.saveUserProfile(defaultProfile);
      profileResult.fold(
        (failure) {
          setState(() {
            _isSaving = false;
            _errorMessage = 'Failed to create user profile: ${failure.message}';
          });
          return;
        },
        (profile) {
          userId = profile.id;
          ref.invalidate(providers.currentUserIdProvider);
        },
      );
      
      if (userId == null) {
        return;
      }
    }

    // userId is guaranteed to be non-null at this point
    final finalUserId = userId!;

    final repository = ref.read(healthTrackingRepositoryProvider);
    final useCase = SaveHealthMetricUseCase(repository);

    final metric = HealthMetric(
      id: '',
      userId: finalUserId,
      date: _selectedDate,
      bodyMeasurements: measurements,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await useCase(metric);

    result.fold(
      (failure) {
        setState(() {
          _isSaving = false;
          _errorMessage = failure.message;
        });
      },
      (savedMetric) {
        setState(() {
          _isSaving = false;
          _successMessage = 'Measurements saved successfully!';
          for (final controller in _controllers.values) {
            controller.clear();
          }
        });
        ref.invalidate(providers.healthMetricsProvider);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lastMeasurements = _getLastMeasurements();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Measurements'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.screenPaddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date picker
            Card(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.cardPadding),
                child: OutlinedButton.icon(
                  onPressed: _selectDate,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    DateFormat('MMMM d, yyyy').format(_selectedDate),
                  ),
                ),
              ),
            ),

            const SizedBox(height: UIConstants.spacingMd),

            // Measurement form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.cardPadding),
                child: MeasurementFormWidget(
                  controllers: _controllers,
                  onChanged: (key, value) {
                    setState(() {
                      _errorMessage = null;
                      _successMessage = null;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: UIConstants.spacingMd),

            // Last measurements card
            if (lastMeasurements != null && lastMeasurements.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(UIConstants.cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last Measurements',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: UIConstants.spacingSm),
                      ...lastMeasurements.entries.map((entry) {
                        final currentText = _controllers[entry.key]?.text.trim();
                        final current = currentText != null && currentText.isNotEmpty
                            ? double.tryParse(currentText)
                            : null;
                        final change = current != null
                            ? _getChangeIndicator(entry.key, current, entry.value)
                            : '';

                        return ListTile(
                          title: Text(entry.key.toUpperCase()),
                          subtitle: Text('${entry.value.toStringAsFixed(1)} cm'),
                          trailing: current != null
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      change,
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: change == '↓'
                                            ? Colors.green
                                            : change == '↑'
                                                ? Colors.red
                                                : Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(width: UIConstants.spacingXs),
                                    Text(
                                      '${(current - entry.value).abs().toStringAsFixed(1)} cm',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                )
                              : null,
                        );
                      }),
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
                  style: TextStyle(color: theme.colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),

            // Success message
            if (_successMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: UIConstants.spacingSm),
                child: Text(
                  _successMessage!,
                  style: TextStyle(color: theme.colorScheme.primary),
                  textAlign: TextAlign.center,
                ),
              ),

            // Save button
            CustomButton(
              label: 'Save Measurements',
              onPressed: _isSaving ? null : _saveMeasurements,
              isLoading: _isSaving,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}

