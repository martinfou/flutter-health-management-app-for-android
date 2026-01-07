import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../../core/constants/ui_constants.dart';
import '../../../../core/llm/providers/use_case_providers.dart';
import '../../../user_profile/presentation/providers/user_profile_repository_provider.dart';
import '../../domain/entities/weekly_review_insight.dart';

/// Provider to hold the current weekly review insight
final weeklyReviewInsightProvider = StateProvider<WeeklyReviewInsight?>((ref) => null);

/// Widget to display AI-generated weekly health insights
class WeeklyReviewInsightsWidget extends ConsumerStatefulWidget {
  const WeeklyReviewInsightsWidget({super.key});

  @override
  ConsumerState<WeeklyReviewInsightsWidget> createState() => _WeeklyReviewInsightsWidgetState();
}

class _WeeklyReviewInsightsWidgetState extends ConsumerState<WeeklyReviewInsightsWidget> {
  bool _isLoading = false;

  Future<void> _generateReview() async {
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
          final useCase = ref.read(generateWeeklyReviewUseCaseProvider);
          final result = await useCase.execute(
            userId: profile.id,
            endDate: DateTime.now(),
          );

          result.fold(
            (failure) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to generate review: ${failure.message}')),
                );
              }
            },
            (insight) {
              ref.read(weeklyReviewInsightProvider.notifier).state = insight;
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
    final insight = ref.watch(weeklyReviewInsightProvider);
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
                Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
                const SizedBox(width: UIConstants.spacingSm),
                Text(
                  'AI Weekly Health Review',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.spacingMd),
            
            if (insight == null && !_isLoading)
              Column(
                children: [
                   const Text(
                    'Get a personalized analysis of your health trends, sleep, and weight progress for the past week.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: UIConstants.spacingSm),
                  Text(
                    'Note: Requires at least 1 day of data. 4-7 days of tracking provides the best quality insights.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: UIConstants.spacingMd),
                  ElevatedButton.icon(
                    onPressed: _generateReview,
                    icon: const Icon(Icons.psychology),
                    label: const Text('Generate Review'),
                  ),
                ],
              )
            else if (_isLoading)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: UIConstants.spacingMd),
                  Text('Analyzing your health data...'),
                ],
              )
            else if (insight != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Review for ${insight.startDate.toLocal().toString().split(' ')[0]} to ${insight.endDate.toLocal().toString().split(' ')[0]}',
                    style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                  ),
                  const Divider(),
                  MarkdownBody(
                    data: insight.content,
                    selectable: true,
                  ),
                  const SizedBox(height: UIConstants.spacingMd),
                  Center(
                    child: TextButton.icon(
                      onPressed: _generateReview,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Regenerate'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
