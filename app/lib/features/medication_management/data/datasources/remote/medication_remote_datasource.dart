import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/network/authenticated_http_client.dart';
import 'package:health_app/features/medication_management/data/models/medication_model.dart';

/// Remote data source for medication management
///
/// Handles communication with the backend API for medications.
class MedicationRemoteDataSource {
  static const String _baseUrl = 'https://healthapp.compica.com/api/v1';
  static const String _medicationsEndpoint = '/medications';

  /// Bulk sync medications
  Future<Result<Map<String, dynamic>>> bulkSync(
      List<MedicationModel> medications) async {
    try {
      final uri = Uri.parse('$_baseUrl$_medicationsEndpoint/sync');

      final payload = {
        'medications': medications.map((m) => m.toJson()).toList(),
      };

      print(
          'MedicationsBulkSync: Sending ${medications.length} medications to $uri');

      final response = await AuthenticatedHttpClient.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      print('MedicationsBulkSync: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Right(data['data'] as Map<String, dynamic>);
      } else {
        return Left(NetworkFailure(
          'Medications sync failed: ${response.statusCode}',
          response.statusCode,
        ));
      }
    } catch (e) {
      print('MedicationsBulkSync: Error: $e');
      return Left(NetworkFailure('Network error: ${e.toString()}'));
    }
  }
}
