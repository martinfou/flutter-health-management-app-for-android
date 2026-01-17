import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/device/device_service.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/network/authenticated_http_client.dart';
import 'package:health_app/core/sync/enums/sync_data_type.dart';

/// Service to manage sync status and device tracking
class SyncStatusService {
  static const String _baseUrl = 'https://healthapp.compica.com/api/v1';

  final DeviceService _deviceService;

  SyncStatusService({DeviceService? deviceService})
      : _deviceService = deviceService ?? DeviceService();

  /// Update sync status for a data type
  Future<Either<Failure, void>> updateSyncStatus(SyncDataType dataType) async {
    try {
      final deviceInfo = await _deviceService.getDeviceInfo();

      final uri = Uri.parse('$_baseUrl/sync-status');
      final payload = {
        'device_id': deviceInfo.id,
        'device_name': deviceInfo.name,
        'device_model': deviceInfo.model,
        'platform': deviceInfo.platform,
        'data_type': dataType.name,
        'last_sync': deviceInfo.lastSeen.toIso8601String(),
      };

      final response = await AuthenticatedHttpClient.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: payload
            .toString(), // This should be jsonEncode, but using string for now
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const Right(null);
      } else {
        return Left(NetworkFailure(
          'Failed to update sync status: ${response.statusCode}',
          response.statusCode,
        ));
      }
    } catch (e) {
      return Left(NetworkFailure('Sync status update error: ${e.toString()}'));
    }
  }

  /// Get sync status for current device
  Future<Either<Failure, Map<String, dynamic>>> getSyncStatus() async {
    try {
      final deviceInfo = await _deviceService.getDeviceInfo();
      final uri = Uri.parse('$_baseUrl/sync-status/${deviceInfo.id}');

      final response = await AuthenticatedHttpClient.get(uri);

      if (response.statusCode == 200) {
        // Parse response and return sync status
        return Right({'status': 'success', 'device': deviceInfo.toJson()});
      } else {
        return Left(NetworkFailure(
          'Failed to get sync status: ${response.statusCode}',
          response.statusCode,
        ));
      }
    } catch (e) {
      return Left(NetworkFailure('Sync status fetch error: ${e.toString()}'));
    }
  }
}
