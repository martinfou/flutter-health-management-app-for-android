import 'base_openai_adapter.dart';

/// Adapter for OpenAI API
class OpenAiAdapter extends BaseOpenAiAdapter {
  @override
  String get name => 'OpenAI';

  @override
  String get defaultBaseUrl => 'https://api.openai.com/v1';
}
