import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../../core/constants/ui_constants.dart';
import '../../../../core/llm/providers/use_case_providers.dart';
import '../../../user_profile/presentation/providers/user_profile_repository_provider.dart';
import '../../domain/entities/exercise.dart';

/// Provider to hold the current workout adaptation
final currentWorkoutAdaptationProvider = StateProvider<String?>((ref) => null);

/// Widget to request and display AI workout modifications
class AiWorkoutAdaptationWidget extends ConsumerStatefulWidget {
  final Exercise? selectedExercise;

  const AiWorkoutAdaptationWidget({
    super.key,
    this.selectedExercise,
  });

  @override
  ConsumerState<AiWorkoutAdaptationWidget> createState() => _AiWorkoutAdaptationWidgetState();
}

class _AiWorkoutAdaptationWidgetState extends ConsumerState<AiWorkoutAdaptationWidget> {
  final TextEditingController _feedbackController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _getAdaptation() async {
    if (widget.selectedExercise == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or log an exercise first.')),
      );
      return;
    }

    if (_feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide some feedback or describe your concern.')),
      );
      return;
    }

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
          final useCase = ref.read(adaptWorkoutUseCaseProvider);
          final result = await useCase.execute(
            userId: profile.id,
            currentExercise: widget.selectedExercise!,
            feedback: _feedbackController.text.trim(),
          );

          result.fold(
            (failure) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to get modifications: ${failure.message}')),
                );
              }
            },
            (adaptation) {
              ref.read(currentWorkoutAdaptationProvider.notifier).state = adaptation;
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
    final adaptation = ref.watch(currentWorkoutAdaptationProvider);
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
                Icon(Icons.fitness_center, color: theme.colorScheme.primary),
                const SizedBox(width: UIConstants.spacingSm),
                Text(
                  'AI Workout Adaptation',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.spacingMd),
            
            if (adaptation == null && !_isLoading)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Need a modification? Describe how you feel (e.g., "knee pain", "too easy") and get AI-powered adjustments.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: UIConstants.spacingMd),
                  TextField(
                    controller: _feedbackController,
                    decoration: const InputDecoration(
                      hintText: 'e.g., knee pain during squats, need a home alternative',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: UIConstants.spacingMd),
                  ElevatedButton.icon(
                    onPressed: _getAdaptation,
                    icon: const Icon(Icons.psychology),
                    label: const Text('Get Modifications'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                    ),
                  ),
                ],
              )
            else if (_isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: UIConstants.spacingMd),
                    Text('Analyzing and adapting your workout...'),
                  ],
                ),
              )
            else if (adaptation != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MarkdownBody(
                    data: adaptation,
                    selectable: true,
                  ),
                  const SizedBox(height: UIConstants.spacingMd),
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        ref.read(currentWorkoutAdaptationProvider.notifier).state = null;
                        _feedbackController.clear();
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Try Another Feedback'),
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
