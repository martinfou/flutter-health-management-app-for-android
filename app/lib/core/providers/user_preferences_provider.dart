// Dart SDK
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod/riverpod.dart';

// Project
import 'package:health_app/core/data/models/user_preferences_model.dart';
import 'package:health_app/core/entities/user_preferences.dart';
import 'package:health_app/core/providers/database_provider.dart';

/// Provider for UserPreferences box
/// 
/// Provides access to the Hive box containing user preferences.
final userPreferencesBoxProvider = FutureProvider<Box<UserPreferencesModel>>((ref) async {
  final boxName = HiveBoxNames.userPreferences;
  
  if (!Hive.isBoxOpen(boxName)) {
    await Hive.openBox<UserPreferencesModel>(boxName);
  }
  
  return Hive.box<UserPreferencesModel>(boxName);
});

/// Provider for current user preferences
/// 
/// Returns the current UserPreferences entity, or defaults if not found.
final userPreferencesProvider = FutureProvider<UserPreferences>((ref) async {
  final box = await ref.watch(userPreferencesBoxProvider.future);
  
  // Try to get existing preferences
  final model = box.get('preferences');
  
  if (model != null) {
    return model.toEntity();
  }
  
  // Return defaults if not found
  return UserPreferences.defaults();
});

/// Provider for unit preference (imperial or metric)
/// 
/// Returns true if imperial units are preferred, false for metric.
/// This is a convenience provider that extracts the units field from UserPreferences.
final unitPreferenceProvider = Provider<bool>((ref) {
  final preferencesAsync = ref.watch(userPreferencesProvider);
  
  return preferencesAsync.when(
    data: (preferences) => preferences.units == 'imperial',
    loading: () => false, // Default to metric while loading
    error: (_, __) => false, // Default to metric on error
  );
});

/// Provider for updating user preferences
/// 
/// Provides a function to update user preferences in the database.
final updateUserPreferencesProvider = Provider<Future<void> Function(UserPreferences)>((ref) {
  return (UserPreferences preferences) async {
    final box = await ref.read(userPreferencesBoxProvider.future);
    final model = UserPreferencesModel.fromEntity(preferences);
    await box.put('preferences', model);
    
    // Invalidate the userPreferencesProvider to trigger a refresh
    ref.invalidate(userPreferencesProvider);
  };
});

/// Provider for updating unit preference
/// 
/// Provides a function to update only the units field in user preferences.
final updateUnitPreferenceProvider = Provider<Future<void> Function(String)>((ref) {
  return (String units) async {
    final preferencesAsync = await ref.read(userPreferencesProvider.future);
    final updatedPreferences = preferencesAsync.copyWith(units: units);
    
    final updateFn = ref.read(updateUserPreferencesProvider);
    await updateFn(updatedPreferences);
  };
});

