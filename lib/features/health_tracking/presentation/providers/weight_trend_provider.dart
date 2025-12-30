import 'package:riverpod/riverpod.dart';
import 'package:health_app/features/health_tracking/domain/usecases/get_weight_trend.dart';
import 'package:health_app/features/health_tracking/presentation/providers/health_metrics_provider.dart';

/// Provider for weight trend analysis
/// 
/// Calculates weight trend by comparing current 7-day moving average
/// to previous 7-day moving average using GetWeightTrendUseCase.
/// Returns null if insufficient data or error occurs.
final weightTrendProvider = Provider<WeightTrendResult?>((ref) {
  final metricsAsync = ref.watch(healthMetricsProvider);
  
  return metricsAsync.when(
    data: (metrics) {
      if (metrics.isEmpty) {
        return null;
      }
      
      final useCase = GetWeightTrendUseCase();
      final result = useCase(metrics);
      
      return result.fold(
        (failure) => null,
        (trendResult) => trendResult,
      );
    },
    loading: () => null,
    error: (error, stack) => null,
  );
});

