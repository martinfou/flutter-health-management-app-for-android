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
  /// Sends local meal changes to the server and optionally receives server changes
  /// since the last sync timestamp for bidirectional synchronization.
  Future<Result<Map<String, dynamic>>> bulkSync(
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

        // Extract server changes and timestamp for bidirectional sync
        print('MealsBulkSync: Response contains ${responseData['changes']?.length ?? 0} server changes');

        return Right(responseData);
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

  /// Fetch meals changed since a given timestamp
  ///
  /// Returns a list of meals that have been created or modified on the server
  /// since the specified timestamp. Used for pull sync to keep local database
  /// in sync with server changes made on other devices.
  Future<Result<List<MealModel>>> getChangesSince(
      DateTime? lastSyncTimestamp) async {
    try {
      final uri = lastSyncTimestamp != null
          ? Uri.parse('$_baseUrl$_mealsEndpoint/changes')
              .replace(queryParameters: {
              'since': lastSyncTimestamp.toIso8601String(),
            })
          : Uri.parse('$_baseUrl$_mealsEndpoint');

      print('MealsGetChangesSince: Fetching meals from $uri');
      if (lastSyncTimestamp != null) {
        print('MealsGetChangesSince: Since timestamp: $lastSyncTimestamp');
      }

      final response = await AuthenticatedHttpClient.get(uri);

      print('MealsGetChangesSince: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final mealsData = data['data'] as List<dynamic>;

        final meals = mealsData
            .map((m) => MealModel.fromJson(m as Map<String, dynamic>))
            .toList();

        print('MealsGetChangesSince: Received ${meals.length} meals');
        return Right(meals);
      } else {
        return Left(NetworkFailure(
          'Failed to fetch meal changes: ${response.statusCode}',
          response.statusCode,
        ));
      }
    } catch (e) {
      print('MealsGetChangesSince: Error: $e');
      return Left(NetworkFailure('Network error: ${e.toString()}'));
    }
  }
}
