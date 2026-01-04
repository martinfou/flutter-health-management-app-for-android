import 'package:fpdart/fpdart.dart';
import '../../../../core/llm/llm_provider.dart';
import '../../../../core/llm/llm_service.dart';
import '../../../../core/llm/prompts/prompt_selector.dart';
import '../../../../core/errors/failures.dart';
import '../../../health_tracking/domain/entities/health_metric.dart';
import '../../../health_tracking/domain/repositories/health_tracking_repository.dart';
import '../../../user_profile/domain/entities/user_profile.dart';
import '../../../user_profile/domain/repositories/user_profile_repository.dart';
import '../entities/weekly_review_insight.dart';

/// Use case to generate a weekly health review insight using LLM
class GenerateWeeklyReviewUseCase {
  final HealthTrackingRepository _healthRepository;
  final UserProfileRepository _userProfileRepository;
  final LlmService _llmService;
  final PromptSelector _promptSelector;

  GenerateWeeklyReviewUseCase({
    required HealthTrackingRepository healthRepository,
    required UserProfileRepository userProfileRepository,
    required LlmService llmService,
    PromptSelector? promptSelector,
  })  : _healthRepository = healthRepository,
        _userProfileRepository = userProfileRepository,
        _llmService = llmService,
        _promptSelector = promptSelector ?? const PromptSelector();

  /// Executes the use case for a given user and week
  Future<Either<Failure, WeeklyReviewInsight>> execute({
    required String userId,
    required DateTime endDate,
  }) async {
    final startDate = endDate.subtract(const Duration(days: 6));

    // 1. Fetch health metrics for the week
    final metricsResult = await _healthRepository.getHealthMetricsByDateRange(
      userId,
      startDate,
      endDate,
    );

    return metricsResult.fold(
      (failure) => Left(failure),
      (metrics) async {
        if (metrics.isEmpty) {
          return Left(ValidationFailure(
              'No health data available for the selected week.'));
        }

        // 2. Fetch user profile for context
        final profileResult =
            await _userProfileRepository.getUserProfile(userId);

        return profileResult.fold(
          (failure) => Left(failure),
          (profile) async {
            // 3. Prepare data for LLM
            final prompt = _buildPrompt(metrics, profile, startDate, endDate);
            final systemPrompt = _buildSystemPrompt();

            // 4. Call LLM Service with fallback
            final llmResult = await _llmService.generateCompletionWithFallback(
              LlmRequest(
                prompt: prompt,
                systemPrompt: systemPrompt,
                temperature: 0.7,
              ),
            );

            return llmResult.fold(
              (failure) => Left(failure),
              (response) => Right(WeeklyReviewInsight(
                id: DateTime.now()
                    .millisecondsSinceEpoch
                    .toString(), // Simplified ID
                userId: userId,
                startDate: startDate,
                endDate: endDate,
                content: response.content,
                model: response.model,
                generatedAt: DateTime.now(),
              )),
            );
          },
        );
      },
    );
  }

  String _buildSystemPrompt() {
    return '''
You are an expert health coach and data analyst specializing in weight loss and holistic health.
Your goal is to provide supportive, data-driven, and actionable insights to users based on their weekly health tracking data.
Be encouraging but honest. Focus on trends rather than daily fluctuations.
Use a professional yet warm tone.
''';
  }

  String _buildPrompt(
    List<HealthMetric> metrics,
    UserProfile profile,
    DateTime start,
    DateTime end,
  ) {
    final metricsLog = metrics.map((m) {
      return '- Date: ${m.date.toIso8601String().split('T')[0]}, Weight: ${m.weight ?? 'N/A'}kg, Sleep: ${m.sleepHours ?? 'N/A'}h (Quality: ${m.sleepQuality ?? 'N/A'}/10), Energy: ${m.energyLevel ?? 'N/A'}/10';
    }).join('\n');

    // Get the appropriate prompt template based on the active LLM provider
    final template = _promptSelector
        .selectWeeklyReviewPrompt(_llmService.config.providerType);

    // Replace placeholders in the template
    return template
        .replaceAll('{name}', profile.name)
        .replaceAll('{currentWeight}', profile.weight.toString())
        .replaceAll('{targetWeight}', profile.targetWeight.toString())
        .replaceAll('{goals}', profile.fitnessGoals.join(', '))
        .replaceAll('{metrics}', metricsLog);
  }
}
