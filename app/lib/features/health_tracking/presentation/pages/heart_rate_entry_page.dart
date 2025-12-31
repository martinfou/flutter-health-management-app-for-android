import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/widgets/custom_button.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';
import 'package:health_app/features/health_tracking/domain/usecases/save_health_metric.dart';
import 'package:health_app/features/health_tracking/domain/usecases/update_health_metric.dart';
import 'package:health_app/features/health_tracking/presentation/providers/health_metrics_provider.dart' as providers;
import 'package:health_app/features/health_tracking/presentation/providers/health_tracking_repository_provider.dart';
import 'package:health_app/features/user_profile/presentation/providers/user_profile_repository_provider.dart';
import 'package:health_app/features/user_profile/domain/entities/user_profile.dart';
import 'package:health_app/features/user_profile/domain/entities/gender.dart';

/// Heart rate entry page
/// 
/// Supports both creating new entries and editing existing ones.
/// When [metricId] is provided, the page opens in edit mode.
class HeartRateEntryPage extends ConsumerStatefulWidget {
  /// Optional metric ID for edit mode
  final String? metricId;

  const HeartRateEntryPage({super.key, this.metricId});

  @override
  ConsumerState<HeartRateEntryPage> createState() => _HeartRateEntryPageState();
}

class _HeartRateEntryPageState extends ConsumerState<HeartRateEntryPage> {
  final TextEditingController _heartRateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
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
    _heartRateController.dispose();
    _notesController.dispose();
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
            setState(() {
              _existingMetric = metric;
              _heartRateController.text = metric.restingHeartRate?.toString() ?? '';
              _notesController.text = metric.notes ?? '';
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

  Future<int?> _calculateBaseline() async {
    try {
      final metrics = await ref.read(providers.healthMetricsProvider.future);
      final heartRateMetrics = metrics
          .where((m) => m.restingHeartRate != null)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      
      if (heartRateMetrics.length < 7) {
        return null;
      }
      
      final first7Days = heartRateMetrics.take(7).toList();
      final sum = first7Days.fold<int>(
        0,
        (sum, metric) => sum + (metric.restingHeartRate ?? 0),
      );
      return (sum / first7Days.length).round();
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveEntry() async {
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

    // Parse heart rate
    int? restingHeartRate;
    if (_heartRateController.text.trim().isNotEmpty) {
      final heartRateValue = int.tryParse(_heartRateController.text.trim());
      if (heartRateValue != null && heartRateValue >= 40 && heartRateValue <= 200) {
        restingHeartRate = heartRateValue;
      } else {
        setState(() {
          _isSaving = false;
          _errorMessage = 'Heart rate must be between 40 and 200 BPM';
        });
        return;
      }
    } else {
      setState(() {
        _isSaving = false;
        _errorMessage = 'Please enter a heart rate value';
      });
      return;
    }

    final repository = ref.read(healthTrackingRepositoryProvider);

    if (_isEditMode && _existingMetric != null) {
      // Update existing metric
      final useCase = UpdateHealthMetricUseCase(repository);
      
      final updatedMetric = _existingMetric!.copyWith(
        restingHeartRate: restingHeartRate,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
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
            _successMessage = 'Heart rate updated successfully!';
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
        id: '', // ID will be generated by use case
        userId: finalUserId,
        date: DateTime.now(),
        restingHeartRate: restingHeartRate,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
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
            _successMessage = 'Heart rate saved successfully!';
            // Clear fields for next entry
            _heartRateController.clear();
            _notesController.clear();
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Heart Rate' : 'Log Heart Rate'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(UIConstants.screenPaddingHorizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Heart Rate Input Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(UIConstants.cardPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Resting Heart Rate',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: UIConstants.spacingLg),
                          TextField(
                            controller: _heartRateController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'BPM',
                              hintText: 'Enter resting heart rate',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(UIConstants.borderRadiusMd),
                              ),
                              suffixText: 'BPM',
                            ),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: UIConstants.spacingMd),
                          Text(
                            'Normal range: 60-100 BPM',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: UIConstants.spacingMd),

                  // Baseline Information Card (if available)
                  FutureBuilder<int?>(
                    future: _calculateBaseline(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        final baseline = snapshot.data!;
                        final currentHR = int.tryParse(_heartRateController.text.trim());
                        final difference = currentHR != null ? currentHR - baseline : null;
                        
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(UIConstants.cardPadding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Baseline Information',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: UIConstants.spacingSm),
                                Text(
                                  'Your baseline: $baseline BPM',
                                  style: theme.textTheme.bodyLarge,
                                ),
                                const SizedBox(height: UIConstants.spacingXs),
                                Text(
                                  'Calculated from first 7 days',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                                if (difference != null) ...[
                                  const SizedBox(height: UIConstants.spacingSm),
                                  Text(
                                    'Current: ${difference >= 0 ? '+' : ''}$difference BPM from baseline',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: difference.abs() > 20
                                          ? theme.colorScheme.error
                                          : theme.colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  const SizedBox(height: UIConstants.spacingMd),

                  // Notes Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(UIConstants.cardPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notes (Optional)',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: UIConstants.spacingSm),
                          TextField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Add any notes about your heart rate...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(UIConstants.borderRadiusMd),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: UIConstants.spacingLg),

                  // Error/Success Messages
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(UIConstants.spacingMd),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(UIConstants.borderRadiusMd),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),

                  if (_successMessage != null)
                    Container(
                      padding: const EdgeInsets.all(UIConstants.spacingMd),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(UIConstants.borderRadiusMd),
                      ),
                      child: Text(
                        _successMessage!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),

                  const SizedBox(height: UIConstants.spacingMd),

                  // Save Button
                  CustomButton(
                    label: _isSaving
                        ? (_isEditMode ? 'Updating...' : 'Saving...')
                        : (_isEditMode ? 'Update Heart Rate' : 'Save Heart Rate'),
                    onPressed: _isSaving ? null : _saveEntry,
                    icon: Icons.save,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
    );
  }
}

