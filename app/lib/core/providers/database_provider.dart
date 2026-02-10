import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod/riverpod.dart';

/// Box name constants for Hive boxes
class HiveBoxNames {
  HiveBoxNames._();

  static const String userProfile = 'userProfileBox';
  static const String healthMetrics = 'healthMetricsBox';
  static const String medications = 'medicationsBox';
  static const String medicationLogs = 'medicationLogsBox';
  static const String meals = 'mealsBox';
  static const String exercises = 'exercisesBox';
  static const String recipes = 'recipesBox';
  static const String mealPlans = 'mealPlansBox';
  static const String shoppingListItems = 'shoppingListItemsBox';
  static const String saleItems = 'saleItemsBox';
  static const String progressPhotos = 'progressPhotosBox';
  static const String sideEffects = 'sideEffectsBox';
  static const String habits = 'habitsBox';
  static const String goals = 'goalsBox';
  static const String userPreferences = 'userPreferencesBox';
  static const String offlineSyncQueue = 'offlineSyncQueueBox';
  static const String products = 'productsBox';
}

/// Provider for Hive database instance
/// 
/// Provides access to Hive for opening boxes and database operations.
final hiveProvider = Provider<HiveInterface>((ref) {
  return Hive;
});

/// Provider that ensures Hive is initialized
/// 
/// This provider initializes Hive when first accessed.
final hiveInitializedProvider = FutureProvider<bool>((ref) async {
  if (!Hive.isAdapterRegistered(0)) {
    // Hive is not initialized yet
    // This will be handled by DatabaseInitializer
    return false;
  }
  return true;
});

