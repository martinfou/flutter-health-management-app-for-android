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
}

