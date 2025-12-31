import 'package:flutter/material.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/features/medication_management/domain/entities/medication.dart';

/// Widget displaying a medication card in the medications list
class MedicationCardWidget extends StatelessWidget {
  /// Medication to display
  final Medication medication;

  /// Callback when medication is tapped
  final VoidCallback? onTap;

  /// Creates a medication card widget
  const MedicationCardWidget({
    super.key,
    required this.medication,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: UIConstants.spacingSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusMd),
        child: Padding(
          padding: const EdgeInsets.all(UIConstants.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                medication.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: UIConstants.spacingSm,
                                vertical: UIConstants.spacingXs,
                              ),
                              decoration: BoxDecoration(
                                color: medication.isActive
                                    ? Colors.green.withValues(alpha: 0.2)
                                    : Colors.grey.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(UIConstants.borderRadiusSm),
                              ),
                              child: Text(
                                medication.isActive ? 'Active' : 'Inactive',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: medication.isActive
                                      ? Colors.green.shade700
                                      : Colors.grey.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: UIConstants.spacingXs),
                        Text(
                          '${medication.dosage} • ${medication.frequency.displayName}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        if (medication.times.isNotEmpty) ...[
                          const SizedBox(height: UIConstants.spacingXs),
                          Wrap(
                            spacing: UIConstants.spacingXs,
                            children: medication.times.map((time) {
                              return Chip(
                                label: Text(
                                  time.toString(),
                                  style: theme.textTheme.bodySmall,
                                ),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                labelPadding: const EdgeInsets.symmetric(
                                  horizontal: UIConstants.spacingXs,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

