import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../llm_provider.dart';
import '../llm_service.dart';
import '../adapters/deepseek_adapter.dart';
import '../adapters/openai_adapter.dart';
import '../adapters/anthropic_adapter.dart';
import '../adapters/ollama_adapter.dart';

/// Provider for the active LLM configuration
final llmConfigProvider = StateProvider<LlmConfig>((ref) {
  // Default to local Ollama with Llama 3
  return const LlmConfig(
    providerType: LlmProviderType.ollama,
    model: 'llama3',
  );
});

/// Provider for the map of available LLM adapters
final llmAdaptersProvider = Provider<Map<LlmProviderType, LlmProvider>>((ref) {
  return {
    LlmProviderType.deepseek: DeepSeekAdapter(),
    LlmProviderType.openai: OpenAiAdapter(),
    LlmProviderType.anthropic: AnthropicAdapter(),
    LlmProviderType.ollama: OllamaAdapter(),
  };
});

/// Provider for the LlmService
final llmServiceProvider = Provider<LlmService>((ref) {
  final adapters = ref.watch(llmAdaptersProvider);
  final initialConfig = ref.watch(llmConfigProvider);
  
  final service = LlmService(
    adapters: adapters,
    initialConfig: initialConfig,
  );

  // Keep the service config in sync with the config provider
  ref.listen(llmConfigProvider, (previous, next) {
    service.updateConfig(next);
  });

  return service;
});
