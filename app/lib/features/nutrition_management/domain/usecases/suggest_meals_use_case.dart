import 'package:fpdart/fpdart.dart';
import '../../../../core/llm/llm_provider.dart';
import '../../../../core/llm/llm_service.dart';
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

  SuggestMealsUseCase({
    required NutritionRepository nutritionRepository,
    required UserProfileRepository userProfileRepository,
    required CalculateMacrosUseCase calculateMacrosUseCase,
    required LlmService llmService,
  })  : _nutritionRepository = nutritionRepository,
        _userProfileRepository = userProfileRepository,
        _calculateMacrosUseCase = calculateMacrosUseCase,
        _llmService = llmService;

  /// Executes the use case
  Future<Either<Failure, String>> execute({
    required String userId,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 1. Fetch today's meals
    final mealsResult = await _nutritionRepository.getMealsByDate(userId, today);
    
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
            return Left(macroResult.getLeft().getOrElse(() => DatabaseFailure('Macro calculation failed')));
          }
          currentMacros = macroResult.getOrElse((l) => throw Exception('Should not happen'));
        }

        // 2. Fetch user profile for context and targets
        final profileResult = await _userProfileRepository.getUserProfile(userId);
        
        return profileResult.fold(
          (failure) => Left(failure),
          (profile) async {
            // 3. Fetch some recipes for context
            final recipesResult = await _nutritionRepository.getAllRecipes();
            final recipes = recipesResult.getOrElse((l) => []);

            // 4. Build prompt and call LLM
            final prompt = _buildPrompt(currentMacros, profile, recipes);
            final systemPrompt = _buildSystemPrompt();

            final llmResult = await _llmService.generateCompletion(
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

    return '''
Please suggest ORIGINAL meals and snacks for me today based on my current progress and targets.

My Macro Targets:
- Protein: 35% of total calories
- Fats: 55% of total calories
- Net Carbs: < 40g (absolute maximum per day)

My Consumed Macros Today:
- Protein: ${current.protein}g (${current.proteinPercent}%)
- Fats: ${current.fats}g (${current.fatsPercent}%)
- Net Carbs: ${current.netCarbs}g
- Total Calories: ${current.calories}

Remaining Macros Capacity:
- Net Carbs: ${(40 - current.netCarbs).toStringAsFixed(1)}g remaining (out of 40g max)
- Aim to balance protein and fats to reach target percentages (35% protein, 55% fats)

User Context:
- Name: ${profile.name}
- Dietary Preferences: ${profile.dietaryApproach}
- Dislikes: ${profile.dislikes.isEmpty ? 'None' : profile.dislikes.join(', ')}
- Allergies: ${profile.allergies.isEmpty ? 'None' : profile.allergies.join(', ')}

$recipeContext

Please provide ORIGINAL, creative suggestions:
1. Suggest 2-3 DIFFERENT meal or snack ideas that are NEW and creative (not just from my library)
2. Include at least one snack option and one full meal option
3. For each suggestion, provide:
   - A creative name for the dish
   - Estimated macros (protein, fats, net carbs, calories)
   - A brief list of ingredients
   - Simple cooking/preparation instructions
   - A helpful tip or variation idea
4. Make sure the suggestions help me reach my remaining macro targets
5. Be creative and think of unique combinations - don't just suggest standard recipes

Format your response in clear markdown with headings for each suggestion.
''';
  }
}
