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

  /// Bulk sync meals
  Future<Result<Map<String, dynamic>>> bulkSync(List<MealModel> meals) async {
    try {
      final uri = Uri.parse('$_baseUrl$_mealsEndpoint/sync');

      final payload = {
        'meals': meals.map((m) => m.toJson()).toList(),
      };

      print('MealsBulkSync: Sending ${meals.length} meals to $uri');

      final response = await AuthenticatedHttpClient.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      print('MealsBulkSync: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Right(data['data'] as Map<String, dynamic>);
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
