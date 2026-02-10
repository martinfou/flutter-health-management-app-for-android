import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/network/authenticated_http_client.dart';
import 'package:health_app/features/nutrition_management/data/models/meal_model.dart';

/// Remote data source for nutrition management
///
/// Handles communication with the backend API for meals.
class NutritionRemoteDataSource {
  static const String _baseUrl = 'https://healthapp.compica.com/api/v1';
  static const String _mealsEndpoint = '/meals';

  /// Bulk sync meals with optional last sync timestamp for delta sync
  ///
  /// Sends local meal changes to the server and returns server changes
  /// since the last sync timestamp for bidirectional synchronization.
  Future<Result<List<MealModel>>> bulkSync(
    List<MealModel> meals, {
    DateTime? lastSyncTimestamp,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$_mealsEndpoint/sync');

      final payload = {
        'changes': meals.map((m) => m.toJson()).toList(),
        if (lastSyncTimestamp != null)
          'last_sync_timestamp': lastSyncTimestamp.toIso8601String(),
      };

      print('MealsBulkSync: Sending ${meals.length} meals to $uri');
      if (lastSyncTimestamp != null) {
        print('MealsBulkSync: Using last sync timestamp: $lastSyncTimestamp');
      }

      final response = await AuthenticatedHttpClient.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      print('MealsBulkSync: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final responseData = data['data'] as Map<String, dynamic>;

        // Extract server changes for bidirectional sync
        final List<dynamic> serverChanges = responseData['changes'] ?? [];
        print('MealsBulkSync: Response contains ${serverChanges.length} server changes');

        final remoteMeals = serverChanges
            .map((m) => MealModel.fromJson(m as Map<String, dynamic>))
            .toList();

        return Right(remoteMeals);
      } else {
        return Left(NetworkFailure(
          'Meals sync failed: ${response.statusCode}',
          response.statusCode,
        ));
      }
    } catch (e) {
      print('MealsBulkSync: Error: $e');
      return Left(NetworkFailure('Network error: ${e.toString()}'));
    }
  }
}
