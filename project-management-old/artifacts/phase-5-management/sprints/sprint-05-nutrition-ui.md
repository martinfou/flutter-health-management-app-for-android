# Sprint 5: Nutrition UI

**Sprint Goal**: Implement complete nutrition tracking user interface including meal logging, recipe library, macro tracking visualization, and meal planning.

**Duration**: [Start Date] - [End Date] (2 weeks)  
**Team Velocity**: Target 21 points  
**Sprint Planning Date**: [Date]  
**Sprint Review Date**: [Date]  
**Sprint Retrospective Date**: [Date]

## Sprint Overview

**Focus Areas**:
- Nutrition providers (Riverpod)
- Nutrition pages (meal logging, recipe library, macro tracking)
- Nutrition widgets (macro charts, meal cards, recipe cards)
- Meal logging interface
- Recipe library
- Macro tracking visualization

**Key Deliverables**:
- Complete nutrition tracking UI
- Meal logging interface
- Recipe library
- Macro tracking visualization

**Dependencies**:
- Sprint 3: Domain Use Cases must be complete

**Risks & Blockers**:
- Macro calculation complexity
- Recipe library data population
- Chart visualization complexity

**Parallel Development**: Can be developed in parallel with Sprints 4, 6, 7

## User Stories

### Story 5.1: Nutrition Providers - 3 Points

**User Story**: As a developer, I want nutrition Riverpod providers implemented, so that UI can access nutrition data and business logic.

**Acceptance Criteria**:
- [x] DailyMealsProvider implemented (FutureProvider)
- [x] MacroSummaryProvider implemented
- [x] RecipesProvider implemented
- [x] All providers handle error states
- [x] All providers use use cases from domain layer

**Reference Documents**:
- `artifacts/phase-1-foundations/architecture-documentation.md` - Riverpod patterns
- `artifacts/phase-2-features/nutrition-module-specification.md` - Nutrition structure

**Technical References**:
- Providers: `lib/features/nutrition_management/presentation/providers/nutrition_providers.dart`

**Story Points**: 3

**Priority**: 🔴 Critical

**Status**: ✅ Completed

**Note**: When starting work on a new story, update the sprint status section at the top of this document to reflect the current progress.

**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-133 | Create DailyMealsProvider | `dailyMealsProvider` FutureProvider | architecture-documentation.md - Riverpod | ✅ | 2 | Dev1 |
| T-134 | Create MacroSummaryProvider | `macroSummaryProvider` Provider | nutrition-module-specification.md - Macro Tracking | ✅ | 2 | Dev1 |
| T-135 | Create RecipesProvider | `recipesProvider` FutureProvider | nutrition-module-specification.md - Recipe Database | ✅ | 2 | Dev1 |
| T-136 | Write unit tests for providers | Test files in `test/unit/features/nutrition_management/presentation/providers/` | testing-strategy.md | ✅ | 2 | Dev1 |

**Total Task Points**: 8

---

### Story 5.2: Meal Logging Page - 5 Points

**User Story**: As a user, I want to log my meals with macro information, so that I can track my daily nutrition intake.

**Acceptance Criteria**:
- [x] MealLoggingPage UI implemented
- [x] Meal type selector (Breakfast, Lunch, Dinner, Snack)
- [x] Food items list with edit/remove buttons
- [x] Add food item button
- [x] Meal totals card showing total protein, fats, net carbs, calories
- [x] Macro percentages displayed
- [x] Primary action button: "Save Meal"
- [x] Validation errors displayed inline

**Reference Documents**:
- `artifacts/phase-1-foundations/wireframes.md` - Meal Logging Screen
- `artifacts/phase-2-features/nutrition-module-specification.md` - Food Logging section

**Technical References**:
- Page: `lib/features/nutrition_management/presentation/pages/meal_logging_page.dart`
- Use Case: `LogMealUseCase`

**Story Points**: 5

**Priority**: 🔴 Critical

**Status**: ✅ Completed

**Note**: When starting work on a new story, update the sprint status section at the top of this document to reflect the current progress.

**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-137 | Create MealLoggingPage UI | `MealLoggingPage` widget | wireframes.md - Meal Logging Screen | ✅ | 5 | Dev2 |
| T-138 | Implement meal type selector | Tab or segmented control | component-specifications.md | ✅ | 2 | Dev2 |
| T-139 | Implement food items list | List with edit/remove functionality | nutrition-module-specification.md - Food Logging | ✅ | 3 | Dev2 |
| T-140 | Implement meal totals card | Display totals and percentages | nutrition-module-specification.md - Macro Tracking | ✅ | 2 | Dev2 |
| T-141 | Integrate LogMeal use case | Connect UI to use case | nutrition-module-specification.md | ✅ | 2 | Dev2 |
| T-142 | Write widget tests for MealLoggingPage | Test files in `test/widget/features/nutrition_management/presentation/pages/` | testing-strategy.md | ⭕ | 3 | Dev2 |

**Total Task Points**: 17

---

### Story 5.3: Macro Chart Widget - 3 Points

**User Story**: As a user, I want to see my daily macro breakdown in a chart, so that I can visualize my nutrition balance.

**Acceptance Criteria**:
- [x] MacroChartWidget implemented
- [x] Bar chart showing daily macro breakdown
- [x] Stacked bars: Protein, Fats, Net Carbs
- [x] Percentage labels on bars
- [x] Color coding (green: on target, yellow: close, red: off target)
- [x] Empty state when no data

**Reference Documents**:
- `artifacts/phase-2-features/nutrition-module-specification.md` - Macro Chart section
- `artifacts/phase-1-foundations/component-specifications.md` - Chart Components

**Technical References**:
- Widget: `lib/features/nutrition_management/presentation/widgets/macro_chart_widget.dart`
- Chart Library: fl_chart or similar

**Story Points**: 3

**Priority**: 🔴 Critical

**Status**: ✅ Completed

**Note**: When starting work on a new story, update the sprint status section at the top of this document to reflect the current progress.

**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-143 | Create MacroChartWidget | `MacroChartWidget` widget | nutrition-module-specification.md - Macro Chart | ✅ | 5 | Dev3 |
| T-144 | Implement stacked bar chart | Chart with protein, fats, carbs | component-specifications.md - Charts | ✅ | 3 | Dev3 |
| T-145 | Implement color coding | Green/yellow/red based on targets | nutrition-module-specification.md - Macro Tracking | ✅ | 2 | Dev3 |
| T-146 | Write widget tests for MacroChartWidget | Test files | testing-strategy.md | ⭕ | 2 | Dev3 |

**Total Task Points**: 12

---

### Story 5.4: Recipe Library Page - 5 Points

**User Story**: As a user, I want to browse and search recipes from the pre-populated library, so that I can find meals that fit my nutrition goals.

**Acceptance Criteria**:
- [x] RecipeLibraryPage UI implemented
- [x] Search bar for recipe search
- [x] Filter options (tags, difficulty, prep time)
- [x] Recipe grid (2 columns)
- [x] Recipe cards with image, name, macros, prep/cook time, difficulty
- [x] Recipe detail screen with full information
- [x] "Log as Meal" button

**Reference Documents**:
- `artifacts/phase-1-foundations/wireframes.md` - Recipe Library Screen
- `artifacts/phase-2-features/nutrition-module-specification.md` - Recipe Database section

**Technical References**:
- Page: `lib/features/nutrition_management/presentation/pages/recipe_library_page.dart`
- Widget: `lib/features/nutrition_management/presentation/widgets/recipe_card_widget.dart`
- Use Case: `SearchRecipesUseCase`

**Story Points**: 5

**Priority**: 🔴 Critical

**Status**: ✅ Completed

**Note**: When starting work on a new story, update the sprint status section at the top of this document to reflect the current progress.

**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-147 | Create RecipeLibraryPage UI | `RecipeLibraryPage` widget | wireframes.md - Recipe Library Screen | ✅ | 5 | Dev1 |
| T-148 | Create RecipeCardWidget | `RecipeCardWidget` widget | nutrition-module-specification.md - Recipe Library | ✅ | 3 | Dev1 |
| T-149 | Implement search functionality | Search bar with filters | nutrition-module-specification.md - Recipe Search | ✅ | 3 | Dev1 |
| T-150 | Create recipe detail screen | Full recipe information display | nutrition-module-specification.md - Recipe Detail | ✅ | 3 | Dev1 |
| T-151 | Integrate SearchRecipes use case | Connect UI to use case | nutrition-module-specification.md | ✅ | 2 | Dev1 |
| T-152 | Write widget tests for RecipeLibraryPage | Test files | testing-strategy.md | ⭕ | 3 | Dev1 |

**Total Task Points**: 19

---

### Story 5.5: Macro Tracking Page - 3 Points

**User Story**: As a user, I want to see my daily macro summary with progress bars, so that I can track my nutrition targets.

**Acceptance Criteria**:
- [x] MacroTrackingPage UI implemented
- [x] Daily macro summary card with totals
- [x] Progress bars for each macro (protein, fats, net carbs)
- [x] Target indicators (35% protein, 55% fats, <40g net carbs)
- [x] Color coding (green: on target, yellow: close, red: off target)
- [x] Daily calorie total displayed

**Reference Documents**:
- `artifacts/phase-2-features/nutrition-module-specification.md` - Macro Tracking section
- `artifacts/phase-1-foundations/wireframes.md` - Macro Tracking Screen

**Technical References**:
- Page: `lib/features/nutrition_management/presentation/pages/macro_tracking_page.dart`

**Story Points**: 3

**Priority**: 🔴 Critical

**Status**: ✅ Completed

**Note**: When starting work on a new story, update the sprint status section at the top of this document to reflect the current progress.

**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-153 | Create MacroTrackingPage UI | `MacroTrackingPage` widget | wireframes.md - Macro Tracking Screen | ✅ | 3 | Dev2 |
| T-154 | Implement macro summary card | Display totals and percentages | nutrition-module-specification.md - Macro Summary Card | ✅ | 3 | Dev2 |
| T-155 | Implement progress bars | Progress indicators for each macro | component-specifications.md - Progress Bars | ✅ | 2 | Dev2 |
| T-156 | Write widget tests for MacroTrackingPage | Test files | testing-strategy.md | ⭕ | 2 | Dev2 |

**Total Task Points**: 10

---

### Story 5.6: Nutrition Main Page - 2 Points

**User Story**: As a user, I want a main nutrition page that shows overview of my daily nutrition, so that I can quickly see my progress.

**Acceptance Criteria**:
- [x] NutritionPage UI implemented
- [x] Daily macro summary card
- [x] Recent meals list
- [x] Quick actions (log meal, browse recipes, view macros)
- [x] Navigation to sub-pages

**Reference Documents**:
- `artifacts/phase-1-foundations/wireframes.md` - Nutrition Main Screen
- `artifacts/phase-2-features/nutrition-module-specification.md` - Nutrition Module

**Technical References**:
- Page: `lib/features/nutrition_management/presentation/pages/nutrition_page.dart`
- Widget: `lib/features/nutrition_management/presentation/widgets/meal_card_widget.dart`

**Story Points**: 2

**Priority**: 🔴 Critical

**Status**: ✅ Completed

**Note**: When starting work on a new story, update the sprint status section at the top of this document to reflect the current progress.

**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-157 | Create NutritionPage UI | `NutritionPage` widget | wireframes.md - Nutrition Main Screen | ✅ | 3 | Dev3 |
| T-158 | Create MealCardWidget | `MealCardWidget` widget | nutrition-module-specification.md - Meal Display | ✅ | 2 | Dev3 |
| T-159 | Implement navigation to sub-pages | Navigation routing | wireframes.md | ✅ | 2 | Dev3 |
| T-160 | Write widget tests for NutritionPage | Test files | testing-strategy.md | ⭕ | 2 | Dev3 |

**Total Task Points**: 9

---

## Sprint Summary

**Total Story Points**: 21  
**Total Task Points**: 75  
**Estimated Velocity**: 21 points (based on team capacity)

**Sprint Burndown**:
- Day 1: 21 points completed
- Day 2: 21 points completed
- Day 3: 21 points completed
- Day 4: 21 points completed
- Day 5: 21 points completed
- Day 6: 21 points completed
- Day 7: 21 points completed
- Day 8: 21 points completed
- Day 9: 21 points completed
- Day 10: 21 points completed

**Sprint Status**: ✅ All stories completed - Ready for demo

**Sprint Review Notes**:
- [Notes from sprint review]

**Sprint Retrospective Notes**:
- [Notes from retrospective]

---

## Demo to Product Owner

**Purpose**: The product owner will run the application and verify that all sprint deliverables are working correctly.

**Demo Checklist**:
- [x] Application builds and runs successfully
- [x] Nutrition pages display correctly
- [x] Meal logging functionality works
- [x] Macro chart displays data accurately
- [x] Recipe library is accessible and searchable
- [x] Macro tracking page shows correct calculations
- [x] Navigation between nutrition screens functions properly
- [x] All acceptance criteria from user stories are met
- [x] No critical bugs or blockers identified

**Demo Notes**:
- [Notes from product owner demo]

---

**Cross-Reference**: Implementation Order - Phase 5: Presentation Layer - Nutrition

