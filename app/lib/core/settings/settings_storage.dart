import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../llm/llm_provider.dart';

/// Service for storing and retrieving app settings
class SettingsStorage {
  static const String _aiPreferenceKey = 'ai_preference';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<void> saveAiPreference(AiPreference preference) async {
    await _storage.write(key: _aiPreferenceKey, value: preference.name);
  }

  static Future<AiPreference> loadAiPreference() async {
    final preferenceName = await _storage.read(key: _aiPreferenceKey);
    if (preferenceName != null) {
      return AiPreference.values.firstWhere(
        (pref) => pref.name == preferenceName,
        orElse: () => AiPreference.preferOnDevice,
      );
    }
    return AiPreference.preferOnDevice; // Default
  }
}
