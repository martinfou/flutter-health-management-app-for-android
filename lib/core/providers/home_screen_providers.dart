// Dart SDK
import 'package:riverpod/riverpod.dart';

// Project
import 'package:health_app/core/entities/recommended_action.dart';
import 'package:health_app/core/usecases/get_recommended_actions.dart';
import 'package:health_app/core/usecases/calculate_daily_progress.dart';
import 'package:health_app/features/health_tracking/presentation/providers/health_metrics_provider.dart';
import 'package:health_app/features/nutrition_management/presentation/providers/nutrition_providers.dart';
import 'package:health_app/features/nutrition_management/domain/usecases/calculate_macros.dart';
import 'package:health_app/features/medication_management/presentation/providers/medication_repository_provider.dart';
import 'package:health_app/features/user_profile/presentation/providers/user_profile_repository_provider.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';
import 'package:health_app/features/medication_management/domain/entities/medication.dart';
import 'package:health_app/features/medication_management/domain/entities/medication_log.dart';

/// Provider for GetRecommendedActions use case
final getRecommendedActionsUseCaseProvider =
    Provider<GetRecommendedActions>((ref) {
  return GetRecommendedActions();
});

/// Provider for CalculateDailyProgress use case
final calculateDailyProgressUseCaseProvider =
    Provider<CalculateDailyProgress>((ref) {
  return CalculateDailyProgress();
});

/// Provider for GetDailyMetricStatus use case
final getDailyMetricStatusUseCaseProvider =
    Provider<GetDailyMetricStatus>((ref) {
  return GetDailyMetricStatus();
});

/// Provider for getting recommended actions for home screen
/// 
/// Returns list of recommended actions based on:
/// - Time of day
/// - Medication schedules
/// - Missing critical metrics
final whatNextProvider = FutureProvider<List<RecommendedAction>>((ref) async {
  try {
    // Get current user
    final userProfileRepo = ref.watch(userProfileRepositoryProvider);
    final userResult = await userProfileRepo.getCurrentUserProfile();

    return userResult.fold(
      (failure) => <RecommendedAction>[],
      (userProfile) async {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        // Get today's metrics
        final healthMetricsAsync = ref.watch(healthMetricsProvider);
        final todayMetrics = healthMetricsAsync.when(
          data: (allMetrics) {
            return allMetrics.where((m) {
              final metricDate = DateTime(m.date.year, m.date.month, m.date.day);
              return metricDate == today;
            }).toList();
          },
          loading: () => <HealthMetric>[],
          error: (_, __) => <HealthMetric>[],
        );

        // Get active medications
        final medicationRepo = ref.watch(medicationRepositoryProvider);
        final medicationsResult = await medicationRepo.getActiveMedications(userProfile.id);
        final activeMedications = medicationsResult.fold(
          (failure) => <Medication>[],
          (medications) => medications,
        );

        // Get today's medication logs
        final todayLogs = <MedicationLog>[];
        for (final medication in activeMedications) {
          final logsResult = await medicationRepo.getMedicationLogsByDateRange(
            medication.id,
            today,
            today.add(const Duration(days: 1)),
          );
          logsResult.fold(
            (failure) => null,
            (logs) => todayLogs.addAll(logs),
          );
        }

        // Get recommendations
        final useCase = ref.watch(getRecommendedActionsUseCaseProvider);
        return useCase.call(
          todayMetrics: todayMetrics,
          activeMedications: activeMedications,
          todayMedicationLogs: todayLogs,
          now: now,
        );
      },
    );
  } catch (e) {
    return <RecommendedAction>[];
  }
});

/// Provider for calculating daily progress percentage
/// 
/// Returns progress value between 0.0 and 1.0 (0.0 = 0%, 1.0 = 100%).
final dailyProgressProvider = FutureProvider<double>((ref) async {
  try {
    // Get current user
    final userProfileRepo = ref.watch(userProfileRepositoryProvider);
    final userResult = await userProfileRepo.getCurrentUserProfile();

    return userResult.fold(
      (failure) => 0.0,
      (userProfile) async {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        // Get today's metrics
        final healthMetricsAsync = ref.watch(healthMetricsProvider);
        final todayMetrics = healthMetricsAsync.when(
          data: (allMetrics) {
            return allMetrics.where((m) {
              final metricDate = DateTime(m.date.year, m.date.month, m.date.day);
              return metricDate == today;
            }).toList();
          },
          loading: () => <HealthMetric>[],
          error: (_, __) => <HealthMetric>[],
        );

        // Get macro completion percentage
        final macroSummary = ref.watch(macroSummaryProvider(today));
        final macroCompletion = _calculateMacroCompletion(macroSummary);

        // Get medication adherence percentage
        final medicationRepo = ref.watch(medicationRepositoryProvider);
        final medicationsResult = await medicationRepo.getActiveMedications(userProfile.id);
        final medicationAdherence = await medicationsResult.fold(
          (failure) async => 0.0,
          (medications) async {
            if (medications.isEmpty) return 100.0; // No medications = 100% adherence

            int totalDoses = 0;
            int loggedDoses = 0;

            final todayEnd = today.add(const Duration(days: 1));
            for (final medication in medications) {
              // Count scheduled doses for today
              totalDoses += medication.times.length;

              // Count logged doses for today
              final logsResult = await medicationRepo.getMedicationLogsByDateRange(
                medication.id,
                today,
                todayEnd,
              );
              logsResult.fold(
                (failure) => null,
                (logs) => loggedDoses += logs.length,
              );
            }

            if (totalDoses == 0) return 100.0;
            return (loggedDoses / totalDoses * 100).clamp(0.0, 100.0);
          },
        );

        // Calculate progress
        final useCase = ref.watch(calculateDailyProgressUseCaseProvider);
        return useCase.call(
          todayMetrics: todayMetrics,
          macroCompletionPercentage: macroCompletion,
          medicationAdherencePercentage: medicationAdherence,
        );
      },
    );
  } catch (e) {
    return 0.0;
  }
});

/// Provider for getting daily metric status
final metricStatusProvider = FutureProvider<DailyMetricStatus>((ref) async {
  try {
    // Get current user
    final userProfileRepo = ref.watch(userProfileRepositoryProvider);
    final userResult = await userProfileRepo.getCurrentUserProfile();

    return userResult.fold(
      (failure) => DailyMetricStatus(
        weight: MetricStatus.notLogged,
        sleep: MetricStatus.notLogged,
        energy: MetricStatus.notLogged,
        heartRate: MetricStatus.notLogged,
        macros: MetricStatus.notLogged,
        medication: MetricStatus.notLogged,
      ),
      (userProfile) async {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        // Get today's metrics
        final healthMetricsAsync = ref.watch(healthMetricsProvider);
        final todayMetrics = healthMetricsAsync.when(
          data: (allMetrics) {
            return allMetrics.where((m) {
              final metricDate = DateTime(m.date.year, m.date.month, m.date.day);
              return metricDate == today;
            }).toList();
          },
          loading: () => <HealthMetric>[],
          error: (_, __) => <HealthMetric>[],
        );

        // Get macro completion percentage
        final macroSummary = ref.watch(macroSummaryProvider(today));
        final macroCompletion = _calculateMacroCompletion(macroSummary);

        // Get medication adherence percentage
        final medicationRepo = ref.watch(medicationRepositoryProvider);
        final medicationsResult = await medicationRepo.getActiveMedications(userProfile.id);
        final medicationAdherence = await medicationsResult.fold(
          (failure) async => 0.0,
          (medications) async {
            if (medications.isEmpty) return 100.0;

            int totalDoses = 0;
            int loggedDoses = 0;

            final todayEnd = today.add(const Duration(days: 1));
            for (final medication in medications) {
              totalDoses += medication.times.length;

              final logsResult = await medicationRepo.getMedicationLogsByDateRange(
                medication.id,
                today,
                todayEnd,
              );
              logsResult.fold(
                (failure) => null,
                (logs) => loggedDoses += logs.length,
              );
            }

            if (totalDoses == 0) return 100.0;
            return (loggedDoses / totalDoses * 100).clamp(0.0, 100.0);
          },
        );

        // Get status
        final useCase = ref.watch(getDailyMetricStatusUseCaseProvider);
        return useCase.call(
          todayMetrics: todayMetrics,
          macroCompletionPercentage: macroCompletion,
          medicationAdherencePercentage: medicationAdherence,
        );
      },
    );
  } catch (e) {
    return DailyMetricStatus(
      weight: MetricStatus.notLogged,
      sleep: MetricStatus.notLogged,
      energy: MetricStatus.notLogged,
      heartRate: MetricStatus.notLogged,
      macros: MetricStatus.notLogged,
      medication: MetricStatus.notLogged,
    );
  }
});

/// Calculate macro completion percentage
/// 
/// Based on whether user meets targets:
/// - Protein >= 35%: 33.3% contribution
/// - Fats >= 55%: 33.3% contribution
/// - Net carbs <= 40g: 33.3% contribution
double _calculateMacroCompletion(MacroSummary macroSummary) {
  double completion = 0.0;

  // Protein target: >= 35%
  if (macroSummary.proteinPercent >= 35.0) {
    completion += 33.3;
  } else {
    completion += (macroSummary.proteinPercent / 35.0) * 33.3;
  }

  // Fats target: >= 55%
  if (macroSummary.fatsPercent >= 55.0) {
    completion += 33.3;
  } else {
    completion += (macroSummary.fatsPercent / 55.0) * 33.3;
  }

  // Net carbs target: <= 40g
  if (macroSummary.netCarbs <= 40.0) {
    completion += 33.3;
  } else {
    // Over limit, reduce completion
    completion += (40.0 / macroSummary.netCarbs) * 33.3;
  }

  return completion.clamp(0.0, 100.0);
}

