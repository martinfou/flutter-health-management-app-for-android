import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';

/// Service for device detection and identification
class DeviceService {
  static final DeviceService _instance = DeviceService._internal();
  factory DeviceService() => _instance;
  DeviceService._internal();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final Uuid _uuid = Uuid();

  String? _deviceId;
  String? _deviceName;
  String? _deviceModel;

  /// Get unique device identifier
  Future<String> getDeviceId() async {
    if (_deviceId != null) return _deviceId!;

    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        _deviceId = androidInfo.id; // Android ID
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        _deviceId =
            iosInfo.identifierForVendor ?? _uuid.v4(); // IDFV or fallback UUID
      } else {
        // For other platforms, generate a UUID
        _deviceId = _uuid.v4();
      }
    } catch (e) {
      // Fallback to UUID if device info fails
      _deviceId = _uuid.v4();
    }

    return _deviceId!;
  }

  /// Get human-readable device name
  Future<String> getDeviceName() async {
    if (_deviceName != null) return _deviceName!;

    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        _deviceName = '${androidInfo.brand} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        _deviceName = iosInfo.name ?? 'iOS Device';
      } else {
        _deviceName = Platform.operatingSystem;
      }
    } catch (e) {
      _deviceName = 'Unknown Device';
    }

    return _deviceName!;
  }

  /// Get device model information
  Future<String> getDeviceModel() async {
    if (_deviceModel != null) return _deviceModel!;

    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        _deviceModel = androidInfo.model;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        _deviceModel = iosInfo.model;
      } else {
        _deviceModel = Platform.operatingSystemVersion;
      }
    } catch (e) {
      _deviceModel = 'Unknown Model';
    }

    return _deviceModel!;
  }

  /// Get comprehensive device information
  Future<DeviceInfo> getDeviceInfo() async {
    final id = await getDeviceId();
    final name = await getDeviceName();
    final model = await getDeviceModel();

    return DeviceInfo(
      id: id,
      name: name,
      model: model,
      platform: Platform.operatingSystem,
      lastSeen: DateTime.now(),
    );
  }
}

/// Device information model
class DeviceInfo {
  final String id;
  final String name;
  final String model;
  final String platform;
  final DateTime lastSeen;

  const DeviceInfo({
    required this.id,
    required this.name,
    required this.model,
    required this.platform,
    required this.lastSeen,
  });

  Map<String, dynamic> toJson() {
    return {
      'device_id': id,
      'device_name': name,
      'device_model': model,
      'platform': platform,
      'last_seen': lastSeen.toIso8601String(),
    };
  }

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      id: json['device_id'],
      name: json['device_name'],
      model: json['device_model'],
      platform: json['platform'],
      lastSeen: DateTime.parse(json['last_seen']),
    );
  }

  @override
  String toString() {
    return '$name ($model)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceInfo && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
