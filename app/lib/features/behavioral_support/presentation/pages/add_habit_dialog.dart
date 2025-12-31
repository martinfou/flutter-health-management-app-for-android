import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/widgets/custom_button.dart';
import 'package:health_app/features/behavioral_support/domain/entities/habit_category.dart';
import 'package:health_app/features/behavioral_support/presentation/providers/behavioral_repository_provider.dart';
import 'package:health_app/features/behavioral_support/presentation/providers/behavioral_providers.dart';
import 'package:health_app/features/user_profile/presentation/providers/user_profile_repository_provider.dart';
import 'package:health_app/features/behavioral_support/domain/entities/habit.dart';

/// Dialog for adding a new habit
class AddHabitDialog extends ConsumerStatefulWidget {
  const AddHabitDialog({super.key});

  @override
  ConsumerState<AddHabitDialog> createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends ConsumerState<AddHabitDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  HabitCategory _category = HabitCategory.exercise;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryOptions = HabitCategory.values;

    return AlertDialog(
      title: const Text('Add Habit'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Habit Name',
                  hintText: 'e.g., Daily Walk',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter habit name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: UIConstants.spacingMd),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'e.g., Walk 10,000 steps',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: UIConstants.spacingMd),
              DropdownButtonFormField<HabitCategory>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                ),
                items: categoryOptions.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _category = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        CustomButton(
          label: _isLoading ? 'Adding...' : 'Add',
          onPressed: _isLoading ? null : _saveHabit,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userProfileRepo = ref.read(userProfileRepositoryProvider);
      final userResult = await userProfileRepo.getCurrentUserProfile();

      final userId = userResult.fold(
        (failure) => null,
        (profile) => profile.id,
      );

      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not found')),
          );
        }
        return;
      }

      final repository = ref.read(behavioralRepositoryProvider);
      final now = DateTime.now();
      final habitId = 'habit-${now.millisecondsSinceEpoch}-${now.microsecondsSinceEpoch}';

      final habit = Habit(
        id: habitId,
        userId: userId,
        name: _nameController.text.trim(),
        category: _category,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        completedDates: [],
        currentStreak: 0,
        longestStreak: 0,
        startDate: now,
        createdAt: now,
        updatedAt: now,
      );

      final result = await repository.saveHabit(habit);

      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${failure.message}')),
            );
          }
        },
        (_) {
          ref.invalidate(habitsProvider);
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Habit added successfully')),
            );
          }
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

