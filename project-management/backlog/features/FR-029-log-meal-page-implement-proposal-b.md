# Feature Request: FR-029 - Log Meal Page Implement Proposal B (Quick Log First)

**Status**: ⏳ In Progress  
**Priority**: 🟠 High  
**Story Points**: 8  
**Created**: 2026-02-09  
**Updated**: 2026-02-09  
**Assigned Sprint**: Backlog

## Description

Implement **Proposal B** from [FR-028](FR-028-log-meal-page-redesign-proposals.md): the "Quick Log First, Details Optional" redesign of the Log Meal page. The goal is to optimize for fast, frequent logging by making "add food" the primary action and keeping meal type compact and hunger/eating reasons behind an expandable "Add details" section.

**Design source**: [FR-028 – Log Meal Page Redesign (3 Design Proposals)](FR-028-log-meal-page-redesign-proposals.md), section "Proposal B: Quick Log First, Details Optional".

**Key layout and behavior**:
- **Top**: Meal type as compact chips (Breakfast | Lunch | Dinner | Snack); default to current meal context when possible.
- **Quick add block**: Prominent search bar with barcode-scan action; optional "Recent" row (recently logged foods with quick-add quantity, e.g. Oatmeal 100g, Milk 200ml).
- **Your meal**: List of added items (each with name, quantity + unit, and computed macros/calories); editable/removable.
- **Sticky totals bar**: Visible as soon as ≥1 item is added (e.g. "24g P  18g F  35g C  398 cal").
- **Add another**: Clear control to add more items (reuses quick add or add-food flow).
- **Add details**: Expandable section (collapsed by default) containing hunger scale and eating reasons (existing widgets); optional post-save prompt "How was this meal?" to encourage behavioral data capture.
- **Save meal**: Primary button to save; all existing save behavior (meal type, items, optional hunger/reasons, macro totals) preserved.

**Quantity and units (in scope)**: For each food item, the user enters a **quantity** (number) and selects a **unit** (g, ml, oz). The app calculates and displays macros and calories for that amount (scaling from per-100g or per-100ml when available from the data source). Default quantity/unit for quick add (e.g. 100 g) to speed single-item logs.

## User Story

As a **user who logs meals daily**,  
I want **a Log Meal screen that puts adding food first with a quick-add bar and sticky totals**,  
so that **I can log meals in minimal taps and still add hunger/reasons when I choose via "Add details"**.

## Acceptance Criteria

### Layout and flow
- [ ] Log Meal page uses Proposal B layout: meal type chips at top, then Quick add block (search + barcode; optional Recent), then "Your meal" list, then expandable "Add details", then "Save meal".
- [ ] Meal type selector is compact (e.g. horizontal chips); default selection respects current time/context when reasonable (e.g. morning → Breakfast).
- [ ] Quick add: search field and barcode button are the primary entry; tapping search focuses field and shows autocomplete (Open Food Facts + local); tapping barcode opens scanner. Optional: "Recent" row with recently logged items and default quantity for one-tap add.
- [ ] "Your meal" lists all added items; each item shows name, quantity + unit, and computed macros/calories; items are editable (quantity/unit, or full edit) and removable.
- [ ] Sticky totals bar appears when there is ≥1 item; shows total P, F, net C, and calories; remains visible (sticky) while scrolling the list.
- [ ] "Add another" (or equivalent) allows adding more items without leaving the page (reuses same add flow).
- [ ] "Add details" is an expandable section (collapsed by default) containing existing hunger scale and eating-reasons widgets.
- [ ] "Save meal" persists meal with meal type, all items (with computed macros/calories), and optional hunger/reasons; invalidates daily meals and macro summary providers; shows success feedback.

### Quantity and units
- [ ] For each food item, user can enter **quantity** (numeric) and choose **unit**: grams (g), milliliters (ml), ounces (oz). App calculates and displays macros and calories for that amount.
- [ ] Grams use nutrition per 100g; ml use per-100ml when provided by data source (e.g. OFF for beverages), otherwise sensible default (e.g. 1 g/ml); oz converted to grams (1 oz = 28.35 g) then scaled.
- [ ] Default quantity/unit in add flow (e.g. 100 g) to support fast single-item logs.

### Preservation and quality
- [ ] All existing behaviors preserved: meal type, add food via Search (Open Food Facts), Barcode, Recipe, Manual; hunger scale; eating reasons; save; macro totals.
- [ ] Accessibility: screen reader labels, minimum touch targets (48dp), semantic structure per project standards.
- [ ] No regressions: navigation from Nutrition/Home to Log Meal and back works as before.

### Optional enhancement
- [ ] After save, optional prompt "How was this meal?" (snackbar or small dialog) with shortcut to log hunger/reasons for the just-saved meal, to improve behavioral data capture.

## Business Value

- **Faster logging**: Reduces friction for the most common case (quick log), improving daily engagement and retention.
- **Clear hierarchy**: One primary action (add food) and secondary/collapsible details, reducing cognitive load.
- **Accurate portions**: Quantity + unit (g, ml, oz) with app-calculated macros supports better nutrition tracking and weight goals.

## Technical Requirements

- Replace or refactor current `MealLoggingPage` to implement Proposal B layout and flow; keep feature under `nutrition_management`, existing use cases and repositories.
- **Quantity/unit**: Extend or add model/UI for quantity + unit per item; normalize to grams for calculation; use `Product.toFoodItemData(servingSizeGrams)` (or equivalent) for scaling; extend Open Food Facts usage for per-100ml when available for ml.
- Preserve integration with Open Food Facts (FR-019), recipes, barcode scanner, `dailyMealsProvider`, `macroSummaryProvider`, `LogMealUseCase`, and hunger/eating-reasons widgets.
- Sticky totals: implement with a sticky header/sliver or pinned widget so totals stay visible when list scrolls.
- Responsive: layout works on small and large phones; expandable "Add details" and list remain usable.

## Reference Documents

- [FR-028](FR-028-log-meal-page-redesign-proposals.md) – Log Meal Page Redesign (3 Design Proposals); **Proposal B** section and ASCII wireframes
- [Backlog Management Process](../docs/processes/backlog-management-process.md) – Feature request lifecycle
- [FR-005](FR-005-hunger-scale-when-logging-food.md) – Hunger scale and eating reasons (preserve behavior)
- [FR-019](FR-019-open-food-facts-integration.md) – Open Food Facts integration (search/barcode)

## Technical References

- **Page**: `app/lib/features/nutrition_management/presentation/pages/meal_logging_page.dart` – `MealLoggingPage` (replace/refactor)
- **Use case**: `app/lib/features/nutrition_management/domain/usecases/log_meal.dart` – `LogMealUseCase`
- **Product scaling**: `app/lib/features/nutrition_management/domain/entities/product.dart` – `Product.toFoodItemData(servingSizeGrams)`
- **Providers**: `app/lib/features/nutrition_management/presentation/providers/nutrition_providers.dart` – `dailyMealsProvider`, `macroSummaryProvider`
- **Widgets**: `HungerScaleWidget`, `EatingReasonsWidget` – reuse in "Add details" section

## Dependencies

- FR-028 (design) – design phase complete; Proposal B selected.
- FR-019 (Open Food Facts) – already integrated; no change required for layout; quantity/unit scaling may use existing per-100g and optional per-100ml.
- FR-005 (Hunger scale / eating reasons) – behavior preserved; placement is "Add details" expandable section.

## Notes

- "Recent" foods for quick add can be a follow-up story if not in initial scope; prioritize layout, sticky totals, quantity/unit, and expandable details.
- Optional post-save "How was this meal?" prompt is recommended to mitigate lower visibility of behavioral data (see FR-028 trade-offs).

## History

- 2026-02-09 - Created; implement Proposal B from FR-028 (Quick Log First, Details Optional)
- 2026-02-09 - Implementation started: Proposal B layout (meal type chips, quick add, sticky totals, expandable Add details), FoodItem quantity/unit (g, ml, oz), add-food dialog quantity/unit and scaling from Product, default meal type by time
