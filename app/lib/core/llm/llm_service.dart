import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import '../errors/failures.dart';
import 'llm_provider.dart';

/// Service that manages LLM providers and coordinates requests
class LlmService {
  final Map<LlmProviderType, LlmProvider> _adapters;
  LlmConfig _activeConfig;

  LlmService({
    required Map<LlmProviderType, LlmProvider> adapters,
    required LlmConfig initialConfig,
  })  : _adapters = adapters,
        _activeConfig = initialConfig;

  /// Update the active configuration
  void updateConfig(LlmConfig config) {
    _activeConfig = config;
  }

  /// Get the active configuration
  LlmConfig get config => _activeConfig;

  /// Generate a completion using the active provider
  Future<Either<Failure, LlmResponse>> generateCompletion(
      LlmRequest request) async {
    final adapter = _adapters[_activeConfig.providerType];

    if (adapter == null) {
      return Left(LlmFailure(
          'No adapter found for provider: ${_activeConfig.providerType}'));
    }

    return adapter.generateCompletion(request, _activeConfig);
  }

  /// Generate a completion with automatic fallback based on AI preference
  Future<Either<Failure, LlmResponse>> generateCompletionWithFallback(
      LlmRequest request) async {
    final onDeviceAdapter = _adapters[LlmProviderType.onDevice];
    final cloudAdapter = _adapters[_activeConfig.providerType];

    // Log provider selection
    debugPrint(
        '🎯 LLM Provider Selection: Preference=${_activeConfig.aiPreference}, Selected=${_activeConfig.providerType}');

    // Determine primary and fallback providers based on preference
    LlmProvider? primaryAdapter;
    LlmProvider? fallbackAdapter;
    LlmConfig primaryConfig = _activeConfig;
    LlmConfig fallbackConfig = _activeConfig;

    switch (_activeConfig.aiPreference) {
      case AiPreference.preferOnDevice:
        primaryAdapter = onDeviceAdapter;
        fallbackAdapter = cloudAdapter;
        primaryConfig =
            _activeConfig.copyWith(providerType: LlmProviderType.onDevice);
        break;
      case AiPreference.preferCloud:
        primaryAdapter = cloudAdapter;
        fallbackAdapter = onDeviceAdapter;
        fallbackConfig =
            _activeConfig.copyWith(providerType: LlmProviderType.onDevice);
        break;
      case AiPreference.onDeviceOnly:
        primaryAdapter = onDeviceAdapter;
        primaryConfig =
            _activeConfig.copyWith(providerType: LlmProviderType.onDevice);
        break;
      case AiPreference.cloudOnly:
        primaryAdapter = cloudAdapter;
        break;
    }

    // Try primary provider first
    if (primaryAdapter != null) {
      debugPrint('🔄 Trying primary provider: ${primaryConfig.providerType}');
      final primaryResult =
          await primaryAdapter.generateCompletion(request, primaryConfig);
      if (primaryResult.isRight()) {
        debugPrint(
            '✅ Primary provider succeeded: ${primaryConfig.providerType}');
        return primaryResult;
      }
      debugPrint('⚠️ Primary provider failed: ${primaryConfig.providerType}');

      // If primary fails and we have a fallback, try it
      if (fallbackAdapter != null &&
          _activeConfig.aiPreference != AiPreference.onDeviceOnly &&
          _activeConfig.aiPreference != AiPreference.cloudOnly) {
        debugPrint(
            '🔄 Trying fallback provider: ${fallbackConfig.providerType}');
        final fallbackResult =
            await fallbackAdapter.generateCompletion(request, fallbackConfig);
        if (fallbackResult.isRight()) {
          debugPrint(
              '✅ Fallback provider succeeded: ${fallbackConfig.providerType}');
          return fallbackResult;
        }
        debugPrint(
            '❌ Fallback provider also failed: ${fallbackConfig.providerType}');
      }
      // Return the primary failure if both failed or no fallback available
      return primaryResult;
    }

    return Left(LlmFailure('No suitable AI provider available'));
  }

  /// Convenience method for simple prompts
  Future<Either<Failure, String>> ask(String prompt,
      {String? systemPrompt}) async {
    final result = await generateCompletion(
      LlmRequest(prompt: prompt, systemPrompt: systemPrompt),
    );

    return result.map((response) => response.content);
  }
}
