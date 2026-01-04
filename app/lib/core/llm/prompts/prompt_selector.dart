import '../llm_provider.dart';

/// Prompt selector that chooses appropriate prompts based on LLM provider capabilities
class PromptSelector {
  const PromptSelector();

  /// Select appropriate weekly review prompt based on provider type
  String selectWeeklyReviewPrompt(LlmProviderType providerType) {
    switch (providerType) {
      case LlmProviderType.onDevice:
        return _slmWeeklyReviewPrompt;
      default:
        return _standardWeeklyReviewPrompt;
    }
  }

  /// Select appropriate food suggestion prompt based on provider type
  String selectFoodSuggestionPrompt(LlmProviderType providerType) {
    switch (providerType) {
      case LlmProviderType.onDevice:
        return _slmFoodSuggestionPrompt;
      default:
        return _standardFoodSuggestionPrompt;
    }
  }

  /// Select appropriate workout adaptation prompt based on provider type
  String selectWorkoutAdaptationPrompt(LlmProviderType providerType) {
    switch (providerType) {
      case LlmProviderType.onDevice:
        return _slmWorkoutAdaptationPrompt;
      default:
        return _standardWorkoutAdaptationPrompt;
    }
  }

  /// Standard weekly review prompt (for cloud LLMs with larger context)
  static const String _standardWeeklyReviewPrompt = '''
Review my health data for the week and provide insights.

User Context:
- Name: {name}
- Current Weight: {currentWeight}kg
- Target Weight: {targetWeight}kg
- Primary Goal: {goals}

Weekly Data:
{metrics}

Please provide:
1. A brief summary of my progress this week.
2. Recognition of "Non-Scale Victories" (e.g., consistent sleep, steady energy).
3. Analysis of any correlations (e.g., how sleep affects energy).
4. One or two actionable recommendations for the coming week.
5. A motivational closing.

Keep the response concise and formatted in markdown.
''';

  /// SLM-optimized weekly review prompt (shorter, focused for <2K tokens)
  static const String _slmWeeklyReviewPrompt = '''
Analyze this week's health data for {name} (weight: {currentWeight}kg, target: {targetWeight}kg, goals: {goals}).

Data:
{metrics}

Provide:
1. Weekly progress summary (2-3 sentences)
2. Key health insights (sleep/energy correlations)
3. 1-2 specific recommendations
4. Encouraging note

Keep under 500 words. Use markdown.
''';

  /// Standard food suggestion prompt (for cloud LLMs)
  static const String _standardFoodSuggestionPrompt = '''
Please suggest meals and snacks based on my current progress and targets.

My Macro Targets:
- Protein: 35% of total calories
- Fats: 55% of total calories
- Net Carbs: < 40g (absolute maximum per day)

My Consumed Macros Today:
- Protein: {protein}g ({proteinPercent}%)
- Fats: {fats}g ({fatsPercent}%)
- Net Carbs: {netCarbs}g
- Total Calories: {calories}

Remaining Macros Capacity:
- Net Carbs: {remainingCarbs}g remaining (out of 40g max)
- Aim to balance protein and fats to reach target percentages (35% protein, 55% fats)

User Context:
- Name: {name}
- Dietary Preferences: {dietaryApproach}
- Dislikes: {dislikes}
- Allergies: {allergies}

{recipeContext}

Please provide ORIGINAL, creative suggestions:
1. Suggest 2-3 DIFFERENT meal or snack ideas that are NEW and creative
2. Include at least one snack option and one full meal option
3. For each suggestion, provide estimated macros, ingredients, and instructions
4. Make sure the suggestions help me reach my remaining macro targets
5. Be creative and think of unique combinations

Format your response in clear markdown with headings for each suggestion.
''';

  /// SLM-optimized food suggestion prompt (shorter for limited context)
  static const String _slmFoodSuggestionPrompt = '''
Suggest creative meals/snacks for {name} within macro targets.

Current intake: {protein}g protein, {fats}g fats, {netCarbs}g carbs, {calories} cal
Remaining carbs: {remainingCarbs}g (max 40g/day)

Preferences: {dietaryApproach}
Restrictions: {dislikes}, {allergies}

Provide 2-3 original meal/snack ideas with:
- Creative name
- Estimated macros (protein/fats/carbs/calories)
- Key ingredients
- Brief prep instructions

Focus on remaining macro targets. Keep creative and varied.
''';

  /// Standard workout adaptation prompt (for cloud LLMs)
  static const String _standardWorkoutAdaptationPrompt = '''
I need help modifying an exercise in my workout.

Current Exercise:
- Name: {exerciseName}
- Type: {exerciseType}
- Current Setup: {sets} sets of {reps} reps @ {weight}kg
- Target Muscles: {muscleGroups}

My Feedback:
"{feedback}"

User Context:
- Name: {name}
- Goals: {goals}
- Physical Limitations/Health Notes: {healthConditions}

Available Exercises in my Library:
{exercises}

Please provide:
1. An explanation of why the current exercise might be challenging
2. 2-3 specific modifications or alternative exercises
3. For each modification, explain how to perform it safely
4. Adjusted sets/reps/weight if applicable

Keep the response supportive, safe, and formatted in markdown.
''';

  /// SLM-optimized workout adaptation prompt (shorter, safety-focused)
  static const String _slmWorkoutAdaptationPrompt = '''
Modify exercise for {name} (goals: {goals}, conditions: {healthConditions}).

Current: {exerciseName} ({exerciseType}) - {sets}x{reps}@{weight}kg, targeting {muscleGroups}

Issue: "{feedback}"

Available alternatives: {exercises}

Provide:
1. Why current exercise is problematic (1-2 sentences)
2. 2-3 safe modifications or alternatives
3. Brief safety instructions for each
4. Suggested sets/reps/weight adjustments

Prioritize safety and effectiveness.
''';
}
