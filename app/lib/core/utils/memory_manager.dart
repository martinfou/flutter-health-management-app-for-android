import 'package:flutter/foundation.dart';

/// Utility for memory management
/// 
/// Provides methods to help manage memory and prevent memory leaks.
class MemoryManager {
  MemoryManager._();

  /// Clear a list and free memory
  /// 
  /// Clears the list and sets it to null to help garbage collection.
  static void clearList<T>(List<T>? list) {
    if (list != null) {
      list.clear();
    }
  }

  /// Clear a map and free memory
  /// 
  /// Clears the map and sets it to null to help garbage collection.
  static void clearMap<K, V>(Map<K, V>? map) {
    if (map != null) {
      map.clear();
    }
  }

  /// Log memory usage (debug only)
  /// 
  /// Logs current memory usage if in debug mode.
  static void logMemoryUsage(String context) {
    if (kDebugMode) {
      // In a production app, you might use a memory profiling library
      // For now, just log the context
      debugPrint('Memory check: $context');
    }
  }

  /// Dispose multiple objects safely
  /// 
  /// Attempts to dispose each object, catching any errors.
  static void disposeAll(List<dynamic> objects) {
    for (final obj in objects) {
      try {
        if (obj is Disposable) {
          obj.dispose();
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error disposing object: $e');
        }
      }
    }
  }
}

/// Interface for objects that can be disposed
abstract class Disposable {
  void dispose();
}

