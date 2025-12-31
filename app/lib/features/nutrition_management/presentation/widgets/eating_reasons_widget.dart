import 'package:flutter/material.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/features/nutrition_management/domain/entities/eating_reason.dart';
import 'package:health_app/features/nutrition_management/domain/entities/eating_reason_category.dart';

/// Widget for selecting eating reasons (multi-select)
/// 
/// Groups reasons by category (Physical, Emotional, Social)
class EatingReasonsWidget extends StatelessWidget {
  /// Currently selected eating reasons
  final Set<EatingReason> selectedReasons;

  /// Callback when selection changes
  final ValueChanged<Set<EatingReason>> onChanged;

  /// Creates an eating reasons widget
  const EatingReasonsWidget({
    super.key,
    required this.selectedReasons,
    required this.onChanged,
  });

  /// Get icon for eating reason
  static IconData _getIconForReason(EatingReason reason) {
    switch (reason.iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'mood_bad':
        return Icons.mood_bad;
      case 'celebration':
        return Icons.celebration;
      case 'sentiment_dissatisfied':
        return Icons.sentiment_dissatisfied;
      case 'bedtime':
        return Icons.bedtime;
      case 'schedule':
        return Icons.schedule;
      case 'groups':
        return Icons.groups;
      case 'cake':
        return Icons.cake;
      default:
        return Icons.restaurant_menu;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groupedReasons = EatingReason.groupedByCategory;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Why are you eating? (Select all that apply)',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: UIConstants.spacingSm),

        // Display reasons grouped by category
        ...EatingReasonCategory.values.map((category) {
          final reasons = groupedReasons[category] ?? [];
          if (reasons.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: UIConstants.spacingSm,
                  bottom: UIConstants.spacingXs,
                ),
                child: Text(
                  category.displayName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              Wrap(
                spacing: UIConstants.spacingXs,
                runSpacing: UIConstants.spacingXs,
                children: reasons.map((reason) {
                  final isSelected = selectedReasons.contains(reason);
                  return FilterChip(
                    selected: isSelected,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getIconForReason(reason),
                          size: 18,
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                        ),
                        const SizedBox(width: UIConstants.spacingXs),
                        Text(reason.displayName),
                      ],
                    ),
                    onSelected: (selected) {
                      final newSet = Set<EatingReason>.from(selectedReasons);
                      if (selected) {
                        newSet.add(reason);
                      } else {
                        newSet.remove(reason);
                      }
                      onChanged(newSet);
                    },
                    selectedColor: theme.colorScheme.primaryContainer,
                    checkmarkColor: theme.colorScheme.onPrimaryContainer,
                    side: BorderSide(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withOpacity(0.5),
                      width: isSelected ? 2 : 1,
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        }),

        const SizedBox(height: UIConstants.spacingXs),

        // Selected reasons summary
        if (selectedReasons.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(UIConstants.spacingSm),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(UIConstants.borderRadiusSm),
            ),
            child: Wrap(
              spacing: UIConstants.spacingXs,
              runSpacing: UIConstants.spacingXs,
              children: selectedReasons.map((reason) {
                return Chip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getIconForReason(reason),
                        size: 16,
                      ),
                      const SizedBox(width: UIConstants.spacingXs),
                      Text(
                        reason.displayName,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  backgroundColor: theme.colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                );
              }).toList(),
            ),
          )
        else
          Text(
            'Tap chips to select (optional)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
      ],
    );
  }
}

