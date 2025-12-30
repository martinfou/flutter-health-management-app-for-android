import 'package:hive_flutter/hive_flutter.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/errors/error_handler.dart';
import 'package:health_app/core/providers/database_provider.dart';
import 'package:fpdart/fpdart.dart';

// Import all Hive models (adapters will be generated)
// NOTE: Run `flutter pub run build_runner build` to generate adapters first
import 'package:health_app/features/user_profile/data/models/user_profile_model.dart';
import 'package:health_app/features/health_tracking/data/models/health_metric_model.dart';
import 'package:health_app/features/medication_management/data/models/medication_model.dart';
import 'package:health_app/features/medication_management/data/models/medication_log_model.dart';
import 'package:health_app/features/nutrition_management/data/models/meal_model.dart';
import 'package:health_app/features/nutrition_management/data/models/recipe_model.dart';
import 'package:health_app/features/nutrition_management/domain/entities/recipe.dart';
import 'package:health_app/features/nutrition_management/domain/entities/recipe_difficulty.dart';
import 'package:health_app/features/exercise_management/data/models/exercise_model.dart';
import 'package:health_app/features/behavioral_support/data/models/habit_model.dart';
import 'package:health_app/features/behavioral_support/data/models/goal_model.dart';
import 'package:health_app/features/health_tracking/data/models/progress_photo_model.dart';
import 'package:health_app/features/nutrition_management/data/models/sale_item_model.dart';
import 'package:health_app/core/data/models/user_preferences_model.dart';

/// Type alias for database initialization result
typedef DatabaseInitResult = Result<bool>;

/// Database initialization utility
/// 
/// Handles Hive initialization, adapter registration, and box opening.
class DatabaseInitializer {
  DatabaseInitializer._();

  /// Initialize Hive database
  /// 
  /// This method:
  /// 1. Initializes Hive for Flutter
  /// 2. Registers all type adapters (to be implemented when models are created)
  /// 3. Opens all required boxes
  /// 
  /// Returns Right(true) on success, Left(Failure) on error.
  static Future<DatabaseInitResult> initialize() async {
    try {
      // Initialize Hive for Flutter
      await Hive.initFlutter();

      // Register all Hive adapters
      // NOTE: Adapters must be generated first using: flutter pub run build_runner build
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(UserProfileModelAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(HealthMetricModelAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(MedicationModelAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(MedicationLogModelAdapter());
      }
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(MealModelAdapter());
      }
      if (!Hive.isAdapterRegistered(5)) {
        Hive.registerAdapter(ExerciseModelAdapter());
      }
      if (!Hive.isAdapterRegistered(6)) {
        Hive.registerAdapter(RecipeModelAdapter());
      }
      if (!Hive.isAdapterRegistered(9)) {
        Hive.registerAdapter(SaleItemModelAdapter());
      }
      if (!Hive.isAdapterRegistered(10)) {
        Hive.registerAdapter(ProgressPhotoModelAdapter());
      }
      if (!Hive.isAdapterRegistered(12)) {
        Hive.registerAdapter(UserPreferencesModelAdapter());
      }
      if (!Hive.isAdapterRegistered(13)) {
        Hive.registerAdapter(HabitModelAdapter());
      }
      if (!Hive.isAdapterRegistered(14)) {
        Hive.registerAdapter(GoalModelAdapter());
      }

      // Open all Hive boxes
      if (!Hive.isBoxOpen(HiveBoxNames.userProfile)) {
        await Hive.openBox<UserProfileModel>(HiveBoxNames.userProfile);
      }
      if (!Hive.isBoxOpen(HiveBoxNames.healthMetrics)) {
        await Hive.openBox<HealthMetricModel>(HiveBoxNames.healthMetrics);
      }
      if (!Hive.isBoxOpen(HiveBoxNames.medications)) {
        await Hive.openBox<MedicationModel>(HiveBoxNames.medications);
      }
      if (!Hive.isBoxOpen(HiveBoxNames.medicationLogs)) {
        await Hive.openBox<MedicationLogModel>(HiveBoxNames.medicationLogs);
      }
      if (!Hive.isBoxOpen(HiveBoxNames.meals)) {
        await Hive.openBox<MealModel>(HiveBoxNames.meals);
      }
      if (!Hive.isBoxOpen(HiveBoxNames.exercises)) {
        await Hive.openBox<ExerciseModel>(HiveBoxNames.exercises);
      }
      if (!Hive.isBoxOpen(HiveBoxNames.recipes)) {
        await Hive.openBox<RecipeModel>(HiveBoxNames.recipes);
      }
      if (!Hive.isBoxOpen(HiveBoxNames.saleItems)) {
        await Hive.openBox<SaleItemModel>(HiveBoxNames.saleItems);
      }
      if (!Hive.isBoxOpen(HiveBoxNames.progressPhotos)) {
        await Hive.openBox<ProgressPhotoModel>(HiveBoxNames.progressPhotos);
      }
      if (!Hive.isBoxOpen(HiveBoxNames.userPreferences)) {
        await Hive.openBox<UserPreferencesModel>(HiveBoxNames.userPreferences);
      }
      if (!Hive.isBoxOpen(HiveBoxNames.habits)) {
        await Hive.openBox<HabitModel>(HiveBoxNames.habits);
      }
      if (!Hive.isBoxOpen(HiveBoxNames.goals)) {
        await Hive.openBox<GoalModel>(HiveBoxNames.goals);
      }

      // Seed default recipes if recipes box is empty
      final recipesBox = Hive.box<RecipeModel>(HiveBoxNames.recipes);
      if (recipesBox.isEmpty) {
        await _seedDefaultRecipes(recipesBox);
      }

      return Right(true);
    } catch (e, stackTrace) {
      ErrorHandler.logError(
        e,
        stackTrace: stackTrace,
        context: 'DatabaseInitializer.initialize',
      );
      return Left(
        DatabaseFailure(
          'Failed to initialize database: ${ErrorHandler.handleError(e)}',
        ),
      );
    }
  }

  /// Check if database is initialized
  static bool isInitialized() {
    return Hive.isBoxOpen(HiveBoxNames.userProfile) ||
        Hive.isAdapterRegistered(0);
  }

  /// Close all open boxes
  /// 
  /// Useful for cleanup or before reinitialization.
  static Future<void> closeAllBoxes() async {
    try {
      await Hive.close();
    } catch (e, stackTrace) {
      ErrorHandler.logError(
        e,
        stackTrace: stackTrace,
        context: 'DatabaseInitializer.closeAllBoxes',
      );
    }
  }

  /// Get list of all box names
  static List<String> getAllBoxNames() {
    return [
      HiveBoxNames.userProfile,
      HiveBoxNames.healthMetrics,
      HiveBoxNames.medications,
      HiveBoxNames.medicationLogs,
      HiveBoxNames.meals,
      HiveBoxNames.exercises,
      HiveBoxNames.recipes,
      HiveBoxNames.mealPlans,
      HiveBoxNames.shoppingListItems,
      HiveBoxNames.saleItems,
      HiveBoxNames.progressPhotos,
      HiveBoxNames.sideEffects,
      HiveBoxNames.habits,
      HiveBoxNames.goals,
      HiveBoxNames.userPreferences,
    ];
  }

  /// Seed default recipes into the recipes box
  static Future<void> _seedDefaultRecipes(Box<RecipeModel> recipesBox) async {
    final now = DateTime.now();
    final baseTimestamp = now.millisecondsSinceEpoch;

    final defaultRecipes = [
      // 1. Grilled Chicken Salad
      Recipe(
        id: 'recipe-$baseTimestamp-1',
        name: 'Grilled Chicken Salad',
        description:
            'A protein-packed salad perfect for lunch or dinner. Fresh greens with grilled chicken, vegetables, and a light vinaigrette.',
        servings: 2,
        prepTime: 15,
        cookTime: 10,
        difficulty: RecipeDifficulty.easy,
        protein: 35.0,
        fats: 12.0,
        netCarbs: 8.0,
        calories: 280,
        ingredients: [
          '2 boneless, skinless chicken breasts (6 oz each)',
          '4 cups mixed greens (spinach, romaine, arugula)',
          '1 cup cherry tomatoes, halved',
          '1/2 cucumber, sliced',
          '1/4 red onion, thinly sliced',
          '2 tbsp olive oil',
          '1 tbsp lemon juice',
          '1 tsp Dijon mustard',
          'Salt and pepper to taste',
        ],
        instructions: [
          'Preheat grill or grill pan to medium-high heat.',
          'Season chicken breasts with salt and pepper.',
          'Grill chicken for 5-6 minutes per side until internal temperature reaches 165°F.',
          'Let chicken rest for 5 minutes, then slice.',
          'In a large bowl, combine mixed greens, tomatoes, cucumber, and red onion.',
          'Whisk together olive oil, lemon juice, Dijon mustard, salt, and pepper for dressing.',
          'Toss salad with half the dressing, top with sliced chicken, and drizzle remaining dressing.',
        ],
        tags: ['chicken', 'salad', 'high-protein', 'low-carb', 'lunch', 'dinner'],
        createdAt: now,
        updatedAt: now,
      ),

      // 2. Quinoa and Vegetable Bowl
      Recipe(
        id: 'recipe-$baseTimestamp-2',
        name: 'Quinoa and Vegetable Bowl',
        description:
            'A nutritious and filling plant-based bowl with quinoa, roasted vegetables, and a tahini dressing.',
        servings: 3,
        prepTime: 20,
        cookTime: 25,
        difficulty: RecipeDifficulty.easy,
        protein: 15.0,
        fats: 18.0,
        netCarbs: 45.0,
        calories: 390,
        ingredients: [
          '1 cup quinoa, rinsed',
          '2 cups vegetable broth',
          '1 bell pepper, diced',
          '1 zucchini, sliced',
          '1 cup broccoli florets',
          '1 sweet potato, cubed',
          '2 tbsp olive oil',
          '2 tbsp tahini',
          '1 tbsp lemon juice',
          '1 clove garlic, minced',
          'Salt and pepper to taste',
        ],
        instructions: [
          'Preheat oven to 400°F (200°C).',
          'Toss vegetables with 1 tbsp olive oil, salt, and pepper.',
          'Roast vegetables on a baking sheet for 20-25 minutes until tender.',
          'In a medium saucepan, bring quinoa and broth to a boil.',
          'Reduce heat, cover, and simmer for 15 minutes until liquid is absorbed.',
          'Whisk together tahini, remaining olive oil, lemon juice, garlic, and 2-3 tbsp water.',
          'Combine quinoa and roasted vegetables, drizzle with tahini dressing.',
        ],
        tags: ['vegetarian', 'quinoa', 'vegetables', 'bowl', 'lunch', 'dinner'],
        createdAt: now,
        updatedAt: now,
      ),

      // 3. Salmon with Roasted Asparagus
      Recipe(
        id: 'recipe-$baseTimestamp-3',
        name: 'Baked Salmon with Roasted Asparagus',
        description:
            'A heart-healthy dinner rich in omega-3 fatty acids. Tender salmon paired with perfectly roasted asparagus.',
        servings: 2,
        prepTime: 10,
        cookTime: 20,
        difficulty: RecipeDifficulty.easy,
        protein: 40.0,
        fats: 22.0,
        netCarbs: 6.0,
        calories: 380,
        ingredients: [
          '2 salmon fillets (6 oz each)',
          '1 lb asparagus, trimmed',
          '2 tbsp olive oil',
          '1 lemon, sliced',
          '2 cloves garlic, minced',
          '1 tsp dried dill',
          'Salt and pepper to taste',
        ],
        instructions: [
          'Preheat oven to 400°F (200°C).',
          'Place salmon fillets on a baking sheet lined with parchment paper.',
          'Season salmon with salt, pepper, dill, and minced garlic.',
          'Top each fillet with 2-3 lemon slices.',
          'Toss asparagus with 1 tbsp olive oil, salt, and pepper.',
          'Arrange asparagus around salmon on the baking sheet.',
          'Bake for 15-20 minutes until salmon is flaky and asparagus is tender.',
        ],
        tags: ['salmon', 'fish', 'high-protein', 'omega-3', 'low-carb', 'dinner'],
        createdAt: now,
        updatedAt: now,
      ),

      // 4. Greek Yogurt Parfait
      Recipe(
        id: 'recipe-$baseTimestamp-4',
        name: 'Greek Yogurt Parfait',
        description:
            'A protein-rich breakfast or snack with Greek yogurt, fresh berries, and granola. Great for meal prep!',
        servings: 1,
        prepTime: 5,
        cookTime: 0,
        difficulty: RecipeDifficulty.easy,
        protein: 20.0,
        fats: 8.0,
        netCarbs: 28.0,
        calories: 260,
        ingredients: [
          '1 cup plain Greek yogurt',
          '1/2 cup mixed berries (strawberries, blueberries, raspberries)',
          '2 tbsp granola',
          '1 tsp honey (optional)',
          '1 tbsp chopped nuts (almonds or walnuts)',
        ],
        instructions: [
          'In a glass or bowl, layer half the Greek yogurt.',
          'Add half the berries on top.',
          'Add remaining yogurt.',
          'Top with remaining berries, granola, and nuts.',
          'Drizzle with honey if desired.',
          'Serve immediately or refrigerate for up to 2 hours.',
        ],
        tags: ['breakfast', 'yogurt', 'protein', 'quick', 'snack', 'meal-prep'],
        createdAt: now,
        updatedAt: now,
      ),

      // 5. Turkey and Vegetable Stir-Fry
      Recipe(
        id: 'recipe-$baseTimestamp-5',
        name: 'Turkey and Vegetable Stir-Fry',
        description:
            'A lean and flavorful stir-fry with ground turkey and colorful vegetables. Quick to prepare and perfect for weeknight dinners.',
        servings: 3,
        prepTime: 15,
        cookTime: 15,
        difficulty: RecipeDifficulty.medium,
        protein: 32.0,
        fats: 14.0,
        netCarbs: 12.0,
        calories: 310,
        ingredients: [
          '1 lb lean ground turkey',
          '2 bell peppers, sliced',
          '1 cup broccoli florets',
          '1 carrot, julienned',
          '1/2 onion, sliced',
          '2 cloves garlic, minced',
          '1 tbsp fresh ginger, minced',
          '2 tbsp low-sodium soy sauce',
          '1 tbsp sesame oil',
          '1 tsp rice vinegar',
          'Salt and pepper to taste',
        ],
        instructions: [
          'Heat a large skillet or wok over high heat.',
          'Add ground turkey and cook until browned, breaking it up with a spoon.',
          'Remove turkey from pan and set aside.',
          'Add sesame oil to the same pan, then add garlic and ginger.',
          'Stir-fry for 30 seconds until fragrant.',
          'Add vegetables and stir-fry for 5-6 minutes until crisp-tender.',
          'Return turkey to pan, add soy sauce and rice vinegar.',
          'Toss everything together and cook for 2 more minutes.',
          'Season with salt and pepper to taste.',
        ],
        tags: ['turkey', 'stir-fry', 'high-protein', 'vegetables', 'dinner', 'quick'],
        createdAt: now,
        updatedAt: now,
      ),

      // 6. Overnight Oats
      Recipe(
        id: 'recipe-$baseTimestamp-6',
        name: 'Overnight Oats',
        description:
            'A make-ahead breakfast that\'s creamy, filling, and customizable. Perfect for busy mornings.',
        servings: 1,
        prepTime: 5,
        cookTime: 0,
        difficulty: RecipeDifficulty.easy,
        protein: 12.0,
        fats: 10.0,
        netCarbs: 42.0,
        calories: 300,
        ingredients: [
          '1/2 cup rolled oats',
          '1/2 cup unsweetened almond milk',
          '1/4 cup Greek yogurt',
          '1 tbsp chia seeds',
          '1/2 banana, mashed',
          '1 tsp honey or maple syrup',
          '1/4 cup berries (fresh or frozen)',
          'Pinch of cinnamon',
        ],
        instructions: [
          'In a jar or container, combine oats, almond milk, Greek yogurt, and chia seeds.',
          'Add mashed banana, honey, and cinnamon. Mix well.',
          'Stir in berries.',
          'Cover and refrigerate overnight (at least 4 hours).',
          'In the morning, give it a good stir and enjoy cold.',
          'Top with additional berries or nuts if desired.',
        ],
        tags: ['breakfast', 'oats', 'meal-prep', 'fiber', 'quick', 'vegetarian'],
        createdAt: now,
        updatedAt: now,
      ),

      // 7. Chicken and Broccoli Sheet Pan Meal
      Recipe(
        id: 'recipe-$baseTimestamp-7',
        name: 'Chicken and Broccoli Sheet Pan Meal',
        description:
            'A complete, healthy meal all on one pan. Minimal cleanup and maximum flavor!',
        servings: 4,
        prepTime: 15,
        cookTime: 25,
        difficulty: RecipeDifficulty.easy,
        protein: 38.0,
        fats: 15.0,
        netCarbs: 10.0,
        calories: 320,
        ingredients: [
          '4 boneless, skinless chicken thighs (6 oz each)',
          '4 cups broccoli florets',
          '1 red bell pepper, sliced',
          '1 yellow bell pepper, sliced',
          '1 onion, sliced',
          '3 tbsp olive oil',
          '2 cloves garlic, minced',
          '1 tsp paprika',
          '1 tsp dried oregano',
          'Salt and pepper to taste',
        ],
        instructions: [
          'Preheat oven to 425°F (220°C).',
          'In a small bowl, mix olive oil, garlic, paprika, oregano, salt, and pepper.',
          'Place chicken thighs on one side of a large baking sheet.',
          'Toss vegetables with half the oil mixture and arrange on the other side.',
          'Brush remaining oil mixture over chicken.',
          'Bake for 20-25 minutes until chicken reaches 165°F and vegetables are tender.',
          'Let chicken rest for 5 minutes before serving.',
        ],
        tags: ['chicken', 'sheet-pan', 'high-protein', 'easy', 'dinner', 'meal-prep'],
        createdAt: now,
        updatedAt: now,
      ),

      // 8. Mediterranean Chickpea Salad
      Recipe(
        id: 'recipe-$baseTimestamp-8',
        name: 'Mediterranean Chickpea Salad',
        description:
            'A fresh, protein-packed salad with chickpeas, vegetables, and a zesty lemon-herb dressing. Great for lunch or as a side.',
        servings: 4,
        prepTime: 15,
        cookTime: 0,
        difficulty: RecipeDifficulty.easy,
        protein: 14.0,
        fats: 16.0,
        netCarbs: 32.0,
        calories: 310,
        ingredients: [
          '2 cans (15 oz each) chickpeas, rinsed and drained',
          '1 cucumber, diced',
          '1 cup cherry tomatoes, halved',
          '1/2 red onion, diced',
          '1/2 cup Kalamata olives, pitted and halved',
          '1/2 cup feta cheese, crumbled',
          '3 tbsp olive oil',
          '2 tbsp lemon juice',
          '1 tsp dried oregano',
          '2 tbsp fresh parsley, chopped',
          'Salt and pepper to taste',
        ],
        instructions: [
          'In a large bowl, combine chickpeas, cucumber, tomatoes, red onion, and olives.',
          'Whisk together olive oil, lemon juice, oregano, salt, and pepper.',
          'Pour dressing over salad and toss to combine.',
          'Let marinate for at least 30 minutes in the refrigerator.',
          'Before serving, add feta cheese and fresh parsley.',
          'Toss gently and serve.',
        ],
        tags: ['vegetarian', 'chickpeas', 'mediterranean', 'salad', 'lunch', 'protein'],
        createdAt: now,
        updatedAt: now,
      ),
    ];

    // Save all recipes to the box
    for (final recipe in defaultRecipes) {
      final model = RecipeModel.fromEntity(recipe);
      await recipesBox.put(recipe.id, model);
    }
  }
}

