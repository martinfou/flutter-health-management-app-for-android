import 'package:health_app/features/nutrition_management/domain/entities/eating_reason_category.dart';

/// Eating reason enumeration
/// 
/// Represents reasons why a user is eating.
/// Used for behavioral tracking and pattern analysis.
enum EatingReason {
  hungry,
  stressed,
  celebration,
  bored,
  tired,
  scheduled,
  social,
  craving;

  /// Display name for UI
  String get displayName {
    switch (this) {
      case EatingReason.hungry:
        return 'Hungry';
      case EatingReason.stressed:
        return 'Stressed';
      case EatingReason.celebration:
        return 'Celebration';
      case EatingReason.bored:
        return 'Bored';
      case EatingReason.tired:
        return 'Tired';
      case EatingReason.scheduled:
        return 'Time to Eat';
      case EatingReason.social:
        return 'Social';
      case EatingReason.craving:
        return 'Craving';
    }
  }

  /// Description for tooltips/help text
  String get description {
    switch (this) {
      case EatingReason.hungry:
        return 'Physical hunger';
      case EatingReason.stressed:
        return 'Eating due to stress';
      case EatingReason.celebration:
        return 'Celebrating or special occasion';
      case EatingReason.bored:
        return 'Eating out of boredom';
      case EatingReason.tired:
        return 'Eating due to fatigue';
      case EatingReason.scheduled:
        return 'Scheduled meal time';
      case EatingReason.social:
        return 'Eating in a social setting';
      case EatingReason.craving:
        return 'Eating due to food craving';
    }
  }

  /// Category for grouping in UI
  EatingReasonCategory get category {
    switch (this) {
      case EatingReason.hungry:
      case EatingReason.tired:
      case EatingReason.scheduled:
        return EatingReasonCategory.physical;
      case EatingReason.stressed:
      case EatingReason.bored:
      case EatingReason.craving:
        return EatingReasonCategory.emotional;
      case EatingReason.celebration:
      case EatingReason.social:
        return EatingReasonCategory.social;
    }
  }

  /// Icon identifier for UI (can be used with icon mapping)
  String get iconName {
    switch (this) {
      case EatingReason.hungry:
        return 'restaurant';
      case EatingReason.stressed:
        return 'mood_bad';
      case EatingReason.celebration:
        return 'celebration';
      case EatingReason.bored:
        return 'sentiment_dissatisfied';
      case EatingReason.tired:
        return 'bedtime';
      case EatingReason.scheduled:
        return 'schedule';
      case EatingReason.social:
        return 'groups';
      case EatingReason.craving:
        return 'cake';
    }
  }

  /// Get all eating reasons grouped by category
  static Map<EatingReasonCategory, List<EatingReason>> get groupedByCategory {
    final grouped = <EatingReasonCategory, List<EatingReason>>{};
    for (final reason in EatingReason.values) {
      final category = reason.category;
      grouped.putIfAbsent(category, () => []).add(reason);
    }
    return grouped;
  }
}

