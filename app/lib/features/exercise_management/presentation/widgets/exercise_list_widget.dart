// Dart SDK
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Packages

// Project
import 'package:health_app/features/exercise_management/domain/entities/exercise.dart';
import 'package:health_app/features/exercise_management/domain/entities/exercise_type.dart';

/// Exercise list widget for displaying list of exercises
class ExerciseListWidget extends StatelessWidget {
  final List<Exercise> exercises;

  const ExerciseListWidget({
    super.key,
    required this.exercises,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Column(
        children: exercises.map((exercise) {
          return ListTile(
            leading: Icon(
              _getExerciseIcon(exercise.type),
              color: _getExerciseColor(exercise.type),
            ),
            title: Text(exercise.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Type: ${exercise.type.displayName}'),
                if (exercise.sets != null && exercise.reps != null)
                  Text('${exercise.sets} sets × ${exercise.reps} reps'),
                if (exercise.weight != null)
                  Text('Weight: ${exercise.weight} kg'),
                if (exercise.duration != null)
                  Text('Duration: ${exercise.duration} min'),
                if (exercise.distance != null)
                  Text('Distance: ${exercise.distance} km'),
                if (exercise.date != null)
                  Text(
                    DateFormat('MMM d, yyyy').format(exercise.date!),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getExerciseIcon(ExerciseType type) {
    switch (type) {
      case ExerciseType.strength:
        return Icons.fitness_center;
      case ExerciseType.cardio:
        return Icons.directions_run;
      case ExerciseType.flexibility:
        return Icons.self_improvement;
      case ExerciseType.other:
        return Icons.sports_gymnastics;
    }
  }

  Color _getExerciseColor(ExerciseType type) {
    switch (type) {
      case ExerciseType.strength:
        return Colors.blue;
      case ExerciseType.cardio:
        return Colors.red;
      case ExerciseType.flexibility:
        return Colors.purple;
      case ExerciseType.other:
        return Colors.grey;
    }
  }
}

