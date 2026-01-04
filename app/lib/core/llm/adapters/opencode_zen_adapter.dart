import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import '../llm_provider.dart';
import '../../errors/failures.dart';
import 'base_openai_adapter.dart';

/// Adapter for OpenCode Zen API (Free API from opencode.ai)
/// OpenCode Zen provides OpenAI-compatible endpoints with free access
class OpenCodeZenAdapter extends BaseOpenAiAdapter {
  @override
  String get name => 'OpenCode Zen';

  @override
  String get defaultBaseUrl => 'https://opencode.ai/zen/v1';

  /// Override generateCompletion to add enhanced logging
  @override
  Future<Either<Failure, LlmResponse>> generateCompletion(
    LlmRequest request,
    LlmConfig config,
  ) async {
    final apiKey = config.apiKey;
    final baseUrl = config.baseUrl ?? defaultBaseUrl;

    if (apiKey == null || apiKey.isEmpty) {
      return Left(LlmFailure('API Key is required for $name. Get your free API key from https://opencode.ai/zen'));
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

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
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
      debugPrint('🔄 OpenCode Zen Request');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('URL: $requestUrl');
      debugPrint('Method: POST');
      debugPrint('Headers: ${headers.keys.join(", ")} (API key hidden)');
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
      debugPrint('✅ OpenCode Zen Response');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Headers: ${response.headers}');
      
      if (response.statusCode != 200) {
        debugPrint('❌ Error Response Body:');
        debugPrint(response.body);
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return Left(LlmFailure(
          'OpenCode Zen API request failed with status ${response.statusCode}: ${response.body}',
          statusCode: response.statusCode,
        ));
      }

      // Log raw response body first
      debugPrint('Raw Response Body (first 500 chars):');
      final bodyPreview = response.body.length > 500 
          ? '${response.body.substring(0, 500)}...' 
          : response.body;
      debugPrint(bodyPreview);
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // Try to parse as JSON
      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint('Response Body (parsed JSON):');
        debugPrint(const JsonEncoder.withIndent('  ').convert(data));
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      } catch (jsonError) {
        debugPrint('❌ Failed to parse response as JSON: $jsonError');
        debugPrint('Full response body:');
        debugPrint(response.body);
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return Left(LlmFailure(
          'OpenCode Zen API returned invalid JSON response. Content-Type: ${response.headers['content-type']}, Error: $jsonError',
        ));
      }

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
    } catch (e, stackTrace) {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ Exception during OpenCode Zen completion:');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      return Left(LlmFailure('Unexpected error during OpenCode Zen completion: $e'));
    }
  }
}

