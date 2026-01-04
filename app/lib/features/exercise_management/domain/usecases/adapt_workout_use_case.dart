import 'package:fpdart/fpdart.dart';
import '../../../../core/llm/llm_provider.dart';
import '../../../../core/llm/llm_service.dart';
import '../../../../core/llm/prompts/prompt_selector.dart';
import '../../../../core/errors/failures.dart';
import '../../../user_profile/domain/entities/user_profile.dart';
import '../../../user_profile/domain/repositories/user_profile_repository.dart';
import '../entities/exercise.dart';
import '../repositories/exercise_repository.dart';

/// Use case to adapt workouts based on user feedback
class AdaptWorkoutUseCase {
  final ExerciseRepository _exerciseRepository;
  final UserProfileRepository _userProfileRepository;
  final LlmService _llmService;
  final PromptSelector _promptSelector;

  AdaptWorkoutUseCase({
    required ExerciseRepository exerciseRepository,
    required UserProfileRepository userProfileRepository,
    required LlmService llmService,
    PromptSelector? promptSelector,
  })  : _exerciseRepository = exerciseRepository,
        _userProfileRepository = userProfileRepository,
        _llmService = llmService,
        _promptSelector = promptSelector ?? const PromptSelector();

  /// Executes the use case
  Future<Either<Failure, String>> execute({
    required String userId,
    required Exercise currentExercise,
    required String feedback,
  }) async {
    // 1. Fetch user profile for context
    final profileResult = await _userProfileRepository.getUserProfile(userId);

    return profileResult.fold(
      (failure) => Left(failure),
      (profile) async {
        // 2. Fetch exercise library for possible substitutions
        final libraryResult =
            await _exerciseRepository.getExercisesByUserId(userId);
        final library = libraryResult.getOrElse((l) => []);
        // Filter out actual logs, keep only templates (date == null)
        final templates = library.where((e) => e.date == null).toList();

        // 3. Build prompt and call LLM
        final prompt =
            _buildPrompt(currentExercise, feedback, profile, templates);
        final systemPrompt = _buildSystemPrompt();

        final llmResult = await _llmService.generateCompletionWithFallback(
          LlmRequest(
            prompt: prompt,
            systemPrompt: systemPrompt,
            temperature: 0.7,
          ),
        );

        return llmResult.fold(
          (failure) => Left(failure),
          (response) => Right(response.content),
        );
      },
    );
  }

  String _buildSystemPrompt() {
    return '''
You are a highly experienced personal trainer and physical therapist assistant.
Your goal is to help users modify their workouts to safely achieve their goals while respecting their physical limitations, pain, or equipment constraints.
Always prioritize safety. If a user reports sharp pain, advise them to stop and consult a professional.
''';
  }

  String _buildPrompt(
    Exercise exercise,
    String feedback,
    UserProfile profile,
    List<Exercise> templates,
  ) {
    final templateHints = templates
        .take(10)
        .map((e) => '- ${e.name} (${e.type.name})')
        .join('\n');

    // Get the appropriate prompt template based on the active LLM provider
    final template = _promptSelector
        .selectWorkoutAdaptationPrompt(_llmService.config.providerType);

    // Replace placeholders in the template
    return template
        .replaceAll('{exerciseName}', exercise.name)
        .replaceAll('{exerciseType}', exercise.type.name)
        .replaceAll('{sets}', exercise.sets?.toString() ?? 'N/A')
        .replaceAll('{reps}', exercise.reps?.toString() ?? 'N/A')
        .replaceAll('{weight}', exercise.weight?.toString() ?? 'N/A')
        .replaceAll('{muscleGroups}', exercise.muscleGroups.join(', '))
        .replaceAll('{feedback}', feedback)
        .replaceAll('{name}', profile.name)
        .replaceAll('{goals}', profile.fitnessGoals.join(', '))
        .replaceAll('{healthConditions}', profile.healthConditions.join(', '))
        .replaceAll('{exercises}', templateHints);
  }
}
