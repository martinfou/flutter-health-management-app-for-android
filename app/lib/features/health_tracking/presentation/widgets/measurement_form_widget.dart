import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/providers/user_preferences_provider.dart';
import 'package:health_app/core/utils/unit_converter.dart';

/// Form widget for body measurements
class MeasurementFormWidget extends ConsumerWidget {
  final Map<String, TextEditingController> controllers;
  final Function(String, String) onChanged;

  const MeasurementFormWidget({
    super.key,
    required this.controllers,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useImperial = ref.watch(unitPreferenceProvider);
    final unitLabel = UnitConverter.getLengthUnitLabel(useImperial);
    
    final measurements = [
      {'key': 'waist', 'label': 'Waist ($unitLabel)', 'icon': Icons.straighten},
      {'key': 'hips', 'label': 'Hips ($unitLabel)', 'icon': Icons.straighten},
      {'key': 'neck', 'label': 'Neck ($unitLabel)', 'icon': Icons.straighten},
      {'key': 'chest', 'label': 'Chest ($unitLabel)', 'icon': Icons.straighten},
      {'key': 'thigh', 'label': 'Thigh ($unitLabel)', 'icon': Icons.straighten},
    ];

    return Column(
      children: measurements.map((measurement) {
        final key = measurement['key'] as String;
        final label = measurement['label'] as String;
        final icon = measurement['icon'] as IconData;

        return Padding(
          padding: const EdgeInsets.only(bottom: UIConstants.spacingMd),
          child: TextField(
            controller: controllers[key],
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(UIConstants.borderRadiusMd),
              ),
            ),
            onChanged: (value) => onChanged(key, value),
          ),
        );
      }).toList(),
    );
  }
}

