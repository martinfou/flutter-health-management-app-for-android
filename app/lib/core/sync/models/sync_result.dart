/// Represents the result of a sync operation across all data types
class SyncResult {
  /// Whether the overall sync was successful (all data types synced without errors)
  final bool success;

  /// Total number of items synced across all data types
  final int totalSynced;

  /// List of data types that failed to sync (error messages)
  final Map<String, String> partialFailures;

  /// When this sync operation completed
  final DateTime timestamp;

  /// Human-readable summary message
  final String? summaryMessage;

  const SyncResult({
    required this.success,
    required this.totalSynced,
    required this.partialFailures,
    required this.timestamp,
    this.summaryMessage,
  });

  /// Whether there were any partial failures
  bool get hasPartialFailures => partialFailures.isNotEmpty;

  /// Number of data types that failed
  int get failureCount => partialFailures.length;

  /// Create a copy with modified fields
  SyncResult copyWith({
    bool? success,
    int? totalSynced,
    Map<String, String>? partialFailures,
    DateTime? timestamp,
    String? summaryMessage,
  }) {
    return SyncResult(
      success: success ?? this.success,
      totalSynced: totalSynced ?? this.totalSynced,
      partialFailures: partialFailures ?? this.partialFailures,
      timestamp: timestamp ?? this.timestamp,
      summaryMessage: summaryMessage ?? this.summaryMessage,
    );
  }

  @override
  String toString() =>
      'SyncResult(success: $success, totalSynced: $totalSynced, failures: ${partialFailures.length}, timestamp: $timestamp)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncResult &&
          runtimeType == other.runtimeType &&
          success == other.success &&
          totalSynced == other.totalSynced &&
          partialFailures == other.partialFailures &&
          timestamp == other.timestamp;

  @override
  int get hashCode =>
      success.hashCode ^
      totalSynced.hashCode ^
      partialFailures.hashCode ^
      timestamp.hashCode;
}
