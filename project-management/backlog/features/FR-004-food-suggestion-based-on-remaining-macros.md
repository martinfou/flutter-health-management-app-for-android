# Feature Request: FR-004 - Food Suggestion Based on Remaining Macros

**Status**: ⭕ Not Started  
**Priority**: 🟠 High  
**Story Points**: 8  
**Created**: 2025-01-02  
**Updated**: 2025-01-02  
**Assigned Sprint**: Backlog

## Description

Implement an intelligent food suggestion feature that recommends foods to consume based on the user's remaining macro targets for the day. The LLM-powered suggestion system will analyze the user's food log to get inspiration from previously logged meals, ensuring suggestions align with the user's eating patterns and preferences while helping them meet their macro goals.

## User Story

As a user, I want to receive food suggestions based on my remaining macro targets, so that I can easily find foods to eat that will help me meet my daily nutrition goals without manually calculating what I still need.

## Acceptance Criteria

- [ ] Calculate remaining macros (target macros - consumed macros) for the current day
- [ ] Display remaining macros clearly (protein, fats, net carbs, calories)
- [ ] Add "Get Food Suggestions" button/action on macro tracking page
- [ ] LLM analyzes user's food log (past meals) to understand eating patterns and preferences
- [ ] LLM generates food suggestions that:
  - Match remaining macro targets (prioritize foods that fit remaining macros)
  - Are inspired by foods the user has previously logged
  - Include macro breakdown for each suggestion
  - Provide portion sizes that help meet remaining targets
- [ ] Display suggestions in a user-friendly format (list or cards)
- [ ] Each suggestion shows:
  - Food name
  - Portion size
  - Macro breakdown (protein, fats, net carbs, calories)
  - How it fits remaining macros (e.g., "Covers 50% of remaining protein")
- [ ] User can select a suggestion to quickly log it as a meal
- [ ] Handle edge cases:
  - No remaining macros (all targets met) → show message
  - No food log history → use general suggestions
  - Remaining macros are very small → suggest appropriate portion sizes
- [ ] Loading state while LLM processes request
- [ ] Error handling for LLM API failures

## Business Value

This feature significantly improves user experience by:
- Reducing the cognitive load of manually calculating what to eat to meet macro targets
- Helping users stay on track with their nutrition goals throughout the day
- Personalizing suggestions based on their actual eating history (not generic recommendations)
- Increasing user engagement with the nutrition tracking feature
- Improving adherence to macro targets by making it easier to find appropriate foods
- Saving time by eliminating the need to search through food databases manually

## Technical Requirements

### Data Layer
- Calculate remaining macros:
  - Get daily macro targets from user profile (or use defaults: 35% protein, 55% fats, <40g net carbs)
  - Get consumed macros from `GetDailyMacroSummaryUseCase` for current date
  - Calculate remaining: `remaining = target - consumed`
- Retrieve food log history:
  - Query meals from `NutritionRepository` (last 30 days recommended for pattern analysis)
  - Extract food names, ingredients, and macro patterns from logged meals

### LLM Integration
- Create new use case: `GetFoodSuggestionsUseCase`
  - Input: Remaining macros (protein, fats, net carbs, calories), food log history
  - Output: List of food suggestions with macro breakdowns
- Create LLM prompt template for food suggestions:
  - Include remaining macro targets
  - Include food log history (last 30 days) for inspiration
  - Request suggestions that match remaining macros
  - Request portion sizes that help meet targets
  - Format: JSON with food name, portion size, macros, description
- Integrate with LLM service (post-MVP architecture already in place)
- Handle LLM API errors gracefully

### Presentation Layer
- Add "Get Suggestions" button to `MacroTrackingPage`:
  - Show when there are remaining macros
  - Disabled when all targets are met
- Create new page: `FoodSuggestionPage`:
  - Display remaining macros summary at top
  - Show loading indicator while fetching suggestions
  - Display suggestions in scrollable list/cards
  - Each suggestion card shows:
    - Food name and description
    - Portion size
    - Macro breakdown
    - "Log This" button to quickly add to meal log
  - Empty state if no suggestions available
  - Error state if LLM request fails
- Create widget: `FoodSuggestionCard`:
  - Displays suggestion details
  - Shows macro breakdown visually
  - Quick action to log the suggestion
- Navigation: Route from macro tracking page to suggestion page

### Business Logic
- Remaining macro calculation:
  - Handle negative values (over target) → show as 0 remaining
  - Handle very small remaining values → suggest appropriate portion sizes
- Food log analysis:
  - Extract common foods/ingredients from past meals
  - Identify macro patterns (e.g., user tends to eat high-protein breakfasts)
  - Use this context in LLM prompt for personalized suggestions
- Suggestion filtering:
  - Prioritize suggestions that best match remaining macros
  - Ensure suggestions are realistic and achievable

### Error Handling
- LLM API failures → show error message with retry option
- No food log history → use general suggestions (fallback)
- Network errors → show appropriate error state
- Invalid remaining macros → validate before making LLM request

## Reference Documents

- `artifacts/phase-2-features/nutrition-module-specification.md` - Nutrition Module Specification
- `artifacts/requirements.md` - Meal Suggestion Prompt Template (lines 1731-1752)
- `artifacts/phase-1-foundations/data-models.md` - Meal and Nutrition Data Models
- `artifacts/phase-1-foundations/architecture-documentation.md` - LLM Integration Architecture

## Technical References

- Use Case: `lib/features/nutrition_management/domain/usecases/get_daily_macro_summary.dart`
- Use Case: `lib/features/nutrition_management/domain/usecases/calculate_macros.dart`
- Repository: `lib/features/nutrition_management/domain/repositories/nutrition_repository.dart`
- Page: `lib/features/nutrition_management/presentation/pages/macro_tracking_page.dart`
- LLM Service: `lib/core/llm/` (architecture already in place)
- Entity: `lib/features/nutrition_management/domain/entities/meal.dart`

## Dependencies

- LLM integration service must be implemented (post-MVP feature, but architecture exists)
- User profile with macro targets (or use default targets)
- Food log history (meals must be logged to provide inspiration)
- `GetDailyMacroSummaryUseCase` must be working correctly
- `NutritionRepository` must support querying meals by date range

## Notes

- This is a post-MVP feature that requires LLM integration
- The LLM integration architecture is already designed in `lib/core/llm/`
- Food log analysis provides personalization - suggestions will be more relevant if user has logged meals
- Consider caching suggestions to reduce LLM API calls (cache for 1 hour or until new meal is logged)
- Portion sizes should be realistic and practical (not "0.3 chicken breasts")
- Suggestions should consider meal timing (e.g., if it's evening, suggest dinner-appropriate foods)
- May want to add "refresh suggestions" option if user logs a meal and wants new suggestions
- Consider adding user preferences (dietary restrictions, allergies) to LLM prompt in future enhancement

## Design Decisions

- **Suggestion Source**: LLM analyzes food log first, then generates suggestions - ensures personalization
- **Remaining Macros Display**: Show on macro tracking page and suggestion page for context
- **Quick Logging**: Allow users to log suggestions directly from suggestion page for convenience
- **Food Log Window**: Analyze last 30 days of meals for pattern recognition (configurable)
- **Fallback Behavior**: If no food log history, use general macro-based suggestions
- **Error Recovery**: Provide retry mechanism for LLM failures
- **Performance**: Consider caching suggestions to reduce API calls

## History

- 2025-01-02 - Created based on user request for food suggestions based on remaining macros with food log inspiration

