import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import '../llm_provider.dart';
import '../../errors/failures.dart';
import 'base_openai_adapter.dart';

/// Adapter for Ollama (Local LLM)
/// Ollama provides an OpenAI-compatible /v1 endpoint
/// Note: Ollama doesn't require an API key for local usage
class OllamaAdapter extends BaseOpenAiAdapter {
  @override
  String get name => 'Ollama';

  @override
  String get defaultBaseUrl => 'http://192.168.5.17:11434/v1';

  /// Override generateCompletion to skip API key requirement for local Ollama
  @override
  Future<Either<Failure, LlmResponse>> generateCompletion(
    LlmRequest request,
    LlmConfig config,
  ) async {
    final baseUrl = config.baseUrl ?? defaultBaseUrl;

    try {
      final messages = <Map<String, String>>[];
      
      if (request.systemPrompt != null) {
        messages.add({'role': 'system', 'content': request.systemPrompt!});
      }

      if (request.history != null) {
        messages.addAll(request.history!);
      }

      messages.add({'role': 'user', 'content': request.prompt});

      // Ollama doesn't require Authorization header for local usage
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      final requestBody = {
        'model': config.model,
        'messages': messages,
        'temperature': request.temperature ?? config.temperature,
        'max_tokens': request.maxTokens ?? config.maxTokens,
      };

      final requestUrl = '$baseUrl/chat/completions';

      // Log the request
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔄 Ollama Request');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('URL: $requestUrl');
      debugPrint('Method: POST');
      debugPrint('Headers: $headers');
      debugPrint('Body:');
      debugPrint(const JsonEncoder.withIndent('  ').convert(requestBody));
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await http.post(
        Uri.parse(requestUrl),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      // Log the response
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('✅ Ollama Response');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Headers: ${response.headers}');
      
      if (response.statusCode != 200) {
        debugPrint('❌ Error Response Body:');
        debugPrint(response.body);
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return Left(LlmFailure(
          'Ollama API request failed with status ${response.statusCode}: ${response.body}',
          statusCode: response.statusCode,
        ));
      }

      final data = jsonDecode(response.body);
      debugPrint('Response Body:');
      debugPrint(const JsonEncoder.withIndent('  ').convert(data));
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final content = data['choices'][0]['message']['content'] as String;
      final usage = data['usage'];

      // Log summary
      debugPrint('📊 Response Summary:');
      debugPrint('  Model: ${data['model'] ?? config.model}');
      debugPrint('  Content Length: ${content.length} characters');
      debugPrint('  Prompt Tokens: ${usage['prompt_tokens'] ?? 0}');
      debugPrint('  Completion Tokens: ${usage['completion_tokens'] ?? 0}');
      debugPrint('  Total Tokens: ${usage['total_tokens'] ?? 0}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      return Right(LlmResponse(
        content: content,
        promptTokens: usage['prompt_tokens'] ?? 0,
        completionTokens: usage['completion_tokens'] ?? 0,
        totalTokens: usage['total_tokens'] ?? 0,
        model: data['model'] ?? config.model,
      ));
    } catch (e) {
      return Left(LlmFailure('Unexpected error during Ollama completion: $e'));
    }
  }
}
