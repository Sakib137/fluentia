/// Question model for multi-question listening comprehension passages.
class ComprehensionQuestion {
  const ComprehensionQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
  });

  final String id;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String? explanation;

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'options': options,
    'correctAnswer': correctAnswer,
    if (explanation != null) 'explanation': explanation,
  };

  factory ComprehensionQuestion.fromJson(Map<String, dynamic> json) {
    return ComprehensionQuestion(
      id: json['id'] as String? ?? '',
      question: json['question'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)?.cast<String>() ?? const [],
      correctAnswer: json['correctAnswer'] as String? ?? '',
      explanation: json['explanation'] as String?,
    );
  }
}
