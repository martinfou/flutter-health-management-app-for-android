import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../../core/constants/ui_constants.dart';
import '../../../../core/llm/providers/use_case_providers.dart';
import '../../../user_profile/presentation/providers/user_profile_repository_provider.dart';

/// Provider to hold the current meal suggestion
final currentMealSuggestionProvider = StateProvider<String?>((ref) => null);

/// Widget to request and display AI meal suggestions
class AiMealSuggestionWidget extends ConsumerStatefulWidget {
  const AiMealSuggestionWidget({super.key});

  @override
  ConsumerState<AiMealSuggestionWidget> createState() => _AiMealSuggestionWidgetState();
}

class _AiMealSuggestionWidgetState extends ConsumerState<AiMealSuggestionWidget> {
  bool _isLoading = false;

  Future<void> _getSuggestion() async {
    setState(() => _isLoading = true);
    
    try {
      final userProfileRepo = ref.read(userProfileRepositoryProvider);
      final userResult = await userProfileRepo.getCurrentUserProfile();
      
      await userResult.fold(
        (failure) async {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${failure.message}')),
            );
          }
        },
        (profile) async {
          final useCase = ref.read(suggestMealsUseCaseProvider);
          final result = await useCase.execute(userId: profile.id);

          result.fold(
            (failure) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to get suggestions: ${failure.message}')),
                );
              }
            },
            (suggestion) {
              ref.read(currentMealSuggestionProvider.notifier).state = suggestion;
            },
          );
        },
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final suggestion = ref.watch(currentMealSuggestionProvider);
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant, color: theme.colorScheme.primary),
                const SizedBox(width: UIConstants.spacingSm),
                Text(
                  'AI Meal Suggestions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (suggestion != null || _isLoading)
              const SizedBox(height: UIConstants.spacingMd),
            
            if (_isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: UIConstants.spacingMd),
                    Text('Finding the perfect meal for your macros...'),
                  ],
                ),
              )
            else if (suggestion != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MarkdownBody(
                    data: suggestion,
                    selectable: true,
                  ),
                  const SizedBox(height: UIConstants.spacingMd),
                  Center(
                    child: TextButton.icon(
                      onPressed: _getSuggestion,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Get New Suggestions'),
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  const SizedBox(height: UIConstants.spacingSm),
                  const Text(
                    'Get personalized meal ideas that fit your remaining macros for today.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: UIConstants.spacingMd),
                  ElevatedButton.icon(
                    onPressed: _getSuggestion,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Suggest Meals'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
