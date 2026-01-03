# Sprint 19: Add AI Suggestion to Meal or Snack

**Sprint Goal:** Enable users to select AI-suggested foods or recipes and seamlessly add them to a specific meal (Breakfast, Lunch, Dinner) or Snack—completing the food suggestion workflow with one-tap logging.

**Duration:** [TBD] (1 week)
**Team Velocity:** Target 5 points
**Sprint Planning Date:** [TBD]
**Sprint Review Date:** [TBD]
**Sprint Retrospective Date:** [TBD]

---

## Related Feature Requests

- [FR-021: Add AI Suggestion to Meal or Snack](../backlog/features/FR-021-add-ai-suggestion-to-meal.md) - 5 points

---

## Sprint Overview

**Focus Areas:**
- Selection UI for AI-generated food/recipe suggestions
- Meal type selection flow (Breakfast, Lunch, Dinner, Snack)
- Seamless logging of selected suggestions with macro data
- Portion adjustment and confirmation flow

**Key Deliverables:**
- UI: Selectable suggestion cards with tap feedback
- UI: Meal selection bottom sheet/dialog
- Logic: `AddSuggestionToMealUseCase` implementation
- Integration: Direct logging from suggestion to meal log
- Automated and manual tests

**Dependencies:**
- FR-004 (Sprint 18): Food Suggestion Based on Remaining Macros must be completed
- FR-010 (Sprint 15): LLM Integration must be working
- Meal logging functionality (`AddMealUseCase`) must be operational
- `FoodSuggestionPage` and `FoodSuggestionCard` from Sprint 18

**Risks & Blockers:**
- Sprint 18 (FR-004) must be fully completed first
- Meal type enum/entity compatibility with suggestion data
- Portion adjustment recalculation accuracy
- UX flow clarity for multi-step selection process

---

## User Stories

### Story 19.1: Add AI Suggestion to Meal - 5 Points

**User Story:** As a user, I want to select a food or recipe from AI suggestions and add it to a specific meal or snack, so that I can quickly log recommended foods without manually re-entering the details.

#### Acceptance Criteria
- [ ] Food suggestion cards are tappable/selectable
- [ ] Visual feedback on selection (highlight, checkmark, or similar)
- [ ] Meal selection sheet appears with options: Breakfast, Lunch, Dinner, Snack
- [ ] Selected food name and macro summary displayed in selection sheet
- [ ] Optional portion size adjustment (slider or input)
- [ ] Macros recalculate proportionally when portion is adjusted
- [ ] "Add to [Meal Type]" button confirms and saves
- [ ] Success feedback (snackbar/toast) after logging
- [ ] Daily macro summary updates after adding item
- [ ] Cancel option available at all steps
- [ ] Can add multiple suggestions in sequence
- [ ] Handles edge cases: empty selection, invalid portion, save failure

#### Reference Documents
- FR-021 spec | FR-004 spec | Nutrition Module | Data Models

---

## Tasks

| Task ID | Task Description                              | Owner | Status | Points |
|---------|-----------------------------------------------|-------|--------|--------|
| T-1901  | Add tap handler & selection state to `FoodSuggestionCard` |       | ⭕     | 1      |
| T-1902  | Create `MealSelectionBottomSheet` widget      |       | ⭕     | 1      |
| T-1903  | Implement portion adjustment with macro recalc |       | ⭕     | 0.5    |
| T-1904  | Implement `AddSuggestionToMealUseCase`        |       | ⭕     | 1      |
| T-1905  | Map suggestion data to `Meal` entity          |       | ⭕     | 0.5    |
| T-1906  | Integrate with `FoodSuggestionPage` navigation flow |       | ⭕     | 0.5    |
| T-1907  | Add success feedback and macro summary refresh |       | ⭕     | 0.5    |
| T-1908  | Automated & manual tests                      |       | ⭕     | 1      |

---

## Technical Implementation Notes

### Presentation Layer
```
lib/features/nutrition_management/presentation/
├── widgets/
│   ├── food_suggestion_card.dart      # Enhanced with selection
│   └── meal_selection_bottom_sheet.dart  # New widget
└── pages/
    └── food_suggestion_page.dart      # Updated with selection flow
```

### Domain Layer
```
lib/features/nutrition_management/domain/
└── usecases/
    └── add_suggestion_to_meal.dart    # New use case
```

### Data Mapping
- Suggestion `foodName` → Meal `name`
- Suggestion `macros` → Meal `nutritionData`
- Suggestion `portionSize` → Meal `servingSize`
- User selection → Meal `mealType`
- Current date → Meal `date`

---

## Demo Checklist
- [ ] Tap a suggestion card → selection visual feedback appears
- [ ] Meal selection sheet opens with all 4 meal types
- [ ] Portion adjustment recalculates macros correctly
- [ ] Confirm adds item to selected meal type
- [ ] Success message appears after logging
- [ ] Macro summary on main page reflects new addition
- [ ] Can add multiple suggestions without leaving page
- [ ] Cancel works at every step

---

## Notes
- This sprint builds directly on Sprint 18's food suggestion infrastructure
- Keep the UX simple: minimize taps to complete the flow
- Consider defaulting meal type based on current time of day (future enhancement)
- Recipe handling (single entry vs. ingredient breakdown) can be v2 enhancement

---
**Last Updated:** 2025-01-03
**Status:** Sprint Planning Draft
