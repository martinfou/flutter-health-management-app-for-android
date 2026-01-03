# Feature Request: FR-021 - Add AI Suggestion to Meal or Snack

**Status**: ⭕ Not Started
**Priority**: 🟠 High
**Story Points**: 5
**Created**: 2025-01-03
**Updated**: 2025-01-03
**Assigned Sprint**: [Sprint 19](../../sprints/sprint-19-add-ai-suggestion-to-meal.md)

## Description

Enable users to select a food or recipe from AI-generated suggestions and add it directly to a meal (breakfast, lunch, dinner) or snack. This feature enhances the food suggestion workflow by providing a seamless way to log suggested items with proper meal categorization.

## User Story

As a user, I want to select a food or recipe from AI suggestions and add it to a specific meal or snack, so that I can quickly log recommended foods without manually re-entering the details.

## Acceptance Criteria

- [ ] Display selectable food/recipe suggestions from AI in a clear, tappable format
- [ ] When user taps a suggestion, show meal/snack selection options:
  - Breakfast
  - Lunch
  - Dinner
  - Snack
- [ ] Allow user to confirm the selection with portion size adjustment if needed
- [ ] Pre-populate all macro information (protein, fats, net carbs, calories) from the suggestion
- [ ] Save the selected item to the appropriate meal/snack log
- [ ] Show success feedback after adding item to meal log
- [ ] Update daily macro summary after adding the item
- [ ] Handle recipes by either:
  - Adding the recipe as a single meal entry with combined macros, or
  - Breaking down into individual ingredients (based on user preference)
- [ ] Allow cancellation at any point in the selection flow
- [ ] Support adding multiple suggestions in sequence without returning to main screen

## Business Value

This feature completes the food suggestion workflow by:
- Reducing friction between receiving a suggestion and logging it
- Eliminating manual data entry for AI-suggested foods
- Ensuring accurate macro tracking by using suggestion data directly
- Improving user satisfaction with the AI suggestion feature
- Increasing likelihood users will follow through on nutrition recommendations
- Saving time by streamlining the food logging process

## Technical Requirements

### Presentation Layer
- Enhance `FoodSuggestionCard` widget:
  - Add tap handler for selection
  - Visual feedback on selection (highlight/checkmark)
  - "Add to Meal" action button
- Create `MealSelectionBottomSheet` or `MealSelectionDialog`:
  - Display meal type options (Breakfast, Lunch, Dinner, Snack)
  - Show selected food/recipe name and macros summary
  - Optional portion size adjustment slider
  - Confirm and Cancel buttons
- Update `FoodSuggestionPage`:
  - Handle selection state
  - Trigger meal selection flow on item tap
  - Show success snackbar after adding

### Data Layer
- Create use case: `AddSuggestionToMealUseCase`
  - Input: Suggestion data (food name, macros, portion size), meal type, date
  - Output: Success/failure with logged meal ID
- Map AI suggestion data to `Meal` entity:
  - Extract food name → meal name
  - Extract macros → nutrition data
  - Extract portion size → serving size
  - Set meal type from user selection
  - Set date to current date (or selected date)

### Business Logic
- Meal type mapping:
  - Breakfast → `MealType.breakfast`
  - Lunch → `MealType.lunch`
  - Dinner → `MealType.dinner`
  - Snack → `MealType.snack`
- Portion adjustment calculation:
  - If user adjusts portion, recalculate macros proportionally
  - Example: 1.5x portion = 1.5x all macros
- Recipe handling:
  - Option 1: Single entry with recipe name and total macros
  - Option 2: Multiple entries for each ingredient (future enhancement)
- Validation:
  - Ensure all required fields are populated before saving
  - Validate portion size is positive and reasonable

### Navigation Flow
1. User views AI food suggestions
2. User taps suggestion card
3. Meal selection sheet appears
4. User selects meal type (Breakfast/Lunch/Dinner/Snack)
5. User optionally adjusts portion size
6. User taps "Add to [Meal Type]"
7. Item is logged, success feedback shown
8. User returns to suggestions (can add more) or navigates away

## Reference Documents

- `artifacts/phase-2-features/nutrition-module-specification.md` - Nutrition Module Specification
- `artifacts/phase-1-foundations/data-models.md` - Meal and Nutrition Data Models
- FR-004 - Food Suggestion Based on Remaining Macros (parent feature)

## Technical References

- Page: `lib/features/nutrition_management/presentation/pages/food_suggestion_page.dart` (to be created in FR-004)
- Widget: `lib/features/nutrition_management/presentation/widgets/food_suggestion_card.dart` (to be created in FR-004)
- Use Case: `lib/features/nutrition_management/domain/usecases/add_meal.dart`
- Repository: `lib/features/nutrition_management/domain/repositories/nutrition_repository.dart`
- Entity: `lib/features/nutrition_management/domain/entities/meal.dart`
- Enum: `lib/features/nutrition_management/domain/entities/meal_type.dart`

## Dependencies

- FR-004 - Food Suggestion Based on Remaining Macros (must be completed first)
- FR-010 - LLM Integration (must be completed for AI suggestions)
- Meal logging functionality must be working
- `NutritionRepository` must support adding meals

## Notes

- This feature is a natural extension of FR-004 (Food Suggestions)
- Should be implemented immediately after or as part of FR-004
- Consider adding "Add All" functionality for multiple suggestions in future enhancement
- May want to add meal time suggestions based on current time of day
- Consider remembering last selected meal type for convenience
- Recipe support may need additional UI for ingredient breakdown option

## History

- 2025-01-03 - Created based on user request for selecting AI suggestions and adding to meals/snacks
