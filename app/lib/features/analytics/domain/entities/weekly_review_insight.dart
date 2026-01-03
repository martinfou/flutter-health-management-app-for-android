/// Entity representing an AI-generated weekly health review insight
class WeeklyReviewInsight {
  final String id;
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final String content;
  final String model;
  final DateTime generatedAt;

  const WeeklyReviewInsight({
    required this.id,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.content,
    required this.model,
    required this.generatedAt,
  });

  /// Create a copy with updated fields
  WeeklyReviewInsight copyWith({
    String? id,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    String? content,
    String? model,
    DateTime? generatedAt,
  }) {
    return WeeklyReviewInsight(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      content: content ?? this.content,
      model: model ?? this.model,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }
}
