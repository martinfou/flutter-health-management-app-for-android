# Feature Request: FR-028 - Log Meal Page Redesign (3 Design Proposals)

**Status**: ⏳ In Progress  
**Priority**: 🟠 High  
**Story Points**: 8 (design + 1 proposal implementation; remaining proposals in follow-up)  
**Created**: 2026-02-09  
**Updated**: 2026-02-09  
**Assigned Sprint**: Backlog

## Description

The current Log Meal page (`MealLoggingPage`) is not user-friendly: it presents meal type, food entry (search, barcode, manual, recipes), hunger scale, eating reasons, and save in one long scroll with multiple dialogs. Users report cognitive overload, unclear flow, and friction when logging quickly. This feature request asks for a **design phase** that produces **3 concrete redesign proposals**. After review, one proposal (or a hybrid) will be selected for implementation.

**Current pain points** (to be addressed by proposals):

- Single long page with many sections and dialogs; no clear "path" for quick vs. detailed logging.
- Add-food entry points (search, barcode, manual, recipe) are grouped in one card; hierarchy and discoverability are weak.
- Hunger scale and eating reasons add length and can feel mandatory even when users want to log quickly.
- Meal type selector competes for attention with the rest of the content; relationship to "what I'm adding" is unclear.
- No persistent visibility of running macro/calorie totals while adding items (totals appear in one card lower on the page).
- **No way to log how much food** the user is tracking; quantity and unit (e.g. grams, ml, oz) are not supported, so macros/calories cannot be scaled to the actual portion.

**Deliverable**: A design document (or section in this FR) that describes **3 distinct redesign proposals** with rationale, **ASCII wireframes** for each key screen/state, and recommended user flow. Implementation of the chosen design is a separate development effort (this FR covers design + one implementation; further implementations can be new FRs or backlog items).

### Quantity and multi-unit support (in scope)

Users must be able to specify **how much** of each food they are logging. The app will support **multiple units** and calculate macros and calories from the quantity and unit:

- **Grams (g)** – primary; nutritional data from Open Food Facts is per 100g, so scaling is direct.
- **Milliliters (ml)** – for liquids (e.g. milk, oil). When the data source provides per-100ml (e.g. OFF for some beverages), use it; otherwise convert via density or default to 1 g/ml where appropriate.
- **Ounces (oz)** – 1 oz ≈ 28.35 g; convert to grams then scale nutrition.

For each logged item (from search, barcode, or manual entry), the user selects a **quantity** (number) and a **unit** (g, ml, oz). The app computes protein, fats, net carbs, and calories for that amount and adds the item to the meal with those values. **Web service note**: Open Food Facts typically provides nutrition **per 100g**; some products (e.g. beverages) may also have per-100ml. The implementation should use per-100g as the canonical base and, when available, use per-100ml for ml-based entries to improve accuracy for liquids. All units are normalized to an equivalent mass (grams) for scaling.

## User Story

As a **user who logs meals daily**,  
I want **a clearer, more intuitive Log Meal screen where I can choose how much of each food I ate (quantity + unit)**,  
so that **I can log meals quickly when in a hurry, track accurate portions (e.g. 50 g, 200 ml, 2 oz), and still add details (hunger, reasons, multiple items) when I want to**.

## Acceptance Criteria

### Design phase

- [x] **Proposal A** is documented with: problem focus, user flow (steps/screens or key interactions), layout concept (e.g. wizard, tabs, bottom sheet), **ASCII wireframes** for each key screen/state, and how it addresses current pain points.
- [x] **Proposal B** is documented with the same structure and a clearly different approach from A, including **ASCII wireframes**.
- [x] **Proposal C** is documented with the same structure and a clearly different approach from A and B, including **ASCII wireframes**.
- [x] Each proposal states trade-offs (e.g. taps vs. clarity, speed vs. detail).
- [x] A short recommendation or comparison matrix supports prioritization (e.g. best for "quick log", best for "detailed log", best for "discoverability").

### Implementation (after design selection)

- [ ] Selected proposal (or agreed hybrid) is implemented for the Log Meal page.
- [ ] All existing behaviors are preserved: meal type, add food (search/Open Food Facts, barcode, manual, recipe), hunger scale, eating reasons, save, and macro totals.
- [ ] **Quantity and units**: For each food item, the user can enter a **quantity** (numeric) and choose a **unit**: grams (g), milliliters (ml), ounces (oz). The app calculates and stores macros and calories for that amount (scaling from per-100g or per-100ml when available).
- [ ] **Unit behavior**: Grams use nutrition per 100g directly; ml use per-100ml when provided by the data source (e.g. OFF for beverages), otherwise a sensible default (e.g. 1 g/ml or product-specific density if available); oz are converted to grams (1 oz = 28.35 g) then scaled.
- [ ] Accessibility (e.g. screen reader, touch targets) meets project standards.
- [ ] No regressions in navigation from Nutrition/Home to Log Meal and back.

## Business Value

- **User satisfaction**: Logging meals is a core, frequent action; a friendlier flow increases daily engagement and retention.
- **Efficiency**: Faster logging reduces drop-off and encourages consistent tracking, which supports nutrition and weight goals.
- **Differentiation**: A clear, modern Log Meal experience aligns with a "health management" product position and reduces perceived complexity.

## Three Design Proposals

Each proposal includes: problem focus, user flow, ASCII wireframes for key screens, how it addresses pain points, and trade-offs.

---

### Proposal A: Stepped / Wizard Flow

**Problem focus**: Single long page and competing sections cause cognitive overload. Users need a clear, linear path: one decision per step.

**User flow**:
1. **Step 1 – Meal type**: Full-screen or prominent step; choose Breakfast | Lunch | Dinner | Snack → Next.
2. **Step 2 – Add food**: List of added items (empty at first) + sticky running totals; "Add food" opens a single add-food surface (Search | Barcode | Recipe | Manual). User picks method, selects/enters food, enters **quantity + unit** (g, ml, oz); item is added. Repeat; then "Done" or "Next".
3. **Step 3 – Optional**: "How was this meal?" – Hunger scale + eating reasons; prominent "Skip" so quick loggers can bypass.
4. **Step 4 – Review & save**: Summary (meal type, items with qty/unit, totals, optional behavioral data); single "Save meal" button.

**ASCII wireframes**

```
┌─────────────────────────────────────┐
│  ← Log Meal                    [1 of 4]
├─────────────────────────────────────┤
│                                     │
│  When did you eat?                  │
│                                     │
│  ┌─────────┐ ┌─────────┐           │
│  │Breakfast│ │ Lunch   │           │
│  └─────────┘ └─────────┘           │
│  ┌─────────┐ ┌─────────┐           │
│  │ Dinner  │ │ Snack   │           │
│  └─────────┘ └─────────┘           │
│                                     │
│                                     │
│         [ Next → ]                   │
└─────────────────────────────────────┘
     Step 1 – Meal type
```

```
┌─────────────────────────────────────┐
│  ← Add food                   [2 of 4]
├─────────────────────────────────────┤
│  Meal: Lunch                        │
│  ─────────────────────────────────  │
│  Running: 12g P  8g F  22g C  198 cal
├─────────────────────────────────────┤
│  Your items:                        │
│  • Chicken breast  150g  31P 4F 0C  │
│  • Rice, white     100g  2P  0F 28C│
│                                     │
│  ┌─────────────────────────────┐   │
│  │  + Add food                 │   │
│  └─────────────────────────────┘   │
│                                     │
│         [ Next → ]                   │
└─────────────────────────────────────┘
     Step 2 – Add food (list + totals)
```

```
┌─────────────────────────────────────┐
│  Add food (method)                  │
├─────────────────────────────────────┤
│  ┌─────────┐ ┌─────────┐           │
│  │ Search  │ │ Barcode │           │
│  └─────────┘ └─────────┘           │
│  ┌─────────┐ ┌─────────┐           │
│  │ Recipe  │ │ Manual  │           │
│  └─────────┘ └─────────┘           │
├─────────────────────────────────────┤
│  (after pick: search field or        │
│   barcode camera or recipe list     │
│   or manual fields)                 │
│  Quantity: [____] [g ▼]             │
│  [ Add to meal ]                    │
└─────────────────────────────────────┘
     Step 2 – Add food (method + qty/unit)
```

```
┌─────────────────────────────────────┐
│  ← Review & save              [4 of 4]
├─────────────────────────────────────┤
│  Lunch                              │
│  • Chicken breast  150g  …          │
│  • Rice, white     100g  …          │
│  ─────────────────────────────────  │
│  Total: 33P  4F  28C  198 cal       │
│  (optional) Hunger: 6  Reasons: …  │
│                                     │
│         [ Save meal ]                │
└─────────────────────────────────────┘
     Step 4 – Review & save
```

**Addresses pain points**:
- Clear path for quick vs. detailed: Step 2 is the only required “work” step; Step 3 is skippable; no single long scroll.
- Add-food entry points are on a dedicated step with four clear options (Search, Barcode, Recipe, Manual).
- Hunger/reasons are one optional step with explicit Skip.
- Meal type is Step 1 only; no competition with food list.
- Running totals are visible in Step 2 while adding items.
- Quantity + unit (g, ml, oz) are part of the add-food flow; app calculates macros/calories.

**Trade-offs**:
- More steps/taps for a very quick log (at least 4 steps). Mitigation: "Quick add again" after save (same meal type + last method), or optional "Skip to add food" from Step 1 for returning users.

---

### Proposal B: Quick Log First, Details Optional

**Problem focus**: Most logs are quick; the current page is optimized for “full” logging. Prioritize one main action (add food) and keep everything else secondary or collapsible.

**User flow**:
1. Open Log Meal → see meal type chips at top and a large "Quick add" block (search bar, barcode button, recent/favorites).
2. Select meal type (optional; default e.g. to current meal context). Add food via search, barcode, or recent; for each item enter **quantity + unit** (default 100 g); item appears in list; running totals appear in a sticky bar.
3. "Add another" or repeat from quick add. Optionally expand "Add details" for hunger scale and eating reasons.
4. Tap "Save meal".

**ASCII wireframes**

```
┌─────────────────────────────────────┐
│  ← Log Meal                         │
├─────────────────────────────────────┤
│  [ Breakfast ] Lunch  Dinner  Snack │
├─────────────────────────────────────┤
│  Quick add                          │
│  ┌─────────────────────────────┐   │
│  │ 🔍 Search or scan barcode   │ 📷 │
│  └─────────────────────────────┘   │
│  Recent: Oatmeal 100g | Milk 200ml  │
├─────────────────────────────────────┤
│  Your meal                          │
│  (empty or list of items)           │
│  ─────────────────────────────────  │
│  ▼ Add details (hunger & reasons)   │
│                                     │
│         [ Save meal ]                │
└─────────────────────────────────────┘
     Proposal B – Main screen (empty or with items)
```

```
┌─────────────────────────────────────┐
│  ← Log Meal                         │
├─────────────────────────────────────┤
│  Breakfast  [ Lunch ]  Dinner  Snack │
├─────────────────────────────────────┤
│  ▓ 24g P  18g F  35g C  398 cal ▓   │  ← sticky totals
├─────────────────────────────────────┤
│  • Oatmeal  50g  6P 3F 27C 159 cal  │
│  • Milk     200ml 6P 8F 12C 122 cal │
│  • Banana   1 medium (≈120g)  …     │
│  ┌─────────────────────────────┐   │
│  │  + Add another              │   │
│  └─────────────────────────────┘   │
│  ▼ Add details (hunger & reasons)   │
│         [ Save meal ]                │
└─────────────────────────────────────┘
     Proposal B – With items + sticky totals
```

**Addresses pain points**:
- One primary path: add food first; meal type and details are secondary/collapsible.
- Quick add is the hero (search + barcode + recent); no buried card.
- Hunger/reasons behind "Add details", collapsed by default.
- Meal type is compact chips; doesn’t dominate.
- Running totals in sticky bar as soon as there’s ≥1 item.
- Quantity + unit in add flow; defaults (e.g. 100 g) speed single-item logs.

**Trade-offs**:
- Behavioral data (hunger/reasons) is less visible; may reduce capture. Mitigation: optional prompt after save ("How was this meal?") or gentle nudge to expand "Add details".

---

### Proposal C: Contextual Tabs and Bottom Sheet

**Problem focus**: Users lose context when dialogs stack. Keep meal type and running totals always on screen; contain “add food” in a bottom sheet so the main screen stays visible.

**User flow**:
1. Open Log Meal → top: meal type tabs/chips; under that, sticky totals (when items exist); then scrollable list of items; FAB or primary "Add food" button.
2. Tap "Add food" → bottom sheet opens with segments: **Search** | **Barcode** | **Recipe** | **Manual**. User picks one, completes flow (select/enter food, **quantity + unit**); sheet dismisses; new item in list; totals update.
3. Edit/remove items from list. Optionally open "How was this meal?" (expandable card or second sheet) for hunger/reasons.
4. Tap "Save meal".

**ASCII wireframes**

```
┌─────────────────────────────────────┐
│  ← Log Meal                         │
├─────────────────────────────────────┤
│  Breakfast  [ Lunch ]  Dinner Snack│
│  ─────────────────────────────────  │
│  12g P  8g F  22g C  198 cal        │
├─────────────────────────────────────┤
│  • Chicken breast  150g             │
│    31P 4F 0C 165 cal            [⋮] │
│  • Rice, white     100g             │
│    2P 0F 28C 130 cal            [⋮] │
│                                     │
│  ┌─────────────────────────────┐   │
│  │  + Add food                 │   │
│  └─────────────────────────────┘   │
│                                     │
│  ▸ How was this meal? (optional)    │
│         [ Save meal ]                │
└─────────────────────────────────────┘
     Proposal C – Main screen
```

```
┌─────────────────────────────────────┐
│  (main screen dimmed, list visible) │
├─────────────────────────────────────┤
│  ═══════════════════════════════════ │
│  Add food                            │
│  ─────────────────────────────────  │
│  [ Search ] [ Barcode ] [Recipe] [Manual]
│  ─────────────────────────────────  │
│  (content for selected tab)         │
│  e.g. Search: [____________]        │
│  Results: …                          │
│  Quantity: [____] [g ▼]  [Add]      │
│  ═══════════════════════════════════ │
└─────────────────────────────────────┘
     Proposal C – Bottom sheet (add food)
```

**Addresses pain points**:
- No single long scroll; main screen is list + totals; add flow is in a sheet.
- Add-food methods are four clear segments in the sheet (Search, Barcode, Recipe, Manual).
- Hunger/reasons are optional card/sheet, not in main flow.
- Meal type and totals always visible at top.
- Running totals sticky under meal type.
- Quantity + unit in sheet; app calculates macros/calories.

**Trade-offs**:
- Bottom sheet must feel fast (no heavy steps). Small screens: sheet height and list visibility need testing; consider half-screen sheet or full-screen modal on very small devices.

---

### Comparison matrix and recommendation

| Criteria                 | Proposal A (Wizard)   | Proposal B (Quick first) | Proposal C (Tabs + sheet) |
|--------------------------|------------------------|---------------------------|----------------------------|
| **Quick log (1 item)**   | More taps (4 steps)    | Best (minimal taps)       | Good (1 sheet)             |
| **Detailed log (many items + details)** | Best (clear steps) | Good (expand details)     | Good (sheet + list)        |
| **Discoverability**      | Best (one step = one thing) | Good (quick add prominent) | Good (sheet segments)      |
| **Context (totals/meal type)** | Per-step only in 2–4   | Sticky totals             | Always visible             |
| **Cognitive load**       | Lowest (linear steps) | Low (one main block)      | Low (contained sheet)      |
| **Implementation risk**  | Wizard state machine   | Single screen + expandable | Sheet + list sync          |

**Recommendation**:  
- Prefer **Proposal B** if the primary goal is **fast, frequent logging** and reducing drop-off; implement "Add details" with optional post-save prompt to protect behavioral data capture.  
- Prefer **Proposal A** if the primary goal is **clarity and guided flow** for all user types; add a "Quick add again" or skip-from-step-1 for power users.  
- Prefer **Proposal C** if **context (totals + meal type always visible)** is paramount and the team is comfortable tuning bottom-sheet UX on small screens.

A **hybrid** is feasible: B’s main screen (quick add + sticky totals) plus C’s bottom sheet for "Add food" (so the main screen never leaves view when adding), and A’s optional Step 3 style for "How was this meal?" as an expandable or post-save prompt.

---

## Technical Requirements

- Redesign is confined to the Log Meal screen and its dialogs/sheets. Domain may be extended to store **quantity and unit** per food item (or derived mass in grams for calculation); meal save API continues to receive computed macros/calories per item.
- **Quantity/unit**: Support units grams (g), milliliters (ml), ounces (oz). Normalize to grams for calculation: g as-is; oz → grams (× 28.35); ml → use per-100ml from data source when available (Open Food Facts SDK may expose per-100ml for some products), else convert via density or 1 g/ml default. Scale nutrition from per-100g (or per-100ml for ml when available) using the normalized amount. Existing `Product.toFoodItemData(servingSizeGrams)` already supports scaling; extend or call it with the user’s quantity converted to grams.
- Preserve integration with Open Food Facts (FR-019), recipes, barcode scanner, and existing providers (e.g. `dailyMealsProvider`, `macroSummaryProvider`).
- Follow existing architecture: feature under `nutrition_management`, existing use cases and repositories.
- Implement responsive layout for different screen sizes; bottom sheets and wizards must work on small and large phones.

## Reference Documents

- [Backlog Management Process](../docs/processes/backlog-management-process.md) – Feature request lifecycle
- [FR-005](FR-005-hunger-scale-when-logging-food.md) – Hunger scale and eating reasons when logging food (existing behavior to preserve)
- [FR-019](FR-019-open-food-facts-integration.md) – Open Food Facts integration (search/barcode on Log Meal)

## Technical References

- **Page**: `app/lib/features/nutrition_management/presentation/pages/meal_logging_page.dart` – `MealLoggingPage`
- **Use case**: `app/lib/features/nutrition_management/domain/usecases/log_meal.dart` – `LogMealUseCase`
- **Product (per-100g + scaling)**: `app/lib/features/nutrition_management/domain/entities/product.dart` – `Product.toFoodItemData(servingSizeGrams)` for scaling by quantity
- **Open Food Facts (per 100g / per 100ml)**: `app/lib/features/nutrition_management/data/datasources/remote/open_food_facts_datasource.dart` – nutriments per 100g; extend or check SDK for per-100ml when adding ml support
- **Providers**: `app/lib/features/nutrition_management/presentation/providers/nutrition_providers.dart` – e.g. `dailyMealsProvider`, `macroSummaryProvider`
- **Widgets**: `HungerScaleWidget`, `EatingReasonsWidget` – used on current Log Meal page

## Dependencies

- None for the **design phase**. Implementation depends on:
  - FR-019 (Open Food Facts) – already integrated; no change required for redesign.
  - FR-005 (Hunger scale / eating reasons) – behavior preserved; only placement/UX may change.

## Notes

- **Wireframe format**: Each of the 3 proposals must include **ASCII wireframes** (text-based layout sketches) for key screens/states so that layouts are comparable and reviewable without external tools. Optionally supplement with Figma/Miro; the required deliverable is ASCII wireframes.
- If the team prefers, one of the three proposals can be chosen and refined in a short follow-up design spike before development.
- Implementation story points (8) assume one full proposal (or hybrid) is implemented; creating the 3 proposals is part of this FR (design) and can be estimated as 2–3 points of the 8, with the rest for implementation.

## History

- 2026-02-09 - Created (design phase: 3 proposals for Log Meal page redesign)
- 2026-02-09 - Added quantity and multi-unit support (g, ml, oz); app calculates macros/calories; clarified OFF per-100g/per-100ml
- 2026-02-09 - Design deliverable: require ASCII wireframes for all 3 proposals
- 2026-02-09 - Design phase: completed all 3 proposals with ASCII wireframes, user flows, pain-point mapping, trade-offs, and comparison matrix + recommendation
