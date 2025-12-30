import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/widgets/custom_button.dart';
import 'package:health_app/core/widgets/error_widget.dart' as core_error;
import 'package:health_app/core/widgets/loading_indicator.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';
import 'package:health_app/features/health_tracking/domain/usecases/save_health_metric.dart';
import 'package:health_app/features/health_tracking/presentation/providers/health_metrics_provider.dart';
import 'package:health_app/features/health_tracking/presentation/providers/moving_average_provider.dart';
import 'package:health_app/features/health_tracking/presentation/providers/weight_trend_provider.dart';
import 'package:health_app/features/health_tracking/domain/usecases/get_weight_trend.dart';
import 'package:health_app/features/health_tracking/presentation/providers/health_tracking_repository_provider.dart';
import 'package:health_app/features/user_profile/presentation/providers/user_profile_repository_provider.dart';
import 'package:health_app/features/user_profile/domain/entities/user_profile.dart';
import 'package:health_app/features/user_profile/domain/entities/gender.dart';

/// Weight entry page for logging daily weight
class WeightEntryPage extends ConsumerStatefulWidget {
  const WeightEntryPage({super.key});

  @override
  ConsumerState<WeightEntryPage> createState() => _WeightEntryPageState();
}

class _WeightEntryPageState extends ConsumerState<WeightEntryPage> {
  final TextEditingController _weightController = TextEditingController();
  final FocusNode _weightFocusNode = FocusNode();
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _weightController.dispose();
    _weightFocusNode.dispose();
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
    final useCase = SaveHealthMetricUseCase(repository);

    final metric = HealthMetric(
      id: '',
      userId: finalUserId,
      date: _selectedDate,
      weight: weight,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metricsAsync = ref.watch(healthMetricsProvider);
    final movingAverage = ref.watch(movingAverageProvider);
    final weightTrend = ref.watch(weightTrendProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weight Entry'),
      ),
      body: SingleChildScrollView(
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
                    const Text(
                      'Today\'s Weight',
                      style: TextStyle(
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
                        suffixText: 'kg',
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
                        'Average: ${movingAverage.toStringAsFixed(1)} kg',
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
                              weightTrend.message,
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

            // Recent weights list
            Card(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Weights',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingSm),
                    metricsAsync.when(
                      data: (metrics) {
                        final weightMetrics = metrics
                            .where((m) => m.weight != null)
                            .toList()
                          ..sort((a, b) => b.date.compareTo(a.date));
                        final recent = weightMetrics.take(5).toList();

                        if (recent.isEmpty) {
                          return Text(
                            'No weight entries yet',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          );
                        }

                        return Column(
                          children: recent.map((metric) {
                            return ListTile(
                              title: Text('${metric.weight!.toStringAsFixed(1)} kg'),
                              subtitle: Text(DateFormat('MMMM d, yyyy').format(metric.date)),
                              leading: const Icon(Icons.scale),
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const LoadingIndicator(),
                      error: (error, stack) => core_error.ErrorWidget(
                        message: 'Failed to load recent weights',
                      ),
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
              label: 'Save Weight',
              onPressed: _isSaving ? null : _saveWeight,
              isLoading: _isSaving,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}

