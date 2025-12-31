import 'package:flutter/material.dart';
import 'package:health_app/core/constants/ui_constants.dart';

/// Widget for selecting hunger/fullness level on a 0-10 scale
/// 
/// 0 = Extremely hungry, 5 = Neutral, 10 = Extremely full
class HungerScaleWidget extends StatefulWidget {
  /// Current selected value (0-10, nullable)
  final int? selectedValue;

  /// Label for the scale (e.g., "Before eating" or "After eating")
  final String label;

  /// Callback when value changes
  final ValueChanged<int?> onChanged;

  /// Creates a hunger scale widget
  const HungerScaleWidget({
    super.key,
    required this.selectedValue,
    required this.label,
    required this.onChanged,
  });

  @override
  State<HungerScaleWidget> createState() => _HungerScaleWidgetState();

  /// Get descriptive label for a scale value
  static String getLabelForValue(int value) {
    switch (value) {
      case 0:
        return 'Extremely hungry';
      case 1:
        return 'Very hungry';
      case 2:
        return 'Hungry';
      case 3:
        return 'Slightly hungry';
      case 4:
        return 'A little hungry';
      case 5:
        return 'Neutral';
      case 6:
        return 'Slightly full';
      case 7:
        return 'Full';
      case 8:
        return 'Very full';
      case 9:
        return 'Extremely full';
      case 10:
        return 'Overfull';
      default:
        return '';
    }
  }
}

class _HungerScaleWidgetState extends State<HungerScaleWidget> {
  late double _sliderValue;

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.selectedValue?.toDouble() ?? 5.0;
  }

  @override
  void didUpdateWidget(HungerScaleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValue != oldWidget.selectedValue) {
      _sliderValue = widget.selectedValue?.toDouble() ?? 5.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentValue = _sliderValue.round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: UIConstants.spacingMd),
        
        // Slider
        Slider(
          value: _sliderValue,
          min: 0,
          max: 10,
          divisions: 10,
          label: currentValue.toString(),
          onChanged: (value) {
            setState(() {
              _sliderValue = value;
            });
            final intValue = value.round();
            widget.onChanged(intValue);
          },
        ),
        
        // Labels for min, middle, and max
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            Text(
              '5',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            Text(
              '10',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: UIConstants.spacingXs),
        
        // Selected value display with descriptive label
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.spacingSm,
            vertical: UIConstants.spacingXs,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(UIConstants.borderRadiusSm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$currentValue/10',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: UIConstants.spacingXs),
              Text(
                '- ${HungerScaleWidget.getLabelForValue(currentValue)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: UIConstants.spacingXs),
        
        // Clear button (to deselect)
        TextButton.icon(
          onPressed: () {
            setState(() {
              _sliderValue = 5.0;
            });
            widget.onChanged(null);
          },
          icon: const Icon(Icons.clear, size: 16),
          label: const Text('Clear'),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: UIConstants.spacingSm),
            minimumSize: const Size(0, 32),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }
}

