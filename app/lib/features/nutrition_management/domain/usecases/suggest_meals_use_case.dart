import 'package:fpdart/fpdart.dart';
import '../../../../core/llm/llm_provider.dart';
import '../../../../core/llm/llm_service.dart';
import '../../../../core/llm/prompts/prompt_selector.dart';
import '../../../../core/errors/failures.dart';
import '../../../user_profile/domain/entities/user_profile.dart';
import '../../../user_profile/domain/repositories/user_profile_repository.dart';
import '../entities/recipe.dart';
import '../repositories/nutrition_repository.dart';
import 'calculate_macros.dart';

/// Use case to suggest meals based on remaining macros and preferences
class SuggestMealsUseCase {
  final NutritionRepository _nutritionRepository;
  final UserProfileRepository _userProfileRepository;
  final CalculateMacrosUseCase _calculateMacrosUseCase;
  final LlmService _llmService;
  final PromptSelector _promptSelector;

  SuggestMealsUseCase({
    required NutritionRepository nutritionRepository,
    required UserProfileRepository userProfileRepository,
    required CalculateMacrosUseCase calculateMacrosUseCase,
    required LlmService llmService,
    PromptSelector? promptSelector,
  })  : _nutritionRepository = nutritionRepository,
        _userProfileRepository = userProfileRepository,
        _calculateMacrosUseCase = calculateMacrosUseCase,
        _llmService = llmService,
        _promptSelector = promptSelector ?? const PromptSelector();

  /// Executes the use case
  Future<Either<Failure, String>> execute({
    required String userId,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 1. Fetch today's meals
    final mealsResult =
        await _nutritionRepository.getMealsByDate(userId, today);

    return mealsResult.fold(
      (failure) => Left(failure),
      (meals) async {
        // Calculate macros (handle empty case)
        MacroSummary currentMacros;
        if (meals.isEmpty) {
          currentMacros = MacroSummary(
            protein: 0,
            fats: 0,
            netCarbs: 0,
            calories: 0,
            proteinPercent: 0,
            fatsPercent: 0,
            carbsPercent: 0,
          );
        } else {
          final macroResult = _calculateMacrosUseCase.call(meals);
          if (macroResult.isLeft()) {
            return Left(macroResult
                .getLeft()
                .getOrElse(() => DatabaseFailure('Macro calculation failed')));
          }
          currentMacros = macroResult
              .getOrElse((l) => throw Exception('Should not happen'));
        }

        // 2. Fetch user profile for context and targets
        final profileResult =
            await _userProfileRepository.getUserProfile(userId);

        return profileResult.fold(
          (failure) => Left(failure),
          (profile) async {
            // 3. Fetch some recipes for context
            final recipesResult = await _nutritionRepository.getAllRecipes();
            final recipes = recipesResult.getOrElse((l) => []);

            // 4. Build prompt and call LLM
            final prompt = _buildPrompt(currentMacros, profile, recipes);
            final systemPrompt = _buildSystemPrompt();

            final llmResult = await _llmService.generateCompletionWithFallback(
              LlmRequest(
                prompt: prompt,
                systemPrompt: systemPrompt,
                temperature: 0.8,
              ),
            );

            return llmResult.fold(
              (failure) => Left(failure),
              (response) => Right(response.content),
            );
          },
        );
      },
    );
  }

  String _buildSystemPrompt() {
    return '''
You are a creative culinary expert and nutrition coach specializing in low-carb, high-protein, and gourmet meal planning.
Your goal is to suggest ORIGINAL, creative meals and snacks that help users stay within their macro targets (35% Protein, 55% Fats, <40g Net Carbs).

IMPORTANT:
- Create NEW, original recipe ideas - do NOT limit yourself to existing recipes
- Suggest creative combinations of ingredients
- Include both full meals AND snacks
- Be innovative and think outside the box
- Provide unique, personalized suggestions based on the user's preferences and remaining macros
''';
  }

  String _buildPrompt(
    MacroSummary current,
    UserProfile profile,
    List<Recipe> recipes,
  ) {
    // Select a few relevant recipes to show the LLM
    final recipeHints = recipes.take(5).map((r) {
      return '- ${r.name} (${r.protein}g P, ${r.fats}g F, ${r.netCarbs}g NC)';
    }).join('\n');

    final recipeContext = recipes.isNotEmpty
        ? '''
Some recipe examples from my library (for inspiration only - feel free to create something new):
$recipeHints
'''
        : '';

    // Get the appropriate prompt template based on the active LLM provider
    final template = _promptSelector
        .selectFoodSuggestionPrompt(_llmService.config.providerType);

    // Calculate remaining carbs
    final remainingCarbs = (40 - current.netCarbs).toStringAsFixed(1);

    // Replace placeholders in the template
    return template
        .replaceAll('{protein}', current.protein.toString())
        .replaceAll('{fats}', current.fats.toString())
        .replaceAll('{netCarbs}', current.netCarbs.toString())
        .replaceAll('{calories}', current.calories.toString())
        .replaceAll('{remainingCarbs}', remainingCarbs)
        .replaceAll('{name}', profile.name)
        .replaceAll('{dietaryApproach}', profile.dietaryApproach)
        .replaceAll('{dislikes}',
            profile.dislikes.isEmpty ? 'None' : profile.dislikes.join(', '))
        .replaceAll('{allergies}',
            profile.allergies.isEmpty ? 'None' : profile.allergies.join(', '))
        .replaceAll('{recipeContext}', recipeContext);
  }
}
