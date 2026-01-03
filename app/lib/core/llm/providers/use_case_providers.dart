import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'llm_providers.dart';
import '../../../../features/health_tracking/presentation/providers/health_tracking_repository_provider.dart';
import '../../../../features/user_profile/presentation/providers/user_profile_repository_provider.dart';
import '../../../../features/nutrition_management/presentation/providers/nutrition_repository_provider.dart';
import '../../../../features/exercise_management/presentation/providers/exercise_repository_provider.dart';
import '../../../../features/nutrition_management/domain/usecases/calculate_macros.dart';
import '../../../../features/analytics/domain/usecases/generate_weekly_review_use_case.dart';
import '../../../../features/nutrition_management/domain/usecases/suggest_meals_use_case.dart';
import '../../../../features/exercise_management/domain/usecases/adapt_workout_use_case.dart';

/// Provider for GenerateWeeklyReviewUseCase
final generateWeeklyReviewUseCaseProvider = Provider<GenerateWeeklyReviewUseCase>((ref) {
  final healthRepo = ref.watch(healthTrackingRepositoryProvider);
  final profileRepo = ref.watch(userProfileRepositoryProvider);
  final llmService = ref.watch(llmServiceProvider);
  
  return GenerateWeeklyReviewUseCase(
    healthRepository: healthRepo,
    userProfileRepository: profileRepo,
    llmService: llmService,
  );
});

/// Provider for SuggestMealsUseCase
final suggestMealsUseCaseProvider = Provider<SuggestMealsUseCase>((ref) {
  final nutritionRepo = ref.watch(nutritionRepositoryProvider);
  final profileRepo = ref.watch(userProfileRepositoryProvider);
  final llmService = ref.watch(llmServiceProvider);
  
  return SuggestMealsUseCase(
    nutritionRepository: nutritionRepo,
    userProfileRepository: profileRepo,
    calculateMacrosUseCase: CalculateMacrosUseCase(),
    llmService: llmService,
  );
});

/// Provider for AdaptWorkoutUseCase
final adaptWorkoutUseCaseProvider = Provider<AdaptWorkoutUseCase>((ref) {
  final exerciseRepo = ref.watch(exerciseRepositoryProvider);
  final profileRepo = ref.watch(userProfileRepositoryProvider);
  final llmService = ref.watch(llmServiceProvider);
  
  return AdaptWorkoutUseCase(
    exerciseRepository: exerciseRepo,
    userProfileRepository: profileRepo,
    llmService: llmService,
  );
});
