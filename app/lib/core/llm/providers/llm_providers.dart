import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../llm_provider.dart';
import '../llm_service.dart';
import '../adapters/deepseek_adapter.dart';
import '../adapters/openai_adapter.dart';
import '../adapters/anthropic_adapter.dart';
import '../adapters/ollama_adapter.dart';
import '../adapters/opencode_zen_adapter.dart';
import '../adapters/on_device_adapter.dart';

/// Provider for the active LLM configuration
final llmConfigProvider = StateProvider<LlmConfig>((ref) {
  // Default to OpenCode Zen (free API from opencode.ai)
  // Users need to set their API key in settings
  return const LlmConfig(
    providerType: LlmProviderType.opencodeZen,
    model:
        'big-pickle', // Default model (OpenCode Zen model ID), can be changed in settings
    aiPreference: AiPreference
        .preferOnDevice, // Default to preferring on-device when available
  );
});

/// Provider for the map of available LLM adapters
final llmAdaptersProvider = Provider<Map<LlmProviderType, LlmProvider>>((ref) {
  return {
    LlmProviderType.deepseek: DeepSeekAdapter(),
    LlmProviderType.openai: OpenAiAdapter(),
    LlmProviderType.anthropic: AnthropicAdapter(),
    LlmProviderType.ollama: OllamaAdapter(),
    LlmProviderType.opencodeZen: OpenCodeZenAdapter(),
    LlmProviderType.onDevice: OnDeviceLlmAdapter(),
  };
});

/// Provider for checking on-device AI availability
final onDeviceAiAvailableProvider = FutureProvider<bool>((ref) async {
  final adapter = ref.watch(llmAdaptersProvider)[LlmProviderType.onDevice];
  if (adapter is OnDeviceLlmAdapter) {
    return adapter.isAvailable();
  }
  return false;
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
