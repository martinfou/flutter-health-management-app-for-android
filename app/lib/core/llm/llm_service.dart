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
  Future<Either<Failure, LlmResponse>> generateCompletion(LlmRequest request) async {
    final adapter = _adapters[_activeConfig.providerType];
    
    if (adapter == null) {
      return Left(LlmFailure('No adapter found for provider: ${_activeConfig.providerType}'));
    }

    return adapter.generateCompletion(request, _activeConfig);
  }

  /// Convenience method for simple prompts
  Future<Either<Failure, String>> ask(String prompt, {String? systemPrompt}) async {
    final result = await generateCompletion(
      LlmRequest(prompt: prompt, systemPrompt: systemPrompt),
    );
    
    return result.map((response) => response.content);
  }
}
