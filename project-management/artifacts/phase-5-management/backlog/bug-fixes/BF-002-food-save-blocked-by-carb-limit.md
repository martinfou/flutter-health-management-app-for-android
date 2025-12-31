# Bug Fix: BF-002 - Food Save Blocked by 40g Carb Limit Validation

**Status**: ⭕ Not Started  
**Priority**: 🟠 High  
**Story Points**: 3  
**Created**: 2025-01-03  
**Updated**: 2025-01-03  
**Assigned Sprint**: Backlog

## Description

The app currently prevents users from saving food entries that have more than 40 grams of net carbs by throwing a validation error. This blocks core functionality (food logging) and prevents users from recording their actual food intake. The 40g carb limit should be treated as a guideline/warning rather than a hard validation rule that blocks saving.

## Steps to Reproduce

1. Open the app and navigate to the food logging screen
2. Enter food details with net carbs exceeding 40g (e.g., 45g net carbs)
3. Attempt to save the food entry
4. Observe that save operation fails with validation error
5. Food entry is not saved

## Expected Behavior

- User should see a warning message when net carbs exceed 40g (e.g., "Warning: Net carbs exceed 40g limit. Current: 45.0g")
- User should be able to acknowledge the warning and proceed with saving
- Food entry should be saved successfully despite exceeding the 40g limit
- Warning should be displayed in the UI to inform user but not block the action

## Actual Behavior

- Save operation fails with `ValidationFailure` error
- Error message displayed: "Net carbs exceed 40g limit. Current: [X]g" or "Net carbs must be less than 40g for low-carb diet"
- Food entry is not saved
- User cannot proceed with logging the food

## Environment

- **Device**: Any Android device
- **Android Version**: Android API 24-34
- **App Version**: Current development version
- **OS**: Android

## Screenshots/Logs

Error occurs when attempting to save food with netCarbs > 40g.

## Technical Details

- **Module**: Nutrition Management - Food Logging
- **Related Documents**: 
  - `artifacts/phase-2-features/nutrition-module-specification.md` - Macro Tracking section
  - `artifacts/phase-1-foundations/data-models.md` - Meal entity validation
- **Classes/Methods**: 
  - `LogMealUseCase._validateMeal()` - `lib/features/nutrition_management/domain/usecases/log_meal.dart` (lines 108-112)
  - `NutritionRepositoryImpl.saveMeal()` - `lib/features/nutrition_management/data/repositories/nutrition_repository_impl.dart` (lines 78-81)
- **Error Messages**: 
  - "Net carbs exceed 40g limit. Current: ${netCarbs.toStringAsFixed(1)}g"
  - "Net carbs must be less than 40g for low-carb diet"

## Root Cause

1. **Hard Validation in Use Case**: `LogMealUseCase._validateMeal()` returns `ValidationFailure` when `netCarbs > 40.0`, which prevents the meal from being saved (line 109-112).

2. **Hard Validation in Repository**: `NutritionRepositoryImpl.saveMeal()` also validates and returns `ValidationFailure` when `meal.netCarbs >= 40`, creating a second layer of blocking validation (line 78-81).

3. **Design Philosophy**: The 40g carb limit is intended as a guideline for low-carb diet tracking, not a hard requirement. Users should be able to log their actual food intake even if it exceeds the guideline, with appropriate warnings displayed.

## Solution

1. **Remove Hard Validation**: Remove the validation checks that block saving when netCarbs > 40g from:
   - `LogMealUseCase._validateMeal()` method
   - `NutritionRepositoryImpl.saveMeal()` method

2. **Add Warning Mechanism**: Implement a warning system that:
   - Detects when netCarbs > 40g
   - Displays a non-blocking warning message in the UI
   - Allows user to proceed with saving after acknowledging the warning
   - Shows warning in macro tracking displays (already partially implemented in `macro_chart_widget.dart` and `macro_tracking_page.dart`)

3. **Update UI Flow**: Modify the food logging UI to:
   - Show warning dialog or banner when netCarbs > 40g
   - Provide "Save Anyway" option
   - Display warning indicators in macro summary displays

4. **Update Tests**: Update unit tests to:
   - Remove tests that expect ValidationFailure for netCarbs > 40g
   - Add tests that verify meals with netCarbs > 40g can be saved successfully
   - Add tests for warning display logic

## Reference Documents

- `artifacts/phase-2-features/nutrition-module-specification.md` - Macro Tracking section (Net Carbs: Capped at 40g absolute maximum)
- `artifacts/phase-1-foundations/data-models.md` - Meal entity validation rules
- `artifacts/requirements.md` - Macro tracking requirements (net carbs <40g absolute maximum)

## Technical References

- Class/Method: `LogMealUseCase._validateMeal()` - `lib/features/nutrition_management/domain/usecases/log_meal.dart` (lines 108-112)
- Class/Method: `NutritionRepositoryImpl.saveMeal()` - `lib/features/nutrition_management/data/repositories/nutrition_repository_impl.dart` (lines 78-81)
- File: `lib/features/nutrition_management/presentation/widgets/macro_chart_widget.dart` (warning display already exists)
- File: `lib/features/nutrition_management/presentation/pages/macro_tracking_page.dart` (warning display already exists)
- Test: `test/unit/features/nutrition_management/domain/usecases/log_meal_test.dart` (line 226-244)
- Test: `test/unit/features/nutrition_management/data/repositories/nutrition_repository_impl_test.dart` (line 237-261)

## Testing

- [ ] Unit test updated for `LogMealUseCase` - remove ValidationFailure expectation for netCarbs > 40g
- [ ] Unit test updated for `NutritionRepositoryImpl` - remove ValidationFailure expectation for netCarbs >= 40g
- [ ] Unit test added to verify meals with netCarbs > 40g can be saved successfully
- [ ] Widget test added/updated for warning display in food logging UI
- [ ] Integration test updated for food logging flow with high carb foods
- [ ] Manual testing completed:
  - [ ] Save food with netCarbs = 45g (should succeed with warning)
  - [ ] Save food with netCarbs = 50g (should succeed with warning)
  - [ ] Verify warning is displayed in UI
  - [ ] Verify warning appears in macro tracking displays
  - [ ] Verify food is saved successfully despite warning

## Notes

- This is a high priority bug as it blocks core functionality (food logging)
- The 40g carb limit is a guideline for low-carb diet tracking, not a hard requirement
- Users should be able to log their actual food intake, even if it exceeds guidelines
- Warning displays already exist in macro tracking UI (`macro_chart_widget.dart`, `macro_tracking_page.dart`) - these should continue to work
- This change aligns with the principle that users should have control over their data entry, with guidance rather than restrictions

## History

- 2025-01-03 - Created

