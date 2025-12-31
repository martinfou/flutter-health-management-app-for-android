/// Time of day class for medication scheduling
class TimeOfDay {
  /// Hour (0-23)
  final int hour;

  /// Minute (0-59)
  final int minute;

  /// Creates a TimeOfDay
  TimeOfDay({required this.hour, required this.minute});

  /// Create from string (format: "HH:mm")
  factory TimeOfDay.fromString(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  /// Convert to string (format: "HH:mm")
  @override
  String toString() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Default times for medication scheduling
  static List<TimeOfDay> get defaultTimes => [
        TimeOfDay(hour: 8, minute: 0), // Morning
        TimeOfDay(hour: 12, minute: 0), // Afternoon
        TimeOfDay(hour: 18, minute: 0), // Evening
        TimeOfDay(hour: 22, minute: 0), // Night
      ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeOfDay &&
          runtimeType == other.runtimeType &&
          hour == other.hour &&
          minute == other.minute;

  @override
  int get hashCode => hour.hashCode ^ minute.hashCode;
}

