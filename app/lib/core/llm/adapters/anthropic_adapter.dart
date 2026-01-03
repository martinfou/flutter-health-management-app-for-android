import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import '../llm_provider.dart';
import '../../errors/failures.dart';

/// Adapter for Anthropic API (Claude)
class AnthropicAdapter implements LlmProvider {
  @override
  String get name => 'Anthropic';

  @override
  bool get supportsStreaming => false;

  @override
  Future<Either<Failure, LlmResponse>> generateCompletion(
    LlmRequest request,
    LlmConfig config,
  ) async {
    final apiKey = config.apiKey;
    final baseUrl = config.baseUrl ?? 'https://api.anthropic.com/v1';

    if (apiKey == null || apiKey.isEmpty) {
      return Left(LlmFailure('API Key is required for Anthropic'));
    }

    try {
      final messages = <Map<String, String>>[];
      
      if (request.history != null) {
        messages.addAll(request.history!);
      }

      messages.add({'role': 'user', 'content': request.prompt});

      final response = await http.post(
        Uri.parse('$baseUrl/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': config.model,
          'system': request.systemPrompt,
          'messages': messages,
          'max_tokens': request.maxTokens ?? config.maxTokens,
          'temperature': request.temperature ?? config.temperature,
        }),
      );

      if (response.statusCode != 200) {
        return Left(LlmFailure(
          'Anthropic API request failed with status ${response.statusCode}: ${response.body}',
          statusCode: response.statusCode,
        ));
      }

      final data = jsonDecode(response.body);
      final content = data['content'][0]['text'] as String;
      final usage = data['usage'];

      return Right(LlmResponse(
        content: content,
        promptTokens: usage['input_tokens'] ?? 0,
        completionTokens: usage['output_tokens'] ?? 0,
        totalTokens: (usage['input_tokens'] ?? 0) + (usage['output_tokens'] ?? 0),
        model: data['model'] ?? config.model,
      ));
    } catch (e) {
      return Left(LlmFailure('Unexpected error during Anthropic completion: $e'));
    }
  }
}
