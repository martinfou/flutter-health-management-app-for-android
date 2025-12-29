import 'package:hive_flutter/hive_flutter.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/errors/error_handler.dart';
import 'package:health_app/core/providers/database_provider.dart';
import 'package:fpdart/fpdart.dart';

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

      // TODO: Register adapters when models are created
      // Example:
      // Hive.registerAdapter(UserProfileAdapter());
      // Hive.registerAdapter(HealthMetricAdapter());
      // ... register all adapters ...

      // TODO: Open boxes when adapters are registered
      // Example:
      // await Hive.openBox(HiveBoxNames.userProfile);
      // await Hive.openBox(HiveBoxNames.healthMetrics);
      // ... open all boxes ...

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

