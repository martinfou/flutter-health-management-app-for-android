import 'package:fpdart/fpdart.dart';
import '../../../../core/llm/llm_provider.dart';
import '../../../../core/llm/llm_service.dart';
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

  AdaptWorkoutUseCase({
    required ExerciseRepository exerciseRepository,
    required UserProfileRepository userProfileRepository,
    required LlmService llmService,
  })  : _exerciseRepository = exerciseRepository,
        _userProfileRepository = userProfileRepository,
        _llmService = llmService;

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
        final libraryResult = await _exerciseRepository.getExercisesByUserId(userId);
        final library = libraryResult.getOrElse((l) => []);
        // Filter out actual logs, keep only templates (date == null)
        final templates = library.where((e) => e.date == null).toList();

        // 3. Build prompt and call LLM
        final prompt = _buildPrompt(currentExercise, feedback, profile, templates);
        final systemPrompt = _buildSystemPrompt();

        final llmResult = await _llmService.generateCompletion(
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
    final templateHints = templates.take(10).map((e) => '- ${e.name} (${e.type.name})').join('\n');

    return '''
I need help modifying an exercise in my workout.

Current Exercise:
- Name: ${exercise.name}
- Type: ${exercise.type.name}
- Current Setup: ${exercise.sets ?? 'N/A'} sets of ${exercise.reps ?? 'N/A'} reps @ ${exercise.weight ?? 'N/A'}kg
- Target Muscles: ${exercise.muscleGroups.join(', ')}

My Feedback:
"$feedback"

User Context:
- Name: ${profile.name}
- Goals: ${profile.fitnessGoals.join(', ')}
- Physical Limitations/Health Notes: ${profile.healthConditions.join(', ')}

Available Exercises in my Library:
$templateHints

Please provide:
1. An explanation of why the current exercise might be challenging or causing issues based on my feedback.
2. 2-3 specific modifications or alternative exercises.
3. For each modification, explain how to perform it safely and what to focus on.
4. Adjusted sets/reps/weight if applicable.

Keep the response supportive, safe, and formatted in markdown.
''';
  }
}
