import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import '../../errors/failures.dart';
import '../llm_provider.dart';
import '../platform/ai_core_platform.dart';

/// Adapter for On-Device AI (Gemini Nano) via Android AI Core.
///
/// This adapter enables local AI inference on supported devices:
/// - Google Pixel 8 Pro, Pixel 9, Pixel 10
/// - Requires Android 14+ with AI Core enabled
///
/// Benefits:
/// - Zero API costs - all processing is on-device
/// - Works offline - no internet required
/// - Privacy-first - data never leaves the device
/// - Low latency - no network round trips
///
/// Limitations:
/// - Smaller context window (~2K tokens)
/// - Only available on supported Pixel devices
/// - No streaming support in initial implementation
class OnDeviceLlmAdapter implements LlmProvider {
  final AiCorePlatform _aiCore;

  /// Cached availability status
  bool? _isAvailable;

  OnDeviceLlmAdapter({AiCorePlatform? aiCore})
      : _aiCore = aiCore ?? AiCorePlatform();

  @override
  String get name => 'On-Device AI (Gemini Nano)';

  @override
  bool get supportsStreaming => false;

  /// Check if on-device AI is available on this device.
  Future<bool> isAvailable() async {
    _isAvailable ??= await _aiCore.isAvailable();
    return _isAvailable!;
  }

  /// Get information about the on-device model.
  Future<AiCoreModelInfo> getModelInfo() async {
    return _aiCore.getModelInfo();
  }

  /// Pre-load the model for faster inference.
  Future<bool> preloadModel() async {
    return _aiCore.loadModel();
  }

  /// Unload the model to free memory.
  Future<bool> unloadModel() async {
    return _aiCore.unloadModel();
  }

  @override
  Future<Either<Failure, LlmResponse>> generateCompletion(
    LlmRequest request,
    LlmConfig config,
  ) async {
    try {
      // Check availability
      if (!await isAvailable()) {
        return Left(LlmFailure(
          'On-device AI not available on this device. '
          'Requires Pixel 8 Pro or newer with Android 14+.',
        ));
      }

      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🤖 On-Device AI Request');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('Model: ${config.model}');
      debugPrint('Prompt (${request.prompt.length} chars):');
      debugPrint(request.prompt);
      if (request.systemPrompt != null) {
        debugPrint('System Prompt (${request.systemPrompt!.length} chars):');
        debugPrint(request.systemPrompt!);
      }
      debugPrint('Temperature: ${request.temperature ?? config.temperature}');
      debugPrint('Max tokens: ${request.maxTokens ?? config.maxTokens}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // Generate text using AI Core
      final response = await _aiCore.generateText(
        prompt: request.prompt,
        systemPrompt: request.systemPrompt,
        maxTokens: request.maxTokens ?? config.maxTokens,
        temperature: request.temperature ?? config.temperature,
      );

      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('✅ On-Device AI Response');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('Model: ${response.model}');
      debugPrint('Content (${response.content.length} chars):');
      debugPrint(response.content);
      debugPrint('Prompt tokens: ${response.promptTokens}');
      debugPrint('Completion tokens: ${response.completionTokens}');
      debugPrint('Total tokens: ${response.totalTokens}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      return Right(LlmResponse(
        content: response.content,
        model: response.model,
        promptTokens: response.promptTokens,
        completionTokens: response.completionTokens,
        totalTokens: response.totalTokens,
      ));
    } on AiCoreException catch (e) {
      debugPrint('❌ On-Device AI Error: ${e.message}');
      return Left(LlmFailure('On-device AI error: ${e.message}'));
    } catch (e) {
      debugPrint('❌ Unexpected On-Device AI Error: $e');
      return Left(LlmFailure('Unexpected on-device AI error: $e'));
    }
  }

  /// Clear cached availability status.
  void clearCache() {
    _isAvailable = null;
    _aiCore.clearCache();
  }
}
