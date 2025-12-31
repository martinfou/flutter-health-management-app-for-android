import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/widgets/custom_button.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';
import 'package:health_app/features/health_tracking/domain/usecases/save_health_metric.dart';
import 'package:health_app/features/health_tracking/domain/usecases/update_health_metric.dart';
import 'package:health_app/features/health_tracking/presentation/providers/health_metrics_provider.dart' as providers;
import 'package:health_app/features/health_tracking/presentation/providers/health_tracking_repository_provider.dart';
import 'package:health_app/features/health_tracking/presentation/widgets/measurement_form_widget.dart';
import 'package:health_app/features/user_profile/presentation/providers/user_profile_repository_provider.dart';
import 'package:health_app/features/user_profile/domain/entities/user_profile.dart';
import 'package:health_app/features/user_profile/domain/entities/gender.dart';
import 'package:health_app/core/providers/user_preferences_provider.dart';
import 'package:health_app/core/utils/unit_converter.dart';
import 'package:health_app/core/utils/format_utils.dart';

/// Body measurements entry page
/// 
/// Supports both creating new entries and editing existing ones.
/// When [metricId] is provided, the page opens in edit mode.
class MeasurementsPage extends ConsumerStatefulWidget {
  /// Optional metric ID for edit mode
  final String? metricId;

  const MeasurementsPage({super.key, this.metricId});

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
  bool _isLoading = true;
  String? _errorMessage;
  String? _successMessage;
  HealthMetric? _existingMetric;

  bool get _isEditMode => widget.metricId != null && widget.metricId!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingMetric();
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadExistingMetric() async {
    if (!_isEditMode) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final repository = ref.read(healthTrackingRepositoryProvider);
      final result = await repository.getHealthMetric(widget.metricId!);

      result.fold(
        (failure) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _errorMessage = 'Failed to load metric: ${failure.message}';
            });
          }
        },
        (metric) {
          if (mounted) {
            // Convert metric values to display units for editing
            final useImperial = ref.read(unitPreferenceProvider);
            setState(() {
              _existingMetric = metric;
              _selectedDate = metric.date;
              if (metric.bodyMeasurements != null) {
                for (final entry in metric.bodyMeasurements!.entries) {
                  if (_controllers.containsKey(entry.key)) {
                    // Convert from metric to display units
                    final displayValue = useImperial
                        ? UnitConverter.convertLengthMetricToImperial(entry.value)
                        : entry.value;
                    _controllers[entry.key]!.text = displayValue.toStringAsFixed(1);
                  }
                }
              }
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error loading metric: $e';
        });
      }
    }
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
    // Convert user input from display units to metric for storage
    final useImperial = ref.read(unitPreferenceProvider);
    final measurements = <String, double>{};
    for (final entry in _controllers.entries) {
      final value = entry.value.text.trim();
      if (value.isNotEmpty) {
        final numValue = double.tryParse(value);
        if (numValue != null && numValue > 0) {
          // Convert to metric before storing
          final metricValue = useImperial
              ? UnitConverter.convertLengthImperialToMetric(numValue)
              : numValue;
          measurements[entry.key] = metricValue;
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

    if (_isEditMode && _existingMetric != null) {
      // Update existing metric
      final useCase = UpdateHealthMetricUseCase(repository);
      
      final updatedMetric = _existingMetric!.copyWith(
        bodyMeasurements: measurements,
      );

      final result = await useCase(updatedMetric);

      result.fold(
        (failure) {
          setState(() {
            _isSaving = false;
            _errorMessage = failure.message;
          });
        },
        (updatedMetric) {
          setState(() {
            _isSaving = false;
            _successMessage = 'Measurements updated successfully!';
          });
          ref.invalidate(providers.healthMetricsProvider);
          // Pop back to previous screen after a short delay
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              Navigator.of(context).pop();
            }
          });
        },
      );
    } else {
      // Create new metric entry
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lastMeasurements = _getLastMeasurements();
    final useImperial = ref.watch(unitPreferenceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Body Measurements' : 'Body Measurements'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(context, theme, lastMeasurements, useImperial),
    );
  }

  Widget _buildBody(BuildContext context, ThemeData theme, Map<String, double>? lastMeasurements, bool useImperial) {
    return SingleChildScrollView(
      child: Padding(
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
                        // Convert last measurement from metric to display units
                        final lastDisplay = useImperial
                            ? UnitConverter.convertLengthMetricToImperial(entry.value)
                            : entry.value;
                        
                        final currentText = _controllers[entry.key]?.text.trim();
                        final current = currentText != null && currentText.isNotEmpty
                            ? double.tryParse(currentText)
                            : null;
                        
                        // For change calculation, compare display values
                        final change = current != null
                            ? _getChangeIndicator(entry.key, current, lastDisplay)
                            : '';

                        return ListTile(
                          title: Text(entry.key.toUpperCase()),
                          subtitle: Text(FormatUtils.formatLengthValue(entry.value, useImperial)),
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
                                      FormatUtils.formatLengthValue((current - lastDisplay).abs(), useImperial),
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
              label: _isSaving
                  ? (_isEditMode ? 'Updating...' : 'Saving...')
                  : (_isEditMode ? 'Update Measurements' : 'Save Measurements'),
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
