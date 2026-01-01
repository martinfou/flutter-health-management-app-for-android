import 'dart:convert';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart' show TargetPlatform;
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/errors/error_handler.dart';
import 'package:health_app/core/providers/database_initializer.dart';
import 'package:health_app/core/providers/database_provider.dart';
import 'package:fpdart/fpdart.dart';

// Import all models for type checking
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
import 'package:health_app/core/data/models/user_preferences_model.dart';
import 'package:health_app/features/nutrition_management/data/models/sale_item_model.dart';

/// Type alias for export result
typedef ExportResult = Result<String>;

/// Export service for backing up Hive data to JSON
class ExportService {
  ExportService._();

  /// Export all Hive boxes to JSON format
  /// 
  /// Returns the path to the exported file on success.
  static Future<ExportResult> exportAllData() async {
    try {
      final exportData = <String, dynamic>{
        'export_version': '1.0',
        'export_date': DateTime.now().toIso8601String(),
      };

      // Export each box (when boxes are opened and adapters are registered)
      final boxNames = DatabaseInitializer.getAllBoxNames();
      
      for (final boxName in boxNames) {
        if (Hive.isBoxOpen(boxName)) {
          // Access box with correct type to avoid type conflicts
          final box = _getBoxByName(boxName);
          if (box != null) {
            exportData[boxName] = _exportBox(box);
          } else {
            exportData[boxName] = [];
          }
        } else {
          // Box not opened yet (no adapters registered)
          exportData[boxName] = [];
        }
      }

      // Convert to JSON with proper serialization
      final jsonString = const JsonEncoder.withIndent('  ').convert(
        _toJsonSerializable(exportData),
      );

      // Save to file
      final filePath = await _saveExportFile(jsonString);

      return Right(filePath);
    } catch (e, stackTrace) {
      ErrorHandler.logError(
        e,
        stackTrace: stackTrace,
        context: 'ExportService.exportAllData',
      );
      return Left(
        DatabaseFailure(
          'Failed to export data: ${ErrorHandler.handleError(e)}',
        ),
      );
    }
  }

  /// Get a Hive box by name using the correct type
  /// Returns null if box is not open or type is unknown
  static Box? _getBoxByName(String boxName) {
    try {
      // Map box names to their correct types
      switch (boxName) {
        case HiveBoxNames.userProfile:
          return Hive.isBoxOpen(boxName)
              ? Hive.box<UserProfileModel>(boxName)
              : null;
        case HiveBoxNames.healthMetrics:
          return Hive.isBoxOpen(boxName)
              ? Hive.box<HealthMetricModel>(boxName)
              : null;
        case HiveBoxNames.medications:
          return Hive.isBoxOpen(boxName)
              ? Hive.box<MedicationModel>(boxName)
              : null;
        case HiveBoxNames.medicationLogs:
          return Hive.isBoxOpen(boxName)
              ? Hive.box<MedicationLogModel>(boxName)
              : null;
        case HiveBoxNames.meals:
          return Hive.isBoxOpen(boxName) ? Hive.box<MealModel>(boxName) : null;
        case HiveBoxNames.exercises:
          return Hive.isBoxOpen(boxName)
              ? Hive.box<ExerciseModel>(boxName)
              : null;
        case HiveBoxNames.recipes:
          return Hive.isBoxOpen(boxName)
              ? Hive.box<RecipeModel>(boxName)
              : null;
        case HiveBoxNames.saleItems:
          return Hive.isBoxOpen(boxName)
              ? Hive.box<SaleItemModel>(boxName)
              : null;
        case HiveBoxNames.progressPhotos:
          return Hive.isBoxOpen(boxName)
              ? Hive.box<ProgressPhotoModel>(boxName)
              : null;
        case HiveBoxNames.userPreferences:
          return Hive.isBoxOpen(boxName)
              ? Hive.box<UserPreferencesModel>(boxName)
              : null;
        case HiveBoxNames.habits:
          return Hive.isBoxOpen(boxName)
              ? Hive.box<HabitModel>(boxName)
              : null;
        case HiveBoxNames.goals:
          return Hive.isBoxOpen(boxName)
              ? Hive.box<GoalModel>(boxName)
              : null;
        default:
          return null;
      }
    } catch (e) {
      ErrorHandler.logError(e, context: 'ExportService._getBoxByName');
      return null;
    }
  }

  /// Export a single Hive box to JSON
  static List<Map<String, dynamic>> _exportBox(Box box) {
    final data = <Map<String, dynamic>>[];
    
    for (final key in box.keys) {
      final value = box.get(key);
      if (value != null) {
        // Convert HiveObject to Map
        if (value is HiveObject) {
          final map = _hiveObjectToMap(value);
          map['_key'] = key.toString(); // Store the Hive key
          data.add(map);
        } else {
          // For primitive types, create a simple map
          data.add({
            '_key': key.toString(),
            '_value': _toJsonSerializable(value),
          });
        }
      }
    }
    
    return data;
  }

  /// Convert HiveObject to Map for JSON serialization
  static Map<String, dynamic> _hiveObjectToMap(HiveObject obj) {
    final map = <String, dynamic>{};

    // Handle different model types by accessing their properties directly
    if (obj is UserProfileModel) {
      map.addAll({
        'id': obj.id,
        'name': obj.name,
        'email': obj.email,
        'dateOfBirth': obj.dateOfBirth.toIso8601String(),
        'gender': obj.gender,
        'height': obj.height,
        'targetWeight': obj.targetWeight,
        'syncEnabled': obj.syncEnabled,
        'createdAt': obj.createdAt.toIso8601String(),
        'updatedAt': obj.updatedAt.toIso8601String(),
      });
    } else if (obj is HealthMetricModel) {
      map.addAll({
        'id': obj.id,
        'userId': obj.userId,
        'date': obj.date.toIso8601String(),
        'weight': obj.weight,
        'sleepQuality': obj.sleepQuality,
        'sleepHours': obj.sleepHours,
        'energyLevel': obj.energyLevel,
        'restingHeartRate': obj.restingHeartRate,
        'systolicBP': obj.systolicBP,
        'diastolicBP': obj.diastolicBP,
        'bodyMeasurements': obj.bodyMeasurements,
        'notes': obj.notes,
        'createdAt': obj.createdAt.toIso8601String(),
        'updatedAt': obj.updatedAt.toIso8601String(),
      });
    } else if (obj is MedicationModel) {
      map.addAll({
        'id': obj.id,
        'userId': obj.userId,
        'name': obj.name,
        'dosage': obj.dosage,
        'frequency': obj.frequency,
        'times': obj.times,
        'startDate': obj.startDate.toIso8601String(),
        'endDate': obj.endDate?.toIso8601String(),
        'reminderEnabled': obj.reminderEnabled,
        'createdAt': obj.createdAt.toIso8601String(),
        'updatedAt': obj.updatedAt.toIso8601String(),
      });
    } else if (obj is MedicationLogModel) {
      map.addAll({
        'id': obj.id,
        'medicationId': obj.medicationId,
        'takenAt': obj.takenAt.toIso8601String(),
        'dosage': obj.dosage,
        'notes': obj.notes,
        'createdAt': obj.createdAt.toIso8601String(),
      });
    } else if (obj is MealModel) {
      map.addAll({
        'id': obj.id,
        'userId': obj.userId,
        'date': obj.date.toIso8601String(),
        'mealType': obj.mealType,
        'name': obj.name,
        'protein': obj.protein,
        'fats': obj.fats,
        'netCarbs': obj.netCarbs,
        'calories': obj.calories,
        'ingredients': obj.ingredients,
        'recipeId': obj.recipeId,
        'createdAt': obj.createdAt.toIso8601String(),
      });
    } else if (obj is RecipeModel) {
      map.addAll({
        'id': obj.id,
        'name': obj.name,
        'description': obj.description,
        'servings': obj.servings,
        'prepTime': obj.prepTime,
        'cookTime': obj.cookTime,
        'difficulty': obj.difficulty,
        'protein': obj.protein,
        'fats': obj.fats,
        'netCarbs': obj.netCarbs,
        'calories': obj.calories,
        'ingredients': obj.ingredients,
        'instructions': obj.instructions,
        'tags': obj.tags,
        'imageUrl': obj.imageUrl,
        'createdAt': obj.createdAt.toIso8601String(),
        'updatedAt': obj.updatedAt.toIso8601String(),
      });
    } else if (obj is ExerciseModel) {
      map.addAll({
        'id': obj.id,
        'userId': obj.userId,
        'name': obj.name,
        'type': obj.type,
        'muscleGroups': obj.muscleGroups,
        'equipment': obj.equipment,
        'duration': obj.duration,
        'sets': obj.sets,
        'reps': obj.reps,
        'weight': obj.weight,
        'distance': obj.distance,
        'date': obj.date?.toIso8601String(), // Nullable for template exercises
        'notes': obj.notes,
        'createdAt': obj.createdAt.toIso8601String(),
        'updatedAt': obj.updatedAt.toIso8601String(),
      });
    } else if (obj is HabitModel) {
      map.addAll({
        'id': obj.id,
        'userId': obj.userId,
        'name': obj.name,
        'category': obj.category,
        'description': obj.description,
        'completedDates': obj.completedDates.map((d) => d.toIso8601String()).toList(),
        'currentStreak': obj.currentStreak,
        'longestStreak': obj.longestStreak,
        'startDate': obj.startDate.toIso8601String(),
        'createdAt': obj.createdAt.toIso8601String(),
        'updatedAt': obj.updatedAt.toIso8601String(),
      });
    } else if (obj is GoalModel) {
      map.addAll({
        'id': obj.id,
        'userId': obj.userId,
        'type': obj.type,
        'description': obj.description,
        'target': obj.target,
        'targetValue': obj.targetValue,
        'currentValue': obj.currentValue,
        'deadline': obj.deadline?.toIso8601String(),
        'linkedMetric': obj.linkedMetric,
        'status': obj.status,
        'completedAt': obj.completedAt?.toIso8601String(),
        'createdAt': obj.createdAt.toIso8601String(),
        'updatedAt': obj.updatedAt.toIso8601String(),
      });
    } else if (obj is ProgressPhotoModel) {
      map.addAll({
        'id': obj.id,
        'healthMetricId': obj.healthMetricId,
        'photoType': obj.photoType,
        'imagePath': obj.imagePath,
        'date': obj.date.toIso8601String(),
        'createdAt': obj.createdAt.toIso8601String(),
      });
    } else if (obj is UserPreferencesModel) {
      map.addAll({
        'dietaryApproach': obj.dietaryApproach,
        'preferredMealTimes': obj.preferredMealTimes,
        'allergies': obj.allergies,
        'dislikes': obj.dislikes,
        'fitnessGoals': obj.fitnessGoals,
        'notificationPreferences': obj.notificationPreferences,
        'units': obj.units,
        'theme': obj.theme,
      });
    } else if (obj is SaleItemModel) {
      map.addAll({
        'id': obj.id,
        'name': obj.name,
        'category': obj.category,
        'store': obj.store,
        'regularPrice': obj.regularPrice,
        'salePrice': obj.salePrice,
        'discountPercent': obj.discountPercent,
        'unit': obj.unit,
        'validFrom': obj.validFrom.toIso8601String(),
        'validTo': obj.validTo.toIso8601String(),
        'description': obj.description,
        'imageUrl': obj.imageUrl,
        'source': obj.source,
        'createdAt': obj.createdAt.toIso8601String(),
        'updatedAt': obj.updatedAt.toIso8601String(),
      });
    } else {
      // Fallback: try to get basic info
      map['_type'] = obj.runtimeType.toString();
      map['_key'] = obj.key.toString();
    }
    
    return map;
  }

  /// Convert a value to JSON-serializable format
  /// Handles DateTime, List, Map, and other complex types
  static dynamic _toJsonSerializable(dynamic value) {
    if (value == null) {
      return null;
    } else if (value is DateTime) {
      return value.toIso8601String();
    } else if (value is List) {
      return value.map((item) => _toJsonSerializable(item)).toList();
    } else if (value is Map) {
      return value.map(
        (key, val) => MapEntry(
          key.toString(),
          _toJsonSerializable(val),
        ),
      );
    } else if (value is num || value is bool || value is String) {
      return value;
    } else {
      // For unknown types, convert to string
      return value.toString();
    }
  }

  /// Save export file to device storage
  /// 
  /// Attempts to save to Downloads directory for better accessibility.
  /// Falls back to app's external storage directory if Downloads is not accessible.
  static Future<String> _saveExportFile(String jsonContent) async {
    try {
      Directory directory;
      
      // Try to save to Downloads directory (more accessible)
      if (defaultTargetPlatform == TargetPlatform.android) {
        try {
          // For Android, try to get Downloads directory
          // First, try to get external storage directory
          final externalDir = await getExternalStorageDirectory();
          if (externalDir != null) {
            // External storage path is like: /storage/emulated/0/Android/data/com.healthapp.health_app/files
            // We need to go to: /storage/emulated/0/Download
            final externalPath = externalDir.path;
            final parts = externalPath.split('/');
            
            // Find the index of 'Android' in the path
            int androidIndex = -1;
            for (int i = 0; i < parts.length; i++) {
              if (parts[i] == 'Android') {
                androidIndex = i;
                break;
              }
            }
            
            if (androidIndex > 0) {
              // Rebuild path up to Android, then replace with Download
              final basePath = parts.sublist(0, androidIndex).join('/');
              final downloadsPath = '$basePath/Download';
              final downloadsDir = Directory(downloadsPath);
              
              // Try to use Downloads directory
              // On Android 10+ (API 29+), direct access to Downloads may be restricted
              // but we can still try
              try {
                // Check if Downloads directory exists or can be created
                if (!await downloadsDir.exists()) {
                  await downloadsDir.create(recursive: true);
                }
                
                // Test if we can actually write to this directory
                final testFile = File('${downloadsDir.path}/.test_write');
                try {
                  await testFile.writeAsString('test');
                  await testFile.delete();
                  directory = downloadsDir;
                } catch (_) {
                  // Can't write to Downloads (likely Android 10+ scoped storage)
                  // Use app's external storage directory instead
                  // This directory is accessible via file picker
                  directory = externalDir;
                }
              } catch (_) {
                // If we can't create/write to Downloads, use app's external directory
                // This is accessible via file picker and share functionality
                directory = externalDir;
              }
            } else {
              // Fallback to app's external storage directory
              directory = externalDir;
            }
          } else {
            // Fallback to app documents directory
            directory = await getApplicationDocumentsDirectory();
          }
        } catch (e) {
          // If Downloads directory fails, fall back to app documents directory
          ErrorHandler.logError(e, context: 'ExportService._saveExportFile - Downloads fallback');
          directory = await getApplicationDocumentsDirectory();
        }
      } else {
        // For other platforms, use app documents directory
        directory = await getApplicationDocumentsDirectory();
      }

      // Ensure directory exists
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Create filename with timestamp
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = 'health_app_export_$timestamp.json';
      final file = File('${directory.path}/$fileName');

      // Write file
      await file.writeAsString(jsonContent);

      return file.path;
    } catch (e, stackTrace) {
      ErrorHandler.logError(
        e,
        stackTrace: stackTrace,
        context: 'ExportService._saveExportFile',
      );
      rethrow;
    }
  }

  /// Get export file size in bytes
  static Future<int?> getExportFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return null;
    } catch (e) {
      ErrorHandler.logError(e, context: 'ExportService.getExportFileSize');
      return null;
    }
  }

  /// Format file size for display
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Import data from JSON file
  /// 
  /// Validates the file format and imports data into Hive boxes.
  /// Returns success if import is successful.
  static Future<ExportResult> importAllData(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return Left(DatabaseFailure('Import file does not exist'));
      }

      // Read file content
      final jsonString = await file.readAsString();
      
      // Parse JSON
      final importData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Validate export version
      if (importData['export_version'] == null) {
        return Left(DatabaseFailure('Invalid import file format: missing export_version'));
      }
      
      // Import each box
      final boxNames = DatabaseInitializer.getAllBoxNames();
      
      for (final boxName in boxNames) {
        if (importData.containsKey(boxName)) {
          final boxData = importData[boxName] as List<dynamic>;
          
          if (Hive.isBoxOpen(boxName)) {
            // Access box with correct type to avoid type conflicts
            final box = _getBoxByName(boxName);
            if (box != null) {
              await _importBox(box, boxData);
            }
          }
        }
      }
      
      return Right('Data imported successfully');
    } catch (e, stackTrace) {
      ErrorHandler.logError(
        e,
        stackTrace: stackTrace,
        context: 'ExportService.importAllData',
      );
      return Left(
        DatabaseFailure(
          'Failed to import data: ${ErrorHandler.handleError(e)}',
        ),
      );
    }
  }

  /// Import data into a Hive box
  static Future<void> _importBox(Box box, List<dynamic> data) async {
    await box.clear();

    for (final item in data) {
      if (item is! Map<String, dynamic>) {
        continue;
      }

      final key = item['_key'];
      if (key == null) {
        continue;
      }

      final value = _reconstructHiveValue(box, item);
      if (value != null) {
        await box.put(key, value);
      }
    }
  }

  static dynamic _reconstructHiveValue(Box box, Map<String, dynamic> item) {
    final itemData = Map<String, dynamic>.from(item);
    itemData.remove('_key');

    if (itemData.containsKey('_value')) {
      return itemData['_value'];
    }

    if (box is Box<HealthMetricModel>) {
      return _mapToHealthMetricModel(itemData);
    } else if (box is Box<UserProfileModel>) {
      return _mapToUserProfileModel(itemData);
    } else if (box is Box<UserPreferencesModel>) {
      return _mapToUserPreferencesModel(itemData);
    } else if (box is Box<MedicationModel>) {
      return _mapToMedicationModel(itemData);
    } else if (box is Box<MedicationLogModel>) {
      return _mapToMedicationLogModel(itemData);
    } else if (box is Box<MealModel>) {
      return _mapToMealModel(itemData);
    } else if (box is Box<ExerciseModel>) {
      return _mapToExerciseModel(itemData);
    } else if (box is Box<RecipeModel>) {
      return _mapToRecipeModel(itemData);
    } else if (box is Box<SaleItemModel>) {
      return _mapToSaleItemModel(itemData);
    } else if (box is Box<ProgressPhotoModel>) {
      return _mapToProgressPhotoModel(itemData);
    } else if (box is Box<HabitModel>) {
      return _mapToHabitModel(itemData);
    } else if (box is Box<GoalModel>) {
      return _mapToGoalModel(itemData);
    }

    // Fallback: store raw map when type is unknown
    return Map<String, dynamic>.from(itemData);
  }

  static UserProfileModel? _mapToUserProfileModel(Map<String, dynamic> data) {
    final id = data['id'] as String?;
    final name = data['name'] as String?;
    final email = data['email'] as String?;
    final dateOfBirth = _parseDateTime(data['dateOfBirth']);
    final gender = data['gender'] as String?;
    final height = _parseDouble(data['height']);
    final targetWeight = _parseDouble(data['targetWeight']);
    final createdAt = _parseDateTime(data['createdAt']);
    final updatedAt = _parseDateTime(data['updatedAt']);

    if ([id, name, email, dateOfBirth, gender, height, targetWeight, createdAt, updatedAt]
        .contains(null)) {
      return null;
    }

    final model = UserProfileModel()
      ..id = id!
      ..name = name!
      ..email = email!
      ..dateOfBirth = dateOfBirth!
      ..gender = gender!
      ..height = height!
      ..targetWeight = targetWeight!
      ..syncEnabled = data['syncEnabled'] as bool? ?? false
      ..createdAt = createdAt!
      ..updatedAt = updatedAt!;

    return model;
  }

  static HealthMetricModel? _mapToHealthMetricModel(Map<String, dynamic> data) {
    final id = data['id'] as String?;
    final userId = data['userId'] as String?;
    final date = _parseDateTime(data['date']);
    final createdAt = _parseDateTime(data['createdAt']);
    final updatedAt = _parseDateTime(data['updatedAt']);

    if ([id, userId, date, createdAt, updatedAt].contains(null)) {
      return null;
    }

    Map<String, double>? measurements;
    if (data['bodyMeasurements'] is Map) {
      measurements = (data['bodyMeasurements'] as Map).map(
        (key, value) => MapEntry(
          key.toString(),
          _parseDouble(value) ?? 0.0,
        ),
      );
    }

    final model = HealthMetricModel()
      ..id = id!
      ..userId = userId!
      ..date = date!
      ..weight = _parseDouble(data['weight'])
      ..sleepQuality = _parseInt(data['sleepQuality'])
      ..sleepHours = _parseDouble(data['sleepHours'])
      ..energyLevel = _parseInt(data['energyLevel'])
      ..restingHeartRate = _parseInt(data['restingHeartRate'])
      ..systolicBP = _parseInt(data['systolicBP'])
      ..diastolicBP = _parseInt(data['diastolicBP'])
      ..bodyMeasurements = measurements
      ..notes = data['notes'] as String?
      ..createdAt = createdAt!
      ..updatedAt = updatedAt!;

    return model;
  }

  static MedicationModel? _mapToMedicationModel(Map<String, dynamic> data) {
    final id = data['id'] as String?;
    final userId = data['userId'] as String?;
    final name = data['name'] as String?;
    final dosage = data['dosage'] as String?;
    final frequency = data['frequency'] as String?;
    final startDate = _parseDateTime(data['startDate']);
    final createdAt = _parseDateTime(data['createdAt']);
    final updatedAt = _parseDateTime(data['updatedAt']);

    if ([id, userId, name, dosage, frequency, startDate, createdAt, updatedAt]
        .contains(null)) {
      return null;
    }

    final model = MedicationModel()
      ..id = id!
      ..userId = userId!
      ..name = name!
      ..dosage = dosage!
      ..frequency = frequency!
      ..times = _parseStringList(data['times'])
      ..startDate = startDate!
      ..endDate = _parseDateTime(data['endDate'])
      ..reminderEnabled = data['reminderEnabled'] as bool? ?? false
      ..createdAt = createdAt!
      ..updatedAt = updatedAt!;

    return model;
  }

  static MedicationLogModel? _mapToMedicationLogModel(Map<String, dynamic> data) {
    final id = data['id'] as String?;
    final medicationId = data['medicationId'] as String?;
    final takenAt = _parseDateTime(data['takenAt']);
    final dosage = data['dosage'] as String?;
    final createdAt = _parseDateTime(data['createdAt']);

    if ([id, medicationId, takenAt, dosage, createdAt].contains(null)) {
      return null;
    }

    final model = MedicationLogModel()
      ..id = id!
      ..medicationId = medicationId!
      ..takenAt = takenAt!
      ..dosage = dosage!
      ..notes = data['notes'] as String?
      ..createdAt = createdAt!;

    return model;
  }

  static MealModel? _mapToMealModel(Map<String, dynamic> data) {
    final id = data['id'] as String?;
    final userId = data['userId'] as String?;
    final date = _parseDateTime(data['date']);
    final mealType = data['mealType'] as String?;
    final name = data['name'] as String?;
    final protein = _parseDouble(data['protein']);
    final fats = _parseDouble(data['fats']);
    final netCarbs = _parseDouble(data['netCarbs']);
    final calories = _parseDouble(data['calories']);
    final ingredients = _parseStringList(data['ingredients']);
    final createdAt = _parseDateTime(data['createdAt']);

    if ([id, userId, date, mealType, name, protein, fats, netCarbs, calories, createdAt]
        .contains(null)) {
      return null;
    }

    final model = MealModel()
      ..id = id!
      ..userId = userId!
      ..date = date!
      ..mealType = mealType!
      ..name = name!
      ..protein = protein!
      ..fats = fats!
      ..netCarbs = netCarbs!
      ..calories = calories!
      ..ingredients = ingredients
      ..recipeId = data['recipeId'] as String?
      ..createdAt = createdAt!
      ..hungerLevelBefore = _parseInt(data['hungerLevelBefore'])
      ..hungerLevelAfter = _parseInt(data['hungerLevelAfter'])
      ..fullnessAfterTimestamp = _parseDateTime(data['fullnessAfterTimestamp'])
      ..eatingReasons = _parseStringListNullable(data['eatingReasons']);

    return model;
  }

  static ExerciseModel? _mapToExerciseModel(Map<String, dynamic> data) {
    final id = data['id'] as String?;
    final userId = data['userId'] as String?;
    final name = data['name'] as String?;
    final type = data['type'] as String?;
    final muscleGroups = _parseStringList(data['muscleGroups']);
    final equipment = _parseStringList(data['equipment']);
    final date = _parseDateTime(data['date']);
    final createdAt = _parseDateTime(data['createdAt']);
    final updatedAt = _parseDateTime(data['updatedAt']);

    if ([id, userId, name, type, date, createdAt, updatedAt].contains(null)) {
      return null;
    }

    final model = ExerciseModel()
      ..id = id!
      ..userId = userId!
      ..name = name!
      ..type = type!
      ..muscleGroups = muscleGroups
      ..equipment = equipment
      ..duration = _parseInt(data['duration'])
      ..sets = _parseInt(data['sets'])
      ..reps = _parseInt(data['reps'])
      ..weight = _parseDouble(data['weight'])
      ..distance = _parseDouble(data['distance'])
      ..date = date!
      ..notes = data['notes'] as String?
      ..createdAt = createdAt!
      ..updatedAt = updatedAt!;

    return model;
  }

  static RecipeModel? _mapToRecipeModel(Map<String, dynamic> data) {
    final id = data['id'] as String?;
    final name = data['name'] as String?;
    final servings = _parseInt(data['servings']);
    final prepTime = _parseInt(data['prepTime']);
    final cookTime = _parseInt(data['cookTime']);
    final difficulty = data['difficulty'] as String?;
    final protein = _parseDouble(data['protein']);
    final fats = _parseDouble(data['fats']);
    final netCarbs = _parseDouble(data['netCarbs']);
    final calories = _parseDouble(data['calories']);
    final ingredients = _parseStringList(data['ingredients']);
    final instructions = _parseStringList(data['instructions']);
    final tags = _parseStringList(data['tags']);
    final createdAt = _parseDateTime(data['createdAt']);
    final updatedAt = _parseDateTime(data['updatedAt']);

    if ([id, name, servings, prepTime, cookTime, difficulty, protein, fats, netCarbs, calories, createdAt, updatedAt]
        .contains(null)) {
      return null;
    }

    final model = RecipeModel()
      ..id = id!
      ..name = name!
      ..description = data['description'] as String?
      ..servings = servings!
      ..prepTime = prepTime!
      ..cookTime = cookTime!
      ..difficulty = difficulty!
      ..protein = protein!
      ..fats = fats!
      ..netCarbs = netCarbs!
      ..calories = calories!
      ..ingredients = ingredients
      ..instructions = instructions
      ..tags = tags
      ..imageUrl = data['imageUrl'] as String?
      ..createdAt = createdAt!
      ..updatedAt = updatedAt!;

    return model;
  }

  static SaleItemModel? _mapToSaleItemModel(Map<String, dynamic> data) {
    final id = data['id'] as String?;
    final name = data['name'] as String?;
    final category = data['category'] as String?;
    final store = data['store'] as String?;
    final regularPrice = _parseDouble(data['regularPrice']);
    final salePrice = _parseDouble(data['salePrice']);
    final discountPercent = _parseDouble(data['discountPercent']);
    final unit = data['unit'] as String?;
    final validFrom = _parseDateTime(data['validFrom']);
    final validTo = _parseDateTime(data['validTo']);
    final source = data['source'] as String?;
    final createdAt = _parseDateTime(data['createdAt']);
    final updatedAt = _parseDateTime(data['updatedAt']);

    if ([id, name, category, store, regularPrice, salePrice, discountPercent, unit, validFrom, validTo, source, createdAt, updatedAt]
        .contains(null)) {
      return null;
    }

    final model = SaleItemModel()
      ..id = id!
      ..name = name!
      ..category = category!
      ..store = store!
      ..regularPrice = regularPrice!
      ..salePrice = salePrice!
      ..discountPercent = discountPercent!
      ..unit = unit!
      ..validFrom = validFrom!
      ..validTo = validTo!
      ..description = data['description'] as String?
      ..imageUrl = data['imageUrl'] as String?
      ..source = source!
      ..createdAt = createdAt!
      ..updatedAt = updatedAt!;

    return model;
  }

  static ProgressPhotoModel? _mapToProgressPhotoModel(Map<String, dynamic> data) {
    final id = data['id'] as String?;
    final healthMetricId = data['healthMetricId'] as String?;
    final photoType = data['photoType'] as String?;
    final imagePath = data['imagePath'] as String?;
    final date = _parseDateTime(data['date']);
    final createdAt = _parseDateTime(data['createdAt']);

    if ([id, healthMetricId, photoType, imagePath, date, createdAt].contains(null)) {
      return null;
    }

    final model = ProgressPhotoModel()
      ..id = id!
      ..healthMetricId = healthMetricId!
      ..photoType = photoType!
      ..imagePath = imagePath!
      ..date = date!
      ..createdAt = createdAt!;

    return model;
  }

  static UserPreferencesModel _mapToUserPreferencesModel(Map<String, dynamic> data) {
    final model = UserPreferencesModel()
      ..dietaryApproach = data['dietaryApproach'] as String? ?? ''
      ..preferredMealTimes = _parseStringList(data['preferredMealTimes'])
      ..allergies = _parseStringList(data['allergies'])
      ..dislikes = _parseStringList(data['dislikes'])
      ..fitnessGoals = _parseStringList(data['fitnessGoals'])
      ..notificationPreferences = Map<String, bool>.from(
        (data['notificationPreferences'] as Map?)?.map(
              (key, value) => MapEntry(key.toString(), value == true),
            ) ??
            {},
      )
      ..units = data['units'] as String? ?? 'metric'
      ..theme = data['theme'] as String? ?? 'light';

    return model;
  }

  static HabitModel? _mapToHabitModel(Map<String, dynamic> data) {
    final id = data['id'] as String?;
    final userId = data['userId'] as String?;
    final name = data['name'] as String?;
    final category = data['category'] as String?;
    final completedDates = _parseDateTimeList(data['completedDates']);
    final currentStreak = _parseInt(data['currentStreak']);
    final longestStreak = _parseInt(data['longestStreak']);
    final startDate = _parseDateTime(data['startDate']);
    final createdAt = _parseDateTime(data['createdAt']);
    final updatedAt = _parseDateTime(data['updatedAt']);

    if ([id, userId, name, category, completedDates, currentStreak, longestStreak, startDate, createdAt, updatedAt]
        .contains(null)) {
      return null;
    }

    final model = HabitModel()
      ..id = id!
      ..userId = userId!
      ..name = name!
      ..category = category!
      ..description = data['description'] as String?
      ..completedDates = completedDates!
      ..currentStreak = currentStreak!
      ..longestStreak = longestStreak!
      ..startDate = startDate!
      ..createdAt = createdAt!
      ..updatedAt = updatedAt!;

    return model;
  }

  static GoalModel? _mapToGoalModel(Map<String, dynamic> data) {
    final id = data['id'] as String?;
    final userId = data['userId'] as String?;
    final type = data['type'] as String?;
    final description = data['description'] as String?;
    final currentValue = _parseDouble(data['currentValue']);
    final status = data['status'] as String?;
    final createdAt = _parseDateTime(data['createdAt']);
    final updatedAt = _parseDateTime(data['updatedAt']);

    if ([id, userId, type, description, currentValue, status, createdAt, updatedAt]
        .contains(null)) {
      return null;
    }

    final model = GoalModel()
      ..id = id!
      ..userId = userId!
      ..type = type!
      ..description = description!
      ..target = data['target'] as String?
      ..targetValue = _parseDouble(data['targetValue'])
      ..currentValue = currentValue!
      ..deadline = _parseDateTime(data['deadline'])
      ..linkedMetric = data['linkedMetric'] as String?
      ..status = status!
      ..completedAt = _parseDateTime(data['completedAt'])
      ..createdAt = createdAt!
      ..updatedAt = updatedAt!;

    return model;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString());
  }

  static int? _parseInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value.toString());
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  static List<String>? _parseStringListNullable(dynamic value) {
    if (value == null) {
      return null;
    }
    return _parseStringList(value);
  }

  static List<DateTime>? _parseDateTimeList(dynamic value) {
    if (value is List) {
      final parsed = value
          .map((e) => _parseDateTime(e))
          .whereType<DateTime>()
          .toList();
      return parsed;
    }
    return null;
  }

  /// Validate import file format
  /// 
  /// Returns true if file format is valid, false otherwise.
  static Future<ExportResult> validateImportFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return Left(DatabaseFailure('File does not exist'));
      }
      
      final jsonString = await file.readAsString();
      final importData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      if (importData['export_version'] == null) {
        return Left(DatabaseFailure('Invalid file format: missing export_version'));
      }
      
      return Right('File format is valid');
    } catch (e) {
      return Left(DatabaseFailure('Invalid JSON file: ${ErrorHandler.handleError(e)}'));
    }
  }
}
