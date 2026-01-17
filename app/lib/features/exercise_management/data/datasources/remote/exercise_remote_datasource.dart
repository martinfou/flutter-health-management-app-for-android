import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/network/authenticated_http_client.dart';
import 'package:health_app/features/exercise_management/data/models/exercise_model.dart';

/// Remote data source for exercise management
///
/// Handles communication with the backend API for exercises.
class ExerciseRemoteDataSource {
  static const String _baseUrl = 'https://healthapp.compica.com/api/v1';
  static const String _exercisesEndpoint = '/exercises';

  /// Bulk sync exercises
  Future<Result<Map<String, dynamic>>> bulkSync(
      List<ExerciseModel> exercises) async {
    try {
      final uri = Uri.parse('$_baseUrl$_exercisesEndpoint/sync');

      final payload = {
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };

      print('ExercisesBulkSync: Sending ${exercises.length} exercises to $uri');

      final response = await AuthenticatedHttpClient.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      print('ExercisesBulkSync: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Right(data['data'] as Map<String, dynamic>);
      } else {
        return Left(NetworkFailure(
          'Exercises sync failed: ${response.statusCode}',
          response.statusCode,
        ));
      }
    } catch (e) {
      print('ExercisesBulkSync: Error: $e');
      return Left(NetworkFailure('Network error: ${e.toString()}'));
    }
  }
}
