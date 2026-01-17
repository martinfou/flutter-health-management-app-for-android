import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import '../llm_provider.dart';
import '../../errors/failures.dart';

/// Base class for OpenAI-compatible LLM adapters
abstract class BaseOpenAiAdapter implements LlmProvider {
  @override
  bool get supportsStreaming => false; // Streaming implementation deferred

  @override
  Future<Either<Failure, LlmResponse>> generateCompletion(
    LlmRequest request,
    LlmConfig config,
  ) async {
    final apiKey = config.apiKey;
    final baseUrl = config.baseUrl ?? defaultBaseUrl;

    if (apiKey == null || apiKey.isEmpty) {
      return Left(LlmFailure('API Key is required for $name'));
    }

    // Log LLM request
    debugPrint('🤖 LLM Request [$name]: ${config.model} via $baseUrl');
    debugPrint('   Prompt (${request.prompt.length} chars):');
    debugPrint(request.prompt);
    if (request.systemPrompt != null) {
      debugPrint('   System Prompt (${request.systemPrompt!.length} chars):');
      debugPrint(request.systemPrompt!);
    }

    try {
      final messages = <Map<String, String>>[];

      if (request.systemPrompt != null) {
        messages.add({'role': 'system', 'content': request.systemPrompt!});
      }

      if (request.history != null) {
        messages.addAll(request.history!);
      }

      messages.add({'role': 'user', 'content': request.prompt});

      final response = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': config.model,
          'messages': messages,
          'temperature': request.temperature ?? config.temperature,
          'max_tokens': request.maxTokens ?? config.maxTokens,
        }),
      );

      if (response.statusCode != 200) {
        // Log API error
        debugPrint('❌ LLM Error [$name]: HTTP ${response.statusCode}');
        debugPrint('   Error Response:');
        debugPrint(response.body);

        return Left(LlmFailure(
          'API request failed with status ${response.statusCode}: ${response.body}',
          statusCode: response.statusCode,
        ));
      }

      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'] as String;
      final usage = data['usage'];

      // Log successful response
      debugPrint(
          '✅ LLM Response [$name]: ${content.length} chars, ${usage['total_tokens'] ?? 0} tokens');
      debugPrint('   Response:');
      debugPrint(content);

      return Right(LlmResponse(
        content: content,
        promptTokens: usage['prompt_tokens'] ?? 0,
        completionTokens: usage['completion_tokens'] ?? 0,
        totalTokens: usage['total_tokens'] ?? 0,
        model: data['model'] ?? config.model,
      ));
    } catch (e) {
      // Log unexpected error
      debugPrint('💥 LLM Exception [$name]: $e');

      return Left(LlmFailure('Unexpected error during completion: $e'));
    }
  }

  String get defaultBaseUrl;
}
