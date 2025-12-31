import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/widgets/custom_button.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';
import 'package:health_app/features/health_tracking/domain/usecases/save_health_metric.dart';
import 'package:health_app/features/health_tracking/domain/usecases/update_health_metric.dart';
import 'package:health_app/features/health_tracking/presentation/providers/health_metrics_provider.dart';
import 'package:health_app/features/health_tracking/presentation/providers/moving_average_provider.dart';
import 'package:health_app/features/health_tracking/presentation/providers/weight_trend_provider.dart';
import 'package:health_app/features/health_tracking/domain/usecases/get_weight_trend.dart';
import 'package:health_app/features/health_tracking/presentation/providers/health_tracking_repository_provider.dart';
import 'package:health_app/features/user_profile/presentation/providers/user_profile_repository_provider.dart';
import 'package:health_app/features/user_profile/domain/entities/user_profile.dart';
import 'package:health_app/features/user_profile/domain/entities/gender.dart';
import 'package:health_app/core/providers/user_preferences_provider.dart';
import 'package:health_app/core/utils/unit_converter.dart';
import 'package:health_app/core/utils/format_utils.dart';

/// Weight entry page for logging daily weight
/// 
/// Supports both creating new entries and editing existing ones.
/// When [metricId] is provided, the page opens in edit mode.
class WeightEntryPage extends ConsumerStatefulWidget {
  /// Optional metric ID for edit mode
  final String? metricId;

  const WeightEntryPage({super.key, this.metricId});

  @override
  ConsumerState<WeightEntryPage> createState() => _WeightEntryPageState();
}

class _WeightEntryPageState extends ConsumerState<WeightEntryPage> {
  final TextEditingController _weightController = TextEditingController();
  final FocusNode _weightFocusNode = FocusNode();
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
    _weightController.dispose();
    _weightFocusNode.dispose();
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
            // Convert weight from metric to user's preferred units for display
            final useImperial = ref.read(unitPreferenceProvider);
            final displayWeight = metric.weight != null
                ? (useImperial
                    ? UnitConverter.convertWeightMetricToImperial(metric.weight!)
                    : metric.weight!)
                : null;
            
            setState(() {
              _existingMetric = metric;
              _selectedDate = metric.date;
              if (displayWeight != null) {
                _weightController.text = displayWeight.toStringAsFixed(1);
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
        _errorMessage = null;
        _successMessage = null;
      });
    }
  }

  Future<void> _saveWeight() async {
    final weightText = _weightController.text.trim();
    if (weightText.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a weight';
      });
      return;
    }

    final weight = double.tryParse(weightText);
    if (weight == null) {
      setState(() {
        _errorMessage = 'Please enter a valid number';
      });
      return;
    }

    // Convert weight from user's preferred units to metric for storage
    final useImperial = ref.read(unitPreferenceProvider);
    final weightInMetric = useImperial
        ? UnitConverter.convertWeightImperialToMetric(weight)
        : weight;

    // Validate weight range based on selected units
    final minWeight = UnitConverter.getMinWeight(useImperial);
    final maxWeight = UnitConverter.getMaxWeight(useImperial);
    if (weight < minWeight || weight > maxWeight) {
      final unitLabel = UnitConverter.getWeightUnitLabel(useImperial);
      setState(() {
        _errorMessage = 'Weight must be between $minWeight and $maxWeight $unitLabel';
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
      userId = await ref.read(currentUserIdProvider.future);
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
          // Invalidate provider to refresh
          ref.invalidate(currentUserIdProvider);
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
        weight: weightInMetric,
        date: _selectedDate,
        updatedAt: DateTime.now(),
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
            _successMessage = 'Weight updated successfully!';
          });
          // Invalidate providers to refresh data
          ref.invalidate(healthMetricsProvider);
          ref.invalidate(movingAverageProvider);
          ref.invalidate(weightTrendProvider);
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
        weight: weightInMetric,
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
            _successMessage = 'Weight saved successfully!';
            _weightController.clear();
          });
          // Invalidate providers to refresh data
          ref.invalidate(healthMetricsProvider);
          ref.invalidate(movingAverageProvider);
          ref.invalidate(weightTrendProvider);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final movingAverage = ref.watch(movingAverageProvider);
    final weightTrend = ref.watch(weightTrendProvider);
    final useImperial = ref.watch(unitPreferenceProvider);
    final unitLabel = UnitConverter.getWeightUnitLabel(useImperial);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Weight' : 'Weight Entry'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(UIConstants.screenPaddingHorizontal),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Weight input card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.cardPadding),
                child: Column(
                  children: [
                    Text(
                      _isEditMode ? 'Edit Weight' : 'Today\'s Weight',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingLg),
                    // Large numeric input
                    TextField(
                      controller: _weightController,
                      focusNode: _weightFocusNode,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: '0.0',
                        suffixText: unitLabel,
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(UIConstants.borderRadiusMd),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(UIConstants.borderRadiusMd),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(UIConstants.borderRadiusMd),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _errorMessage = null;
                          _successMessage = null;
                        });
                      },
                    ),
                    const SizedBox(height: UIConstants.spacingMd),
                    // Date picker button
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

            // 7-day moving average card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '7-Day Moving Average',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingSm),
                    if (movingAverage != null) ...[
                      Text(
                        'Average: ${FormatUtils.formatWeightValue(movingAverage, useImperial)}',
                        style: theme.textTheme.titleLarge,
                      ),
                      if (weightTrend != null) ...[
                        const SizedBox(height: UIConstants.spacingXs),
                        Row(
                          children: [
                            Icon(
                              weightTrend.trend == WeightTrend.decreasing
                                  ? Icons.arrow_downward
                                  : weightTrend.trend == WeightTrend.increasing
                                      ? Icons.arrow_upward
                                      : Icons.arrow_forward,
                              color: weightTrend.trend == WeightTrend.decreasing
                                  ? Colors.green
                                  : weightTrend.trend == WeightTrend.increasing
                                      ? Colors.red
                                      : Colors.grey,
                            ),
                            const SizedBox(width: UIConstants.spacingXs),
                            Text(
                              // Format change value with proper units
                              weightTrend.change > 0
                                  ? 'Weight is increasing by ${FormatUtils.formatWeightChange(weightTrend.change, useImperial)}'
                                  : weightTrend.change < 0
                                      ? 'Weight is decreasing by ${FormatUtils.formatWeightChange(weightTrend.change.abs(), useImperial)}'
                                      : 'Weight is stable (change: ${FormatUtils.formatWeightChange(weightTrend.change.abs(), useImperial)})',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ] else ...[
                      Text(
                        'Insufficient data: Need at least 7 days of weight entries',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
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
              label: _isSaving
                  ? (_isEditMode ? 'Updating...' : 'Saving...')
                  : (_isEditMode ? 'Update Weight' : 'Save Weight'),
              onPressed: _isSaving ? null : _saveWeight,
              isLoading: _isSaving,
              width: double.infinity,
            ),
          ],
        ),
        ),
      ),
    );
  }
}

