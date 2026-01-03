import 'base_openai_adapter.dart';

/// Adapter for DeepSeek API
class DeepSeekAdapter extends BaseOpenAiAdapter {
  @override
  String get name => 'DeepSeek';

  @override
  String get defaultBaseUrl => 'https://api.deepseek.com';
}
