import 'package:flutter/material.dart';
import 'package:health_app/core/constants/ui_constants.dart';

/// Form widget for body measurements
class MeasurementFormWidget extends StatelessWidget {
  final Map<String, TextEditingController> controllers;
  final Function(String, String) onChanged;

  const MeasurementFormWidget({
    super.key,
    required this.controllers,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final measurements = [
      {'key': 'waist', 'label': 'Waist (cm)', 'icon': Icons.straighten},
      {'key': 'hips', 'label': 'Hips (cm)', 'icon': Icons.straighten},
      {'key': 'neck', 'label': 'Neck (cm)', 'icon': Icons.straighten},
      {'key': 'chest', 'label': 'Chest (cm)', 'icon': Icons.straighten},
      {'key': 'thigh', 'label': 'Thigh (cm)', 'icon': Icons.straighten},
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

