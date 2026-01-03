# Feature Request: FR-005 - Hunger Scale and Eating Reasons When Logging Food

**Status**: ✅ Completed  
**Priority**: 🟡 Medium  
**Story Points**: 8  
**Created**: 2025-01-02  
**Updated**: 2025-01-03  
**Assigned Sprint**: [Sprint 11](../../sprints/sprint-11-post-mvp-improvements.md)

## Description

Add behavioral tracking features to the meal logging page that allow users to rate their hunger/fullness level before and after eating (0-10 scale, where 0 = extremely hungry, 5 = neutral, 10 = extremely full) and select reasons for eating (e.g., Stressed, Celebration, Bored, Tired, Hungry, Time to Eat) when logging a meal. This helps users track their eating patterns, understand hunger cues, identify emotional eating triggers, recognize relationships between hunger levels, eating reasons, and food choices, and monitor how meals affect their satiety over time. Both hunger/fullness scale ratings (before and after, with timestamps) and eating reasons will be stored with each meal and can be used for future behavioral analysis and insights.

## User Story

As a user, I want to rate my hunger level before and after eating and select why I'm eating when logging food, so that I can track my eating patterns, understand emotional eating triggers, monitor how meals affect my hunger, and better understand the relationship between my hunger levels, eating reasons, and food choices.

## Acceptance Criteria

### Hunger Scale
- [x] Add hunger scale widgets to `MealLoggingPage`:
  - Display "Hunger Before" scale selector (0-10 scale) before meal is saved
  - Display "Fullness After" scale selector (0-10 scale) after meal is saved (or allow user to update it later)
  - Show descriptive labels for scale values (0 = "Extremely hungry", 5 = "Neutral", 10 = "Extremely full")
  - Include visual calibration aid (faces, colors, or examples) to help users interpret the scale
  - Store timestamp for "Fullness After" measurement to track when it was logged
  - Make both hunger scales optional (user can skip if they don't want to log them)
  - Display hunger scales visually (slider or segmented buttons)
- [x] Update `Meal` entity to include optional `hungerLevelBefore` and `hungerLevelAfter` fields (int, 0-10, nullable)
- [x] Update `Meal` entity to include optional `fullnessAfterTimestamp` field (DateTime?, nullable) to track when "after" was measured
- [x] Update `MealModel` (Hive model) to include both `hungerLevelBefore`, `hungerLevelAfter`, and `fullnessAfterTimestamp` fields
- [x] Update meal logging use case to accept and save both hunger levels and timestamp
- [x] Display both hunger levels on meal detail page (if available)
- [x] Display hunger levels on meal cards/list (if available, show as "Before: 3, After: 7")
- [x] Handle migration for existing meals (hunger levels will be null for existing meals)
- [x] Add validation: both hunger levels must be between 0-10 if provided
- [x] Handle edge cases gracefully:
  - Allow any valid combination (don't assume before < after)
- [x] Ensure hunger scales are accessible (screen reader support, proper touch targets)
- [x] Allow user to update "Fullness After" on meal detail page if not logged initially

### Eating Reasons
- [x] Create `EatingReason` enum (`lib/features/nutrition_management/domain/entities/eating_reason.dart`):
  - Include: hungry, stressed, celebration, bored, tired, scheduled (time to eat)
  - Optional additions: social, craving
  - Include `displayName` getter for UI labels
  - Include `description` getter for tooltips/help text
  - Include `category` getter to group by: physical, emotional, social
- [x] Update `Meal` entity to include optional `eatingReasons` field (List<EatingReason>?, nullable)
- [x] Update `MealModel` (Hive model) to include `eatingReasons` field (store as List<String> with enum names for better data integrity and debugging)
- [x] Update meal logging use case to accept and save eating reasons
- [x] Add eating reasons widget to `MealLoggingPage`:
  - Display multi-select chip-based selector
  - Group reasons by category (Physical, Emotional, Social) with section headers
  - Make eating reasons optional (user can skip if they don't want to log it)
  - Allow multiple selections (user can select multiple reasons)
  - Use visual chips with icons for each reason
- [x] Display eating reasons on meal detail page (if available)
- [x] Display eating reasons on meal cards/list (if available, show as icons or chips)
- [x] Handle migration for existing meals (eating reasons will be null/empty for existing meals)
- [x] Add validation: eating reasons list must contain valid enum values if provided
- [x] Allow empty list for eating reasons (distinct from null - empty = user explicitly chose none, null = not answered)
- [x] Ensure eating reasons selector is accessible (screen reader support, proper touch targets)

### UI/UX Integration
- [x] Create "Meal Context" section on `MealLoggingPage`:
  - Place after meal totals card, before save button
  - Group hunger scale and eating reasons together
  - Show clear section header: "Meal Context (Optional)"
  - Use collapsible/expandable section to reduce visual clutter (optional)
- [x] Ensure both features work independently (user can log one, both, or neither)

## Business Value

This feature provides significant value for users by:
- Helping users develop awareness of their hunger cues and eating patterns
- Identifying emotional eating triggers (stress, boredom, tiredness) and patterns
- Monitoring how meals affect hunger levels (satiety tracking)
- Enabling future behavioral analysis features:
  - "You tend to eat more calories when hunger level before is 8+"
  - "You logged meals with high hunger levels before eating 3 days in a row"
  - "Meals logged as 'Stressed' average 450 more calories than meals logged as 'Hungry'"
  - "You tend to eat when tired in the evenings"
  - "Stress eating increased 40% this week"
  - "Meals with higher protein tend to result in higher fullness levels after eating"
  - "You often still feel hungry (fullness after < 5) after meals with < 30g protein"
- Supporting mindful eating practices by encouraging users to check in with their hunger before and after eating
- Providing data for future insights and recommendations:
  - Pattern detection: "You eat when stressed 3+ times per week" (framed as patterns, not causes)
  - Correlation analysis: "Boredom eating correlates with higher calorie meals" (with disclaimer: correlation, not causation)
  - Trend analysis: "Celebration meals are 30% higher in calories" (with data quality indicators)
  - Satiety analysis: "High-protein meals result in higher average fullness levels" (weighted by data completeness)
  - Meal effectiveness: "Meals with 40g+ protein consistently result in higher fullness levels" (based on meals with complete data)
- Improving user engagement with the nutrition tracking feature by adding a behavioral component
- Supporting weight loss goals by helping users identify patterns between hunger levels, eating reasons, and food choices
- Enabling targeted behavioral interventions based on eating reason patterns
- Helping users understand meal satiety and make better food choices based on hunger response

## Technical Requirements

### Data Layer
- Create `EatingReason` enum (`lib/features/nutrition_management/domain/entities/eating_reason.dart`):
  - Values: `hungry`, `stressed`, `celebration`, `bored`, `tired`, `scheduled`
  - Optional: `social`, `craving` (for future expansion)
  - Include `displayName` getter for UI labels
  - Include `description` getter for tooltips
  - Include `category` getter returning `EatingReasonCategory` enum (physical, emotional, social)
- Create `EatingReasonCategory` enum:
  - Values: `physical`, `emotional`, `social`
- Update `Meal` entity (`lib/features/nutrition_management/domain/entities/meal.dart`):
  - Add optional `hungerLevelBefore` field: `final int? hungerLevelBefore;` (0-10, nullable)
  - Add optional `hungerLevelAfter` field: `final int? hungerLevelAfter;` (0-10, nullable)
  - Add optional `fullnessAfterTimestamp` field: `final DateTime? fullnessAfterTimestamp;` (nullable) - tracks when "after" was measured
  - Add optional `eatingReasons` field: `final List<EatingReason>? eatingReasons;` (nullable) - null = not answered, empty list = explicitly no reasons
  - Update constructor to include `hungerLevelBefore`, `hungerLevelAfter`, `fullnessAfterTimestamp`, and `eatingReasons` parameters
  - Update `copyWith` method to include all four fields
  - Update `==` operator and `hashCode` to include all four fields
  - Update `toString` to include all four fields (optional)
- Update `MealModel` (`lib/features/nutrition_management/data/models/meal_model.dart`):
  - Add `hungerLevelBefore` field to Hive model (nullable int, 0-10)
  - Add `hungerLevelAfter` field to Hive model (nullable int, 0-10)
  - Add `fullnessAfterTimestamp` field to Hive model (nullable DateTime)
  - Add `eatingReasons` field to Hive model (nullable List<String> storing enum names for better data integrity)
  - Update `toEntity()` method to map all four fields
  - Update `fromEntity()` method to map all four fields
  - Update Hive type adapter if needed
  - Include migration strategy for enum changes (version enum system or string-based storage)
- Update `NutritionLocalDataSource`:
  - Ensure `hungerLevelBefore`, `hungerLevelAfter`, `fullnessAfterTimestamp`, and `eatingReasons` are properly saved and retrieved from Hive
  - Handle null values for existing meals (backward compatibility)
  - Convert enum list to/from string list for Hive storage (more robust than indices)

### Domain Layer
- Update `LogMealUseCase` (`lib/features/nutrition_management/domain/usecases/log_meal.dart`):
  - Add optional `hungerLevelBefore` parameter (int?, 0-10)
  - Add optional `hungerLevelAfter` parameter (int?, 0-10)
  - Add optional `fullnessAfterTimestamp` parameter (DateTime?, nullable) - auto-set to current time if after is provided
  - Add optional `eatingReasons` parameter (List<EatingReason>?, nullable) - allow empty list (distinct from null)
  - Add validation: if `hungerLevelBefore` is provided, must be between 0-10
  - Add validation: if `hungerLevelAfter` is provided, must be between 0-10
  - Add validation: if `eatingReasons` is provided, must contain valid enum values (empty list is valid)
  - Don't flag unusual patterns (after < before) as errors - allow any valid combination
  - Pass `hungerLevelBefore`, `hungerLevelAfter`, `fullnessAfterTimestamp`, and `eatingReasons` to `Meal` entity when creating meal
- Update `UpdateMealUseCase` (if exists) to support updating hunger levels and timestamp after meal is logged
- Create `UpdateFullnessAfterUseCase` (optional) for updating fullness after measurement separately
- Update `NutritionRepository` interface:
  - Ensure repository methods handle `hungerLevelBefore`, `hungerLevelAfter`, `fullnessAfterTimestamp`, and `eatingReasons` fields (should be automatic if entity is updated)

### Presentation Layer
- Update `MealLoggingPage` (`lib/features/nutrition_management/presentation/pages/meal_logging_page.dart`):
  - Add state variables: `int? _hungerLevelBefore;`, `int? _hungerLevelAfter;`, and `Set<EatingReason> _selectedEatingReasons = {};`
  - Create "Meal Context" section:
    - Place after meal totals card, before save button
    - Group hunger scales and eating reasons together
    - Use collapsible/expandable Card widget (optional, to reduce clutter)
  - Add "Hunger Before" scale widget:
    - Use `SegmentedButton` or `Slider` widget for selection
    - Show descriptive labels for scale values
    - Make it optional (allow user to skip)
    - Add visual feedback for selected hunger level
    - Label: "How hungry are you? (Before eating)"
  - Add "Fullness After" scale widget:
    - Use `SegmentedButton` or `Slider` widget for selection
    - Show descriptive labels for scale values
    - Make it optional (allow user to skip)
    - Add visual feedback for selected hunger level
    - Label: "How full are you now? (After eating)" (optional, can be filled later)
  - Add eating reasons widget:
    - Use `FilterChip` or `ChoiceChip` widgets for multi-select
    - Group by category (Physical, Emotional, Social) with section headers
    - Show icons for each reason (optional, for visual clarity)
    - Allow multiple selections
    - Make it optional (allow user to skip)
    - Add visual feedback for selected reasons
  - Update `_saveMeal()` method to pass `_hungerLevelBefore`, `_hungerLevelAfter`, and `_selectedEatingReasons.toList()` to use case
- Create `HungerScaleWidget` (optional, if extracting to reusable widget):
  - Display 0-10 scale with labels
  - Handle selection and callbacks
  - Support optional selection (can be null)
  - Accept label parameter (e.g., "Before" or "After")
- Create `EatingReasonsWidget` (optional, if extracting to reusable widget):
  - Display multi-select chips grouped by category
  - Handle selection and callbacks
  - Support optional selection (can be empty)
  - Return `Set<EatingReason>` for selected reasons
- Update `MealDetailPage` (`lib/features/nutrition_management/presentation/pages/meal_detail_page.dart`):
  - Display hunger levels if available (e.g., "Before: 2/10, After: 7/10")
  - Display eating reasons if available (e.g., show as chips or icons with labels)
  - Show in meal information section
  - Allow user to update "Fullness After" if not logged initially (add edit button/field)
- Update `MealCardWidget` (`lib/features/nutrition_management/presentation/widgets/meal_card_widget.dart`):
  - Optionally display hunger levels if available (e.g., "2/10 → 7/10" or small visual)
  - Optionally display eating reason icons/chips if available
  - Use subtle visual indicators (e.g., small icons)

### UI Layout Design

The following ASCII layout shows the structure of the Meal Logging Page with the new behavioral tracking features:

```
┌─────────────────────────────────────────────────────────────────┐
│  Log Meal                                    [← Back]           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  Meal Type                                              │  │
│  │  [Breakfast] [Lunch] [Dinner] [Snack]                  │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  Food Items                          [+ Add] [📋 Recipe]│  │
│  │  ┌───────────────────────────────────────────────────┐  │  │
│  │  │  Grilled Chicken Breast                           │  │  │
│  │  │  45.0g P / 12.0g F / 0.0g C / 288 cal            │  │  │
│  │  │                                    [✏️ Edit] [🗑️] │  │  │
│  │  └───────────────────────────────────────────────────┘  │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  Meal Totals                                            │  │
│  │  Protein:        45.0g  (62.5%)                        │  │
│  │  Fats:           12.0g  (37.5%)                        │  │
│  │  Net Carbs:       0.0g  (0.0%)                         │  │
│  │  ────────────────────────────────────────────────────  │  │
│  │  Total Calories: 288 cal                               │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  Meal Context (Optional)                    [▼ Expand] │  │
│  ├─────────────────────────────────────────────────────────┤  │
│  │                                                          │  │
│  │  How hungry are you? (Before eating)                    │  │
│  │  ┌──────────────────────────────────────────────────┐  │  │
│  │  │ [0] [1] [2] [3] [4] [5] [6] [7] [8] [9] [10]     │  │  │
│  │  │ Extr Very Hungry Slight A Lit Neutr Slight Full Very Extr│  │  │
│  │  │ Hungry Hungry Hungry Hungry Hungry (5) Full Full Full Full│  │  │
│  │  │ (0)  (1)  (2)   (3)   (4)        (6)  (7) (8) (9)(10)│  │  │
│  │  └──────────────────────────────────────────────────┘  │  │
│  │  Selected: 2/10 (Hungry)                                  │  │
│  │                                                          │  │
│  │  ────────────────────────────────────────────────────  │  │
│  │                                                          │  │
│  │  How full are you now? (After eating)                   │  │
│  │  ┌──────────────────────────────────────────────────┐  │  │
│  │  │ [0] [1] [2] [3] [4] [5] [6] [7] [8] [9] [10]     │  │  │
│  │  │ Extr Very Hungry Slight A Lit Neutr Slight Full Very Extr│  │  │
│  │  │ Hungry Hungry Hungry Hungry Hungry (5) Full Full Full Full│  │  │
│  │  │ (0)  (1)  (2)   (3)   (4)        (6)  (7) (8) (9)(10)│  │  │
│  │  └──────────────────────────────────────────────────┘  │  │
│  │  Selected: 7/10 (Full)                                    │  │
│  │  Measured: 15 minutes after eating                       │  │
│  │                                                          │  │
│  │  ────────────────────────────────────────────────────  │  │
│  │                                                          │  │
│  │  Why are you eating? (Select all that apply)            │  │
│  │                                                          │  │
│  │  Physical:                                              │  │
│  │  [🍽️ Hungry] [😴 Tired] [⏰ Time to Eat]              │  │
│  │                                                          │  │
│  │  Emotional:                                             │  │
│  │  [😰 Stressed] [😑 Bored] [🍫 Craving]                 │  │
│  │                                                          │  │
│  │  Social:                                                 │  │
│  │  [🎉 Celebration] [👥 Social]                          │  │
│  │                                                          │  │
│  │  Selected: 🍽️ Hungry, ⏰ Time to Eat                   │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │                    [Save Meal]                           │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Alternative Compact Layout** (for smaller screens or collapsed view):

```
┌─────────────────────────────────────────────────────────┐
│  Meal Context (Optional)                    [▼ Expand] │
├─────────────────────────────────────────────────────────┤
│  Hunger Before: [0] [1] [2] [3] [4] [5] [6] [7] [8] [9] [10]│
│  Selected: 2/10 (Hungry)                                │
│                                                          │
│  Fullness After: [0] [1] [2] [3] [4] [5] [6] [7] [8] [9] [10]│
│  Selected: 7/10 (Full)                                  │
│                                                          │
│  Why eating?                                             │
│  [🍽️ Hungry] [😰 Stressed] [🎉 Celebration] [😑 Bored]│
│  [😴 Tired] [⏰ Time to Eat] [👥 Social] [🍫 Craving]   │
└─────────────────────────────────────────────────────────┘
```

**Meal Detail Page Layout** (showing logged data):

```
┌─────────────────────────────────────────────────────────┐
│  Meal Details                              [✏️ Edit]    │
├─────────────────────────────────────────────────────────┤
│  Grilled Chicken Breast                                  │
│  Breakfast • Jan 2, 2025 at 8:30 AM                     │
│                                                          │
│  ┌───────────────────────────────────────────────────┐ │
│  │  Nutrition Information                             │ │
│  │  288 cal • 45.0g P • 12.0g F • 0.0g C            │ │
│  └───────────────────────────────────────────────────┘ │
│                                                          │
│  ┌───────────────────────────────────────────────────┐ │
│  │  Meal Context                                      │ │
│  │                                                    │ │
│  │  Hunger/Fullness:                                    │ │
│  │  Before: Hungry (2/10)                            │ │
│  │  After: Full (7/10)                               │ │
│  │  Measured: 15 minutes after eating                │ │
│  │                                                    │ │
│  │  Eating Reasons:                                  │ │
│  │  [🍽️ Hungry] [⏰ Time to Eat]                     │ │
│  │                                                    │ │
│  │  [Update Fullness After]                          │ │
│  └───────────────────────────────────────────────────┘ │
│                                                          │
│  [Delete Meal]                                           │
└─────────────────────────────────────────────────────────┘
```

**Meal Card Compact View** (in meal list):

```
┌─────────────────────────────────────────────────────────┐
│  Grilled Chicken Breast                    [2,7] 🍽️⏰  │
│  Breakfast • 288 cal • 45.0g P • 12.0g F • 0.0g C     │
│  Jan 2, 2025 at 8:30 AM                                 │
└─────────────────────────────────────────────────────────┘
  └─ Before: 2/10, After: 7/10  └─ Eating reasons icons
```

**Design Notes:**
- Hunger/Fullness scales use segmented buttons (0-10) with labels below
- Scale range: 0 = Extremely hungry, 5 = Neutral, 10 = Extremely full
- Include visual calibration aid: faces, colors, or examples for each scale point
- Selected values are highlighted and shown with descriptive text
- Eating reasons use FilterChip widgets with icons and text
- Categories are grouped with section headers for clarity
- All fields are optional - user can skip any or all
- Section can be collapsed/expanded to reduce visual clutter
- Touch targets meet 48x48dp minimum for accessibility
- "Before" scale measures hunger level (typically 0-4 before eating, but allow any 0-10)
- "After" scale measures fullness level (typically 6-10 after eating, but allow any 0-10)
- Store timestamp for "after" measurement to track when it was logged
- Handle edge cases gracefully (after < before, same values, extreme values)

### Business Logic
- Hunger/Fullness scale validation:
  - If provided, both `hungerLevelBefore` and `hungerLevelAfter` must be integers between 0-10
  - If not provided, store as null (optional fields)
  - User can log before only, after only, or both
  - Don't assume ranges - allow any valid combination (0-10 for both)
  - Handle edge cases gracefully:
    - After < before: Flag for user review with context, not as error (may be valid: delayed satiety, meal didn't satisfy)
    - Same value before/after: Display as "No change" with context
    - After = before = 0: User was extremely hungry before and after (meal didn't help)
    - After = before = 10: User was extremely full before and after (unusual but possible)
- Hunger/Satiety scale labels (0 = extreme hunger, 10 = extreme fullness, 5 = neutral):
  - 0: "Extremely hungry" (Severe hunger, urgent need to eat, feeling weak/dizzy)
  - 1: "Very hungry" (Strong hunger, need to eat soon)
  - 2: "Hungry" (Moderate hunger, ready to eat)
  - 3: "Slightly hungry" (Mild hunger, could eat)
  - 4: "A little hungry" (Very mild hunger, not urgent)
  - 5: "Neutral" (Comfortable, neither hungry nor full - ideal neutral point)
  - 6: "Slightly full" (Mild fullness, satisfied)
  - 7: "Full" (Moderate fullness, comfortably satisfied)
  - 8: "Very full" (Strong fullness, approaching uncomfortable)
  - 9: "Extremely full" (Severe fullness, uncomfortable)
  - 10: "Extremely full" (Overfull, feeling unwell from overeating)
- Visual calibration aid:
  - Provide examples for each scale point: "0 = I'm so hungry I feel weak"
  - Consider visual aids: faces, colors, or progress indicators
  - Allow user calibration (optional one-time setup: "What does 5 feel like for you?")
- Scale interpretation: Lower numbers (0-4) = hungry, Higher numbers (6-10) = full, 5 = neutral
- Eating reasons validation:
  - If provided, must be list of valid `EatingReason` enum values (empty list is valid - user explicitly chose none)
  - If not provided, store as null (not answered)
  - Distinguish between null (not answered) and empty list (answered: none)
  - Allow multiple selections (user can select multiple reasons)
  - Store as List<String> (enum names) for better data integrity and debugging
- Eating reason categories and labels:
  - **Physical**: Hungry, Tired, Scheduled (Time to Eat)
  - **Emotional**: Stressed, Bored, Craving (optional)
  - **Social**: Celebration, Social (optional)
- Eating reason display names:
  - `hungry`: "Hungry" (description: "Physical hunger")
  - `stressed`: "Stressed" (description: "Eating due to stress")
  - `celebration`: "Celebration" (description: "Celebrating or special occasion")
  - `bored`: "Bored" (description: "Eating out of boredom")
  - `tired`: "Tired" (description: "Eating due to fatigue")
  - `scheduled`: "Time to Eat" (description: "Scheduled meal time")

### Error Handling
- Validate both hunger level ranges (0-10) if provided
- Validate eating reasons list contains valid enum values if provided (empty list is valid)
- Handle null/empty values gracefully (existing meals won't have these fields)
- Ensure backward compatibility with existing meal data
- Handle enum serialization/deserialization errors for eating reasons (use string-based storage)
- Handle cases where only before or only after is logged (both are independent)
- Handle unusual patterns gracefully:
  - After < before: Flag for user review with helpful context, not as error
  - Extreme values: Provide context (e.g., "You were extremely hungry (0) - did the meal help?")
- Data quality indicators:
  - Track data completeness for insights (e.g., "Based on 45% of meals with complete data")
  - Weight insights by data quality
  - Show confidence levels for pattern detection

## Reference Documents

- `artifacts/phase-2-features/nutrition-module-specification.md` - Nutrition Module Specification
- `artifacts/phase-1-foundations/data-models.md` - Meal and Nutrition Data Models
- `artifacts/requirements.md` - Behavioral Support Requirements (hunger tracking)

## Technical References

- Entity: `lib/features/nutrition_management/domain/entities/meal.dart`
- New Entity: `lib/features/nutrition_management/domain/entities/eating_reason.dart`
- Model: `lib/features/nutrition_management/data/models/meal_model.dart`
- Use Case: `lib/features/nutrition_management/domain/usecases/log_meal.dart`
- Page: `lib/features/nutrition_management/presentation/pages/meal_logging_page.dart`
- Repository: `lib/features/nutrition_management/domain/repositories/nutrition_repository.dart`
- Data Source: `lib/features/nutrition_management/data/datasources/local/nutrition_local_datasource.dart`
- Reference: `lib/features/nutrition_management/domain/entities/meal_type.dart` (for enum pattern)

## Dependencies

- `EatingReason` enum must be created first
- `Meal` entity must be updated to include all four fields (hungerLevelBefore, hungerLevelAfter, fullnessAfterTimestamp, eatingReasons)
- `MealModel` (Hive model) must be updated to include all four fields
- Hive database migration may be needed (if schema changes require it)
- `LogMealUseCase` must support hunger levels (before and after), timestamp, and eating reasons parameters
- `UpdateMealUseCase` should support updating hunger levels and timestamp after meal is logged
- Meal logging page must be functional
- Enum serialization/deserialization must be implemented for Hive storage (use string-based storage for robustness)

## Notes

- Both hunger scales (before and after) and eating reasons are optional - users can skip them if they don't want to log behavioral context
- Users can log hunger before only, after only, or both
- "Fullness After" can be logged immediately after saving the meal, or updated later on the meal detail page
- This feature supports future behavioral analysis features (post-MVP)
- Combined data can be used for powerful insights:
  - **Hunger scale insights**:
    - "You tend to eat more calories when hunger level before is 7+" (with data quality indicator)
    - "You logged meals with high hunger levels before eating 3 days in a row" (pattern, not cause)
    - "Average hunger level before breakfast: 2.5" (based on 60% of breakfast meals with data)
    - "Average fullness level after meals: 7.2" (based on meals with complete data)
    - "Meals with higher protein tend to result in higher fullness levels after eating"
    - "You often still feel hungry (fullness after < 5) after meals with < 30g protein" (correlation, not causation)
    - "High-protein meals (40g+) consistently result in higher fullness levels"
  - **Eating reasons insights**:
    - "You eat when stressed 3+ times per week"
    - "Meals logged as 'Stressed' average 450 more calories than meals logged as 'Hungry'"
    - "You tend to eat when tired in the evenings"
    - "Stress eating increased 40% this week"
    - "Celebration meals are 30% higher in calories"
  - **Combined insights**:
    - "When you're stressed and hunger level before is low (0-2), you consume 600+ calories" (pattern, not medical advice)
    - "High hunger before (7-10) + 'Hungry' reason = normal calorie intake, but high hunger + 'Bored' = 200+ extra calories" (correlation analysis)
    - "Meals logged as 'Stressed' result in lower average fullness levels compared to 'Hungry' meals"
    - "Celebration meals result in lower average fullness levels compared to regular meals"
- Consider adding behavioral context visualization in future analytics features
- Both features can help users practice mindful eating and identify emotional eating patterns
- UI should be intuitive:
  - Hunger scale: slider with visual labels or segmented buttons
  - Eating reasons: chip-based multi-select grouped by category
- Ensure accessibility: screen reader support, proper touch targets (48x48dp minimum for chips)
- Consider adding both features to meal editing (if user wants to add them later)
- Eating reasons support multiple selections to capture complex scenarios (e.g., "Stressed" + "Tired")
- Grouping eating reasons by category helps users understand the nature of their eating triggers

## Design Decisions

- **Optional Fields**: Both hunger levels (before and after) and eating reasons are optional to reduce friction in meal logging
- **0-10 Scale**: Standard hunger/fullness scale used in nutrition and behavioral health apps (0 = extreme hunger, 5 = neutral, 10 = extreme fullness)
- **Before and After Tracking**: Log hunger both before and after eating to track satiety and meal effectiveness
- **Flexible Logging**: User can log hunger before only, after only, or both (allows for different logging workflows)
- **Post-Meal Update**: Allow user to update "Fullness After" on meal detail page if not logged initially
- **Multi-Select for Eating Reasons**: Allow multiple selections to capture complex scenarios (e.g., user is both stressed and tired)
- **Categorized Eating Reasons**: Group by Physical, Emotional, Social to help users understand eating triggers
- **Visual Representation**:
  - Hunger scales: segmented buttons or slider for easy selection
  - Eating reasons: chip-based multi-select for intuitive selection
- **Storage**:
  - Hunger levels: nullable ints in Meal entity and Hive model (hungerLevelBefore, hungerLevelAfter, 0-10 range)
  - Timestamp: nullable DateTime for fullnessAfterTimestamp to track when "after" was measured
  - Eating reasons: nullable List<EatingReason> in entity, stored as List<String> (enum names) in Hive model for better data integrity
- **Display**: Show both hunger levels and eating reasons on meal detail page and optionally on meal cards
- **Backward Compatibility**: Existing meals will have null values for all four fields (graceful handling)
- **Data Quality**: Track completeness and weight insights accordingly
- **Edge Cases**: Allow any valid combination of before and after values (0-10 for both)
- **Placement**: Group all features in "Meal Context" section after meal totals, before save button
- **Integration**: All features work independently - user can log any combination of hunger before, fullness after, and eating reasons
- **Enum Pattern**: Follow same pattern as `MealType` enum for consistency

## Implementation Notes

**Completed**: 2025-01-03

### Implementation Details
- Created `EatingReason` enum with 8 values: hungry, stressed, celebration, bored, tired, scheduled, social, craving
- Created `EatingReasonCategory` enum with 3 categories: physical, emotional, social
- Updated `Meal` entity to include optional fields:
  - `hungerLevelBefore` (int?, 0-10)
  - `hungerLevelAfter` (int?, 0-10)
  - `fullnessAfterTimestamp` (DateTime?)
  - `eatingReasons` (List<EatingReason>?)
- Updated `MealModel` (Hive) with new `@HiveField` annotations for persistence
- Updated `LogMealUseCase` to accept and validate new behavioral tracking parameters
- Created `HungerScaleWidget` as reusable slider component:
  - Uses `Slider` widget for intuitive selection (0-10 scale)
  - Displays descriptive labels (e.g., "7/10 - Full")
  - Includes "Clear" button to reset value
  - Uses neutral theme colors (no color coding for hunger/fullness)
- Created `EatingReasonsWidget` as reusable multi-select component:
  - Displays `FilterChip` widgets grouped by category
  - Shows icons and display names for each reason
  - Supports multi-selection
- Updated `MealLoggingPage`:
  - Added "Meal Context (Optional)" section
  - Integrated `HungerScaleWidget` for "Hunger Before" and "Fullness After"
  - Integrated `EatingReasonsWidget` for "Why are you eating?"
  - Passes behavioral data to `LogMealUseCase`
- Updated `MealDetailPage` to display behavioral data if available
- Updated `MealCardWidget` to optionally show compact behavioral indicators
- Auto-sets `fullnessAfterTimestamp` to `DateTime.now()` if `hungerLevelAfter` provided but timestamp is null

### Technical Changes
- **New Files Created**:
  - `lib/features/nutrition_management/domain/entities/eating_reason.dart`
  - `lib/features/nutrition_management/domain/entities/eating_reason_category.dart`
  - `lib/features/nutrition_management/presentation/widgets/hunger_scale_widget.dart`
  - `lib/features/nutrition_management/presentation/widgets/eating_reasons_widget.dart`
- **Files Modified**:
  - `lib/features/nutrition_management/domain/entities/meal.dart` - added behavioral tracking fields
  - `lib/features/nutrition_management/data/models/meal_model.dart` - added Hive fields
  - `lib/features/nutrition_management/domain/usecases/log_meal.dart` - added parameters and validation
  - `lib/features/nutrition_management/presentation/pages/meal_logging_page.dart` - integrated widgets
  - `lib/features/nutrition_management/presentation/pages/meal_detail_page.dart` - display behavioral data
  - `lib/features/nutrition_management/presentation/widgets/meal_card_widget.dart` - optional display

### Testing
- Unit tests completed for `LogMealUseCase` with new behavioral tracking parameters
- Manual testing completed - all features verified and working correctly

### User Feedback Addressed
- Changed hunger scale from segmented buttons to slider per user request
- Removed color coding for hunger/fullness levels, using neutral theme colors
- Slider provides more intuitive selection experience

## History

- 2025-01-02 - Created based on user request for hunger scale when logging food
- 2025-01-02 - Updated to include eating reasons (WHY) feature based on user request
- 2025-01-02 - Updated to track hunger both before and after eating for satiety tracking
- 2025-01-02 - Updated scale from 1-10 to 0-10 (0 = extremely hungry, 5 = neutral, 10 = extremely full)
- 2025-01-02 - Added improvements based on business logic critique:
  - Added timestamp tracking for "after" measurement
  - Changed eating reasons storage from enum indices to strings for better data integrity
  - Added distinction between null (not answered) and empty list (explicitly no reasons)
  - Added edge case handling (after < before, same values, extreme values)
  - Added data quality indicators for insights
  - Framed insights as patterns/correlations, not causes
  - Added visual calibration aid for scale interpretation
  - Removed assumptions about typical ranges (allow any 0-10 combination)
- 2025-01-03 - Completed - All acceptance criteria met, implementation verified

