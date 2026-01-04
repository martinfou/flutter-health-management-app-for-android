import 'package:fpdart/fpdart.dart';
import '../errors/failures.dart';

/// Supported LLM Providers
enum LlmProviderType {
  deepseek,
  openai,
  anthropic,
  ollama,
  opencodeZen,
  onDevice, // Gemini Nano via Android AI Core (Pixel 8 Pro+)
}

/// Configuration for an LLM provider
/// AI provider preference
enum AiPreference {
  /// Prefer on-device AI when available, fallback to cloud
  preferOnDevice,

  /// Prefer cloud AI, use on-device only as fallback
  preferCloud,

  /// Always use on-device AI (if available)
  onDeviceOnly,

  /// Always use cloud AI
  cloudOnly,
}

class LlmConfig {
  final LlmProviderType providerType;
  final String model;
  final String? apiKey;
  final String? baseUrl;
  final double temperature;
  final int maxTokens;
  final AiPreference aiPreference;

  const LlmConfig({
    required this.providerType,
    required this.model,
    this.apiKey,
    this.baseUrl,
    this.temperature = 0.7,
    this.maxTokens = 2048,
    this.aiPreference = AiPreference.preferOnDevice,
  });

  LlmConfig copyWith({
    LlmProviderType? providerType,
    String? model,
    String? apiKey,
    String? baseUrl,
    double? temperature,
    int? maxTokens,
    AiPreference? aiPreference,
  }) {
    return LlmConfig(
      providerType: providerType ?? this.providerType,
      model: model ?? this.model,
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      aiPreference: aiPreference ?? this.aiPreference,
    );
  }
}

/// Request for LLM completion
class LlmRequest {
  final String prompt;
  final String? systemPrompt;
  final double? temperature;
  final int? maxTokens;
  final List<Map<String, String>>? history;

  const LlmRequest({
    required this.prompt,
    this.systemPrompt,
    this.temperature,
    this.maxTokens,
    this.history,
  });
}

/// Response from LLM provider
class LlmResponse {
  final String content;
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;
  final String model;

  const LlmResponse({
    required this.content,
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
    required this.model,
  });
}

/// Base interface for LLM providers
abstract class LlmProvider {
  String get name;
  bool get supportsStreaming;

  Future<Either<Failure, LlmResponse>> generateCompletion(
    LlmRequest request,
    LlmConfig config,
  );
}

/// Failure specific to LLM operations
class LlmFailure extends Failure {
  final int? statusCode;

  LlmFailure(super.message, {this.statusCode});
}
