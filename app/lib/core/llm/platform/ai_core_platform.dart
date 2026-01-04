import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Platform channel interface for Android AI Core (Gemini Nano).
///
/// This class provides a Dart interface to the native Android AI Core service,
/// enabling on-device AI capabilities through a platform channel.
///
/// Usage:
/// ```dart
/// final aiCore = AiCorePlatform();
/// if (await aiCore.isAvailable()) {
///   final response = await aiCore.generateText(prompt: 'Hello');
///   print(response);
/// }
/// ```
class AiCorePlatform {
  static const _channel = MethodChannel('com.healthapp.health_app/ai_core');

  /// Cached availability status
  bool? _isAvailable;

  /// Check if AI Core is available on this device.
  ///
  /// Returns true if:
  /// - Android 14+ (API 34+)
  /// - Supported Pixel device (8 Pro, 9, 10, etc.)
  /// - AI Core service is available
  Future<bool> isAvailable() async {
    if (_isAvailable != null) return _isAvailable!;

    try {
      final result = await _channel.invokeMethod<bool>('isAvailable');
      _isAvailable = result ?? false;
      debugPrint('AI Core available: $_isAvailable');
      return _isAvailable!;
    } on PlatformException catch (e) {
      debugPrint('AI Core availability check failed: ${e.message}');
      _isAvailable = false;
      return false;
    } on MissingPluginException {
      // Platform channel not available (e.g., running on iOS or web)
      debugPrint('AI Core not available: Platform channel not implemented');
      _isAvailable = false;
      return false;
    }
  }

  /// Load the on-device model into memory.
  ///
  /// This should be called before generating text for faster response times.
  /// The model will be automatically loaded if not already loaded when
  /// [generateText] is called.
  Future<bool> loadModel() async {
    try {
      final result = await _channel.invokeMethod<bool>('loadModel');
      debugPrint('AI Core model loaded: $result');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('AI Core model loading failed: ${e.message}');
      return false;
    } on MissingPluginException {
      debugPrint('AI Core not available: Platform channel not implemented');
      return false;
    }
  }

  /// Unload the model to free memory.
  ///
  /// Call this when the app goes to background or AI features are not needed.
  Future<bool> unloadModel() async {
    try {
      final result = await _channel.invokeMethod<bool>('unloadModel');
      debugPrint('AI Core model unloaded: $result');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('AI Core model unloading failed: ${e.message}');
      return false;
    } on MissingPluginException {
      debugPrint('AI Core not available: Platform channel not implemented');
      return false;
    }
  }

  /// Generate text using the on-device model.
  ///
  /// [prompt] - The user prompt to process
  /// [systemPrompt] - Optional system prompt for context
  /// [maxTokens] - Maximum tokens to generate (default: 1024)
  /// [temperature] - Temperature for generation (default: 0.7)
  ///
  /// Returns an [AiCoreResponse] with the generated text and token counts.
  /// Throws [AiCoreException] if generation fails.
  Future<AiCoreResponse> generateText({
    required String prompt,
    String? systemPrompt,
    int maxTokens = 1024,
    double temperature = 0.7,
  }) async {
    try {
      final result = await _channel.invokeMethod<String>('generateText', {
        'prompt': prompt,
        'systemPrompt': systemPrompt,
        'maxTokens': maxTokens,
        'temperature': temperature,
      });

      if (result == null) {
        throw AiCoreException('No response from AI Core');
      }

      // Parse JSON response from native code
      final json = jsonDecode(result) as Map<String, dynamic>;

      return AiCoreResponse(
        content: json['content'] as String,
        model: json['model'] as String? ?? 'gemini-nano',
        promptTokens: json['prompt_tokens'] as int? ?? 0,
        completionTokens: json['completion_tokens'] as int? ?? 0,
        totalTokens: json['total_tokens'] as int? ?? 0,
      );
    } on PlatformException catch (e) {
      debugPrint('AI Core text generation failed: ${e.message}');
      throw AiCoreException(e.message ?? 'Text generation failed');
    } on MissingPluginException {
      throw AiCoreException('AI Core not available on this platform');
    } on FormatException catch (e) {
      throw AiCoreException('Failed to parse AI Core response: $e');
    }
  }

  /// Get information about the on-device model.
  Future<AiCoreModelInfo> getModelInfo() async {
    try {
      final result =
          await _channel.invokeMethod<Map<Object?, Object?>>('getModelInfo');

      if (result == null) {
        throw AiCoreException('No model info from AI Core');
      }

      // Convert to proper Map<String, dynamic>
      final info = result.map(
        (key, value) => MapEntry(key.toString(), value),
      );

      return AiCoreModelInfo(
        available: info['available'] as bool? ?? false,
        loaded: info['loaded'] as bool? ?? false,
        device: info['device'] as String? ?? 'unknown',
        androidVersion: info['android_version'] as int? ?? 0,
        modelName: info['model_name'] as String? ?? 'gemini-nano',
        provider: info['provider'] as String? ?? 'on-device',
        maxContextTokens: info['max_context_tokens'] as int? ?? 2048,
        supportsStreaming: info['supports_streaming'] as bool? ?? false,
      );
    } on PlatformException catch (e) {
      debugPrint('AI Core get model info failed: ${e.message}');
      throw AiCoreException(e.message ?? 'Failed to get model info');
    } on MissingPluginException {
      throw AiCoreException('AI Core not available on this platform');
    }
  }

  /// Clear cached availability status.
  /// Useful after app lifecycle changes.
  void clearCache() {
    _isAvailable = null;
  }
}

/// Response from AI Core text generation.
class AiCoreResponse {
  final String content;
  final String model;
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  const AiCoreResponse({
    required this.content,
    required this.model,
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  @override
  String toString() {
    return 'AiCoreResponse(model: $model, tokens: $totalTokens, content: ${content.length} chars)';
  }
}

/// Information about the on-device AI model.
class AiCoreModelInfo {
  final bool available;
  final bool loaded;
  final String device;
  final int androidVersion;
  final String modelName;
  final String provider;
  final int maxContextTokens;
  final bool supportsStreaming;

  const AiCoreModelInfo({
    required this.available,
    required this.loaded,
    required this.device,
    required this.androidVersion,
    required this.modelName,
    required this.provider,
    required this.maxContextTokens,
    required this.supportsStreaming,
  });

  @override
  String toString() {
    return 'AiCoreModelInfo(available: $available, device: $device, model: $modelName)';
  }
}

/// Exception thrown when AI Core operations fail.
class AiCoreException implements Exception {
  final String message;

  const AiCoreException(this.message);

  @override
  String toString() => 'AiCoreException: $message';
}
