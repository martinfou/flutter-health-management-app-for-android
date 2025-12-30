import 'package:riverpod/riverpod.dart';
import 'package:health_app/features/health_tracking/domain/usecases/calculate_moving_average.dart';
import 'package:health_app/features/health_tracking/presentation/providers/health_metrics_provider.dart';

/// Provider for 7-day moving average of weight
/// 
/// Calculates the 7-day moving average of weight using CalculateMovingAverageUseCase.
/// Returns null if insufficient data (less than 7 days) or error occurs.
final movingAverageProvider = Provider<double?>((ref) {
  final metricsAsync = ref.watch(healthMetricsProvider);
  
  return metricsAsync.when(
    data: (metrics) {
      if (metrics.isEmpty) {
        return null;
      }
      
      final useCase = CalculateMovingAverageUseCase();
      final result = useCase(metrics);
      
      return result.fold(
        (failure) => null,
        (average) => average,
      );
    },
    loading: () => null,
    error: (error, stack) => null,
  );
});

