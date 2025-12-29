import 'dart:convert';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/errors/error_handler.dart';
import 'package:health_app/core/providers/database_initializer.dart';
import 'package:fpdart/fpdart.dart';

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
      // For now, we'll create the structure but boxes will be empty
      final boxNames = DatabaseInitializer.getAllBoxNames();
      
      for (final boxName in boxNames) {
        if (Hive.isBoxOpen(boxName)) {
          final box = Hive.box(boxName);
          exportData[boxName] = _exportBox(box);
        } else {
          // Box not opened yet (no adapters registered)
          exportData[boxName] = [];
        }
      }

      // Convert to JSON
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

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

  /// Export a single Hive box to JSON
  static List<Map<String, dynamic>> _exportBox(Box box) {
    final data = <Map<String, dynamic>>[];
    
    for (final key in box.keys) {
      final value = box.get(key);
      if (value != null) {
        // Convert HiveObject to Map
        if (value is HiveObject) {
          data.add(_hiveObjectToMap(value));
        } else {
          // For primitive types, create a simple map
          data.add({'key': key.toString(), 'value': value});
        }
      }
    }
    
    return data;
  }

  /// Convert HiveObject to Map for JSON serialization
  static Map<String, dynamic> _hiveObjectToMap(HiveObject obj) {
    // Get all fields from the HiveObject
    // This is a simplified version - in production, you'd use reflection
    // or the actual model's toJson() method
    if (obj is Map) {
      return Map<String, dynamic>.from(obj as Map);
    }
    
    // For now, return a basic representation
    // When models are created, they'll have proper toJson() methods
    return {'id': obj.key.toString()};
  }

  /// Save export file to device storage
  static Future<String> _saveExportFile(String jsonContent) async {
    try {
      // Get the Downloads directory (Android)
      Directory? directory;
      
      if (Platform.isAndroid) {
        // Try to get external storage directory
        directory = await getExternalStorageDirectory();
        if (directory != null) {
          // Use Downloads subdirectory
          final downloadsDir = Directory('${directory.path}/Download');
          if (!await downloadsDir.exists()) {
            await downloadsDir.create(recursive: true);
          }
          directory = downloadsDir;
        }
      }
      
      // Fallback to app documents directory
      directory ??= await getApplicationDocumentsDirectory();

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
}

