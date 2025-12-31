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

/// Blood pressure entry page
/// 
/// Supports both creating new entries and editing existing ones.
/// When [metricId] is provided, the page opens in edit mode.
class BloodPressureEntryPage extends ConsumerStatefulWidget {
  /// Optional metric ID for edit mode
  final String? metricId;

  const BloodPressureEntryPage({super.key, this.metricId});

  @override
  ConsumerState<BloodPressureEntryPage> createState() => _BloodPressureEntryPageState();
}

class _BloodPressureEntryPageState extends ConsumerState<BloodPressureEntryPage> {
  final TextEditingController _systolicController = TextEditingController();
  final TextEditingController _diastolicController = TextEditingController();
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
    _systolicController.dispose();
    _diastolicController.dispose();
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
              _systolicController.text = metric.systolicBP?.toString() ?? '';
              _diastolicController.text = metric.diastolicBP?.toString() ?? '';
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

  String _getBPInterpretation(int systolic, int diastolic) {
    if (systolic < 120 && diastolic < 80) {
      return 'Normal';
    } else if (systolic >= 120 && systolic <= 129 && diastolic < 80) {
      return 'Elevated';
    } else if ((systolic >= 130 && systolic <= 139) || (diastolic >= 80 && diastolic <= 89)) {
      return 'High Stage 1';
    } else {
      return 'High Stage 2';
    }
  }

  Color _getBPInterpretationColor(int systolic, int diastolic) {
    if (systolic < 120 && diastolic < 80) {
      return Colors.green;
    } else if (systolic >= 120 && systolic <= 129 && diastolic < 80) {
      return Colors.orange;
    } else if ((systolic >= 130 && systolic <= 139) || (diastolic >= 80 && diastolic <= 89)) {
      return Colors.red.shade300;
    } else {
      return Colors.red;
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

    // Parse blood pressure values
    int? systolicBP;
    int? diastolicBP;
    
    if (_systolicController.text.trim().isEmpty) {
      setState(() {
        _isSaving = false;
        _errorMessage = 'Please enter systolic blood pressure';
      });
      return;
    }
    
    if (_diastolicController.text.trim().isEmpty) {
      setState(() {
        _isSaving = false;
        _errorMessage = 'Please enter diastolic blood pressure';
      });
      return;
    }

    final systolicValue = int.tryParse(_systolicController.text.trim());
    final diastolicValue = int.tryParse(_diastolicController.text.trim());

    if (systolicValue == null || systolicValue < 70 || systolicValue > 250) {
      setState(() {
        _isSaving = false;
        _errorMessage = 'Systolic blood pressure must be between 70 and 250 mmHg';
      });
      return;
    }

    if (diastolicValue == null || diastolicValue < 40 || diastolicValue > 150) {
      setState(() {
        _isSaving = false;
        _errorMessage = 'Diastolic blood pressure must be between 40 and 150 mmHg';
      });
      return;
    }

    if (systolicValue <= diastolicValue) {
      setState(() {
        _isSaving = false;
        _errorMessage = 'Systolic blood pressure must be greater than diastolic blood pressure';
      });
      return;
    }

    systolicBP = systolicValue;
    diastolicBP = diastolicValue;

    final repository = ref.read(healthTrackingRepositoryProvider);

    if (_isEditMode && _existingMetric != null) {
      // Update existing metric
      final useCase = UpdateHealthMetricUseCase(repository);
      
      final updatedMetric = _existingMetric!.copyWith(
        systolicBP: systolicBP,
        diastolicBP: diastolicBP,
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
            _successMessage = 'Blood pressure updated successfully!';
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
        systolicBP: systolicBP,
        diastolicBP: diastolicBP,
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
            _successMessage = 'Blood pressure saved successfully!';
            // Clear fields for next entry
            _systolicController.clear();
            _diastolicController.clear();
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
    final systolicValue = int.tryParse(_systolicController.text.trim());
    final diastolicValue = int.tryParse(_diastolicController.text.trim());
    final hasValidBP = systolicValue != null && 
                       diastolicValue != null && 
                       systolicValue > diastolicValue;
    final bpInterpretation = hasValidBP 
        ? _getBPInterpretation(systolicValue, diastolicValue)
        : null;
    final bpColor = hasValidBP 
        ? _getBPInterpretationColor(systolicValue, diastolicValue)
        : null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Blood Pressure' : 'Log Blood Pressure'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(UIConstants.screenPaddingHorizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Systolic Input Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(UIConstants.cardPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Systolic (Top Number)',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: UIConstants.spacingMd),
                          TextField(
                            controller: _systolicController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Systolic',
                              hintText: 'Enter systolic pressure',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(UIConstants.borderRadiusMd),
                              ),
                              suffixText: 'mmHg',
                            ),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: UIConstants.spacingMd),

                  // Diastolic Input Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(UIConstants.cardPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Diastolic (Bottom Number)',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: UIConstants.spacingMd),
                          TextField(
                            controller: _diastolicController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Diastolic',
                              hintText: 'Enter diastolic pressure',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(UIConstants.borderRadiusMd),
                              ),
                              suffixText: 'mmHg',
                            ),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: UIConstants.spacingMd),

                  // Interpretation Card
                  if (hasValidBP && bpInterpretation != null && bpColor != null)
                    Card(
                      color: bpColor.withValues(alpha: 0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(UIConstants.cardPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Interpretation',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: UIConstants.spacingSm),
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: bpColor,
                                ),
                                const SizedBox(width: UIConstants.spacingSm),
                                Text(
                                  '$bpInterpretation: ${systolicValue}/${diastolicValue} mmHg',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: bpColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: UIConstants.spacingXs),
                            Text(
                              'Normal: <120/<80 mmHg',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                              hintText: 'Add any notes about your blood pressure...',
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
                        : (_isEditMode ? 'Update Blood Pressure' : 'Save Blood Pressure'),
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

