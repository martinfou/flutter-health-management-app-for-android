
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/network/authenticated_http_client.dart';
import 'package:health_app/features/health_tracking/data/models/health_metric_model.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';

/// Remote data source for health tracking
/// 
/// Handles communication with the backend API for health metrics.
class HealthTrackingRemoteDataSource {
  // For Android Emulator, use 10.0.2.2 to access localhost
  // For iOS Simulator, use 127.0.0.1 associated with localhost
  static const String _baseUrl = 'https://healthapp.compica.com/api/v1';
  static const String _metricsEndpoint = '/health-metrics';
  
  /// Fetch health metrics from backend
  ///
  /// Parameters:
  /// - [startDate]: Filter metrics on or after this date
  /// - [endDate]: Filter metrics on or before this date
  /// - [updatedSince]: Filter metrics updated since this datetime (for delta sync)
  /// - [limit]: Maximum number of metrics to return (default 100, max 100)
  /// - [offset]: Number of metrics to skip for pagination (default 0)
  Future<Result<List<HealthMetricModel>>> getHealthMetrics({
    DateTime? startDate,
    DateTime? endDate,
    DateTime? updatedSince,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      }

      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
      }

      // For efficient delta sync: only fetch metrics updated since last sync
      if (updatedSince != null) {
        queryParams['updated_since'] = updatedSince.toIso8601String();
      }

      final uri = Uri.parse('$_baseUrl$_metricsEndpoint').replace(
        queryParameters: queryParams,
      );

      print('GetHealthMetrics: Fetching from $uri');

      final response = await AuthenticatedHttpClient.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> results = data['data'] as List<dynamic>;

        final metrics = results
            .map((json) => HealthMetricModel.fromJson(json as Map<String, dynamic>))
            .toList();

        print('GetHealthMetrics: Retrieved ${metrics.length} metrics');

        return Right(metrics);
      } else {
        return Left(NetworkFailure(
          'Failed to fetch metrics: ${response.statusCode}',
          response.statusCode,
        ));
      }
    } catch (e) {
      return Left(NetworkFailure('Network error: ${e.toString()}'));
    }
  }
  
  /// Save health metric to backend
  Future<Result<HealthMetricModel>> saveHealthMetric(HealthMetricModel metric) async {
    try {
      final uri = Uri.parse('$_baseUrl$_metricsEndpoint');
      
      final response = await AuthenticatedHttpClient.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(metric.toJson()),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        // Handle nested data structure if wrapper exists, assumed direct or in 'data'
        final metricData = data['data'] != null 
            ? data['data']['health_metric'] ?? data['data'] 
            : data;
            
        return Right(HealthMetricModel.fromJson(metricData as Map<String, dynamic>));
      } else if (response.statusCode == 409) {
        return Left(ValidationFailure('Metric already exists for this date'));
      } else {
        return Left(NetworkFailure(
          'Failed to save metric: ${response.statusCode}',
          response.statusCode,
        ));
      }
    } catch (e) {
      return Left(NetworkFailure('Network error: ${e.toString()}'));
    }
  }
  
  /// Update health metric on backend
  Future<Result<HealthMetricModel>> updateHealthMetric(HealthMetricModel metric) async {
    try {
      final uri = Uri.parse('$_baseUrl$_metricsEndpoint/${metric.id}');
      
      final response = await AuthenticatedHttpClient.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(metric.toJson()),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final metricData = data['data'] != null 
            ? data['data']['health_metric'] ?? data['data'] 
            : data;
            
        return Right(HealthMetricModel.fromJson(metricData as Map<String, dynamic>));
      } else if (response.statusCode == 404) {
        return Left(NetworkFailure('Metric not found on server', 404));
      } else {
        return Left(NetworkFailure(
          'Failed to update metric: ${response.statusCode}',
          response.statusCode,
        ));
      }
    } catch (e) {
      return Left(NetworkFailure('Network error: ${e.toString()}'));
    }
  }
  
  /// Delete health metric from backend
  Future<Result<void>> deleteHealthMetric(String id) async {
    try {
      final uri = Uri.parse('$_baseUrl$_metricsEndpoint/$id');
      
      final response = await AuthenticatedHttpClient.delete(uri);
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Right(null);
      } else if (response.statusCode == 404) {
        return Left(NetworkFailure('Metric not found on server', 404));
      } else {
        return Left(NetworkFailure(
          'Failed to delete metric: ${response.statusCode}',
          response.statusCode,
        ));
      }
    } catch (e) {
      return Left(NetworkFailure('Network error: ${e.toString()}'));
    }
  }
  
  /// Bulk sync health metrics
  Future<Result<Map<String, dynamic>>> bulkSync(List<HealthMetricModel> metrics) async {
    try {
      final uri = Uri.parse('$_baseUrl$_metricsEndpoint/sync');

      final payload = {
        'metrics': metrics.map((m) => m.toJson()).toList(),
      };

      print('BulkSync: Sending ${metrics.length} metrics to $uri');
      print('BulkSync: Payload: ${jsonEncode(payload)}');

      final response = await AuthenticatedHttpClient.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      print('BulkSync: Response status: ${response.statusCode}');
      print('BulkSync: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Right(data['data'] as Map<String, dynamic>);
      } else {
        return Left(NetworkFailure(
          'Sync failed: ${response.statusCode}',
          response.statusCode,
        ));
      }
    } catch (e) {
      print('BulkSync: Error: $e');
      return Left(NetworkFailure('Network error: ${e.toString()}'));
    }
  }
}
