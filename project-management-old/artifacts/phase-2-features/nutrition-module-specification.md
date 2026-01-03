# Nutrition Module Specification

## Overview

The Nutrition Module provides comprehensive nutrition tracking including macro tracking, food logging, meal planning with manual sale entry, and recipe database management. The module includes a pre-populated recipe library and supports manual entry of sale items for cost-effective meal planning.

**Reference**: 
- Architecture: `artifacts/phase-1-foundations/architecture-documentation.md`
- Data Models: `artifacts/phase-1-foundations/data-models.md`
- Health Domain: `artifacts/phase-1-foundations/health-domain-specifications.md`

## Module Structure

```
lib/features/nutrition_management/
├── data/
│   ├── models/
│   │   ├── meal_model.dart
│   │   ├── recipe_model.dart
│   │   ├── meal_plan_model.dart
│   │   ├── shopping_list_item_model.dart
│   │   └── sale_item_model.dart
│   ├── repositories/
│   │   └── nutrition_repository_impl.dart
│   └── datasources/
│       └── local/
│           └── nutrition_local_datasource.dart
├── domain/
│   ├── entities/
│   │   ├── meal.dart
│   │   ├── recipe.dart
│   │   ├── meal_plan.dart
│   │   └── shopping_list_item.dart
│   ├── repositories/
│   │   └── nutrition_repository.dart
│   └── usecases/
│       ├── calculate_macros.dart
│       ├── log_meal.dart
│       ├── get_daily_macro_summary.dart
│       ├── search_recipes.dart
│       └── create_meal_plan.dart
└── presentation/
    ├── pages/
    │   ├── nutrition_page.dart
    │   ├── meal_logging_page.dart
    │   ├── recipe_library_page.dart
    │   ├── meal_planning_page.dart
    │   └── shopping_list_page.dart
    ├── widgets/
    │   ├── macro_chart_widget.dart
    │   ├── meal_card_widget.dart
    │   └── recipe_card_widget.dart
    └── providers/
        ├── daily_meals_provider.dart
        ├── macro_summary_provider.dart
        └── recipes_provider.dart
```

## Macro Tracking

### Target Macros

- **Protein**: Minimum 35% of total calories
- **Fats**: Minimum 55% of total calories
- **Net Carbs**: Capped at 40g absolute maximum (not percentage-based)

### Calculation Logic

**Macro Percentages by Calories**:
- Protein: (protein grams × 4) / total calories × 100
- Fats: (fats grams × 9) / total calories × 100
- Net Carbs: (net carbs grams × 4) / total calories × 100

**Calorie Conversion**:
- Protein: 4 calories per gram
- Fats: 9 calories per gram
- Net Carbs: 4 calories per gram

**Daily Validation**:
- Daily totals should sum to approximately 100% (±5% tolerance for rounding)
- Individual meals don't need to sum to exactly 100% (daily totals matter)

### UI Components

**Macro Summary Card**:
- Display daily totals:
  - Protein: Xg / Yg (Z% of calories) [Progress bar]
  - Fats: Xg / Yg (Z% of calories) [Progress bar]
  - Net Carbs: Xg / 40g [Progress bar with warning if > 40g]
  - Total Calories: X / Y
- Color coding:
  - Green: On target
  - Yellow: Close to target
  - Red: Off target or over limit (carbs > 40g)

**Macro Chart**:
- Bar chart showing daily macro breakdown
- Stacked bars: Protein, Fats, Net Carbs
- Percentage labels on bars

### Business Logic

**CalculateDailyMacrosUseCase**:
```dart
class CalculateDailyMacrosUseCase {
  MacroSummary call(List<Meal> meals, DateTime date) {
    final dayMeals = meals.where((m) => 
      m.date.year == date.year &&
      m.date.month == date.month &&
      m.date.day == date.day
    ).toList();
    
    double totalProtein = 0;
    double totalFats = 0;
    double totalNetCarbs = 0;
    double totalCalories = 0;
    
    for (final meal in dayMeals) {
      totalProtein += meal.protein;
      totalFats += meal.fats;
      totalNetCarbs += meal.netCarbs;
      totalCalories += meal.calories;
    }
    
    // Calculate percentages
    final proteinPercent = totalCalories > 0 
        ? (totalProtein * 4 / totalCalories) * 100 
        : 0;
    final fatsPercent = totalCalories > 0 
        ? (totalFats * 9 / totalCalories) * 100 
        : 0;
    final carbsPercent = totalCalories > 0 
        ? (totalNetCarbs * 4 / totalCalories) * 100 
        : 0;
    
    return MacroSummary(
      protein: totalProtein,
      fats: totalFats,
      netCarbs: totalNetCarbs,
      calories: totalCalories,
      proteinPercent: proteinPercent,
      fatsPercent: fatsPercent,
      carbsPercent: carbsPercent,
    );
  }
}
```

## Food Logging

### Features

- Daily meal logging (breakfast, lunch, dinner, snack)
- Food item entry with macro breakdown
- Recipe-based meal logging
- Quick add from recipe library
- Meal history view

### UI Components

**Meal Logging Screen**:
- Meal type selector (Breakfast, Lunch, Dinner, Snack)
- Food items list:
  - Item name
  - Quantity/portion
  - Macros breakdown (protein, fats, net carbs, calories)
  - Edit/Remove buttons
- Add food item button
- Meal totals card:
  - Total protein, fats, net carbs, calories
  - Macro percentages
- Primary action button: "Save Meal"

**Food Item Entry**:
- Food name input
- Quantity input (grams, servings, etc.)
- Macro inputs (or auto-calculate from food database)
- Save button

### Business Logic

**LogMealUseCase**:
```dart
class LogMealUseCase {
  final NutritionRepository repository;
  
  Future<Either<Failure, Meal>> call({
    required MealType mealType,
    required String name,
    required double protein,
    required double fats,
    required double netCarbs,
    required double calories,
    required List<String> ingredients,
    String? recipeId,
    DateTime? date,
  }) async {
    // Validate macros
    if (netCarbs > 40) {
      return Left(ValidationFailure(
        'Net carbs exceed 40g limit. Current: ${netCarbs}g'
      ));
    }
    
    final meal = Meal(
      id: UUID().v4(),
      userId: currentUserId,
      date: date ?? DateTime.now(),
      mealType: mealType,
      name: name,
      protein: protein,
      fats: fats,
      netCarbs: netCarbs,
      calories: calories,
      ingredients: ingredients,
      recipeId: recipeId,
      createdAt: DateTime.now(),
    );
    
    return await repository.saveMeal(meal);
  }
}
```

## Recipe Database

### Features

- Pre-populated recipe library
- Recipe search and filtering
- Recipe detail view
- Add recipe to meal plan
- Use recipe for meal logging

### Recipe Structure

**Recipe Entity**:
- Name, description
- Servings, prep time, cook time
- Difficulty level
- Macros per serving
- Ingredients list
- Instructions list
- Tags (low-carb, gourmet, etc.)
- Image URL (optional)

### UI Components

**Recipe Library Screen**:
- Search bar
- Filter options (tags, difficulty, prep time)
- Recipe grid (2 columns)
- Recipe cards:
  - Image thumbnail
  - Recipe name
  - Macros per serving
  - Prep/cook time
  - Difficulty indicator

**Recipe Detail Screen**:
- Full recipe information
- Ingredients list
- Instructions (step-by-step)
- Macros breakdown
- "Add to Meal Plan" button
- "Log as Meal" button

### Business Logic

**SearchRecipesUseCase**:
- Search by name, description, ingredients
- Filter by tags, difficulty, prep time
- Sort by relevance, name, prep time

## Meal Planning

### Features

- Weekly meal plan creation
- Manual sale item entry
- Sale-based meal plan generation (post-MVP with LLM)
- Shopping list generation
- Meal prep suggestions

### Manual Sale Entry System

**Purpose**: Allow users to manually enter grocery store sale items for cost-effective meal planning.

**Features**:
- Sale item entry form:
  - Item name
  - Category (produce, meat, dairy, pantry)
  - Store name
  - Regular price
  - Sale price
  - Discount percentage (auto-calculate)
  - Unit (lb, oz, each)
  - Valid from/to dates
  - Description (optional)
- Sale item list view
- Sale item search/filter
- Sale item cache (store locally for offline access)

**UI Components**:
- Sale entry screen with form fields
- Sale items list (grouped by store/category)
- Active sales filter (show only current sales)

**Note**: Grocery store API integration deferred to post-MVP. Manual entry provides MVP functionality.

### Meal Plan Creation

**Features**:
- Select week start date
- Add meals for each day (breakfast, lunch, dinner, snacks)
- Link recipes to meal plan
- Generate shopping list automatically
- Calculate estimated weekly cost
- Track sale items used

**UI Components**:
- Weekly calendar view
- Meal slots for each day
- Drag-and-drop recipe assignment (optional, post-MVP)
- Shopping list preview
- Cost summary

### Shopping List Management

**Features**:
- Auto-generate from meal plan
- Organize by category
- Mark items as purchased
- Add custom items
- Link to sale items
- Estimated cost calculation

**UI Components**:
- Shopping list screen
- Category sections
- Checkbox for purchased items
- Sale item indicators
- Total cost display

## Sale Item Data Model

**SaleItem Entity**:
```dart
class SaleItem {
  final String id;
  final String name;
  final String category; // produce, meat, dairy, pantry
  final String store;
  final double regularPrice;
  final double salePrice;
  final double discountPercent; // auto-calculated
  final String unit; // lb, oz, each
  final DateTime validFrom;
  final DateTime validTo;
  final String? description;
  final String? imageUrl;
  final String source; // 'manual', 'api', 'scraped'
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

**Validation**:
- Sale price must be less than regular price
- Valid dates: validTo must be after validFrom
- Discount percent: ((regularPrice - salePrice) / regularPrice) × 100

## Integration Points

### Health Tracking Module

- Link nutrition to weight trends
- Display correlation between macros and weight
- Show nutrition impact on energy levels

### Medication Module

- Medication-aware nutrition (protein-first strategy)
- Adjust meal plans based on medication side effects
- Track medication impact on appetite

## User Flows

### Meal Logging Flow

```
Nutrition Screen → Log Meal → Select Meal Type
    ↓
Add Food Items → Enter Macros → Save Meal
    ↓
Update Daily Macros → Update Charts
```

### Meal Planning Flow

```
Nutrition Screen → Meal Planning → Select Week
    ↓
Add Meals (or use recipes) → Generate Shopping List
    ↓
Add Sale Items (manual) → Link to Shopping List
    ↓
View Cost Summary → Save Meal Plan
```

## Testing Requirements

- Macro calculation accuracy
- Meal validation logic
- Recipe search functionality
- Shopping list generation
- Sale item calculations

## References

- **Architecture**: `artifacts/phase-1-foundations/architecture-documentation.md`
- **Data Models**: `artifacts/phase-1-foundations/data-models.md`
- **Health Domain**: `artifacts/phase-1-foundations/health-domain-specifications.md`

---

**Last Updated**: [Date]  
**Version**: 1.0  
**Status**: Nutrition Module Specification Complete

