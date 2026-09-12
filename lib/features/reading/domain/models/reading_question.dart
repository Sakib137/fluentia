/// Supported question formats in Reading Lab.
enum ReadingQuestionType {
  multipleChoice('multipleChoice'),
  trueFalse('trueFalse'),
  mainIdea('mainIdea'),
  vocabularyInContext('vocabularyInContext'),
  shortAnswer('shortAnswer');

  const ReadingQuestionType(this.id);
  final String id;

  static ReadingQuestionType fromId(String id) {
    return ReadingQuestionType.values.firstWhere(
      (t) => t.id.toLowerCase() == id.toLowerCase(),
      orElse: () => ReadingQuestionType.multipleChoice,
    );
  }
}

/// Represents a single question in a Reading Lab activity.
class ReadingQuestion {
  const ReadingQuestion({
    required this.id,
    required this.question,
    required this.type,
    this.options = const [],
    required this.correctAnswer,
    this.acceptedAnswers = const [],
    this.explanation,
    this.targetWord,
    this.paragraphIndex,
  });

  final String id;
  final String question;
  final ReadingQuestionType type;
  final List<String> options;
  final String correctAnswer;
  final List<String> acceptedAnswers;
  final String? explanation;
  final String? targetWord;
  final int? paragraphIndex;

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'type': type.id,
    'options': options,
    'correctAnswer': correctAnswer,
    'acceptedAnswers': acceptedAnswers,
    'explanation': explanation,
    'targetWord': targetWord,
    'paragraphIndex': paragraphIndex,
  };

  factory ReadingQuestion.fromJson(Map<String, dynamic> json) {
    return ReadingQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      type: ReadingQuestionType.fromId(
        json['type'] as String? ?? 'multipleChoice',
      ),
      options: (json['options'] as List<dynamic>?)?.cast<String>() ?? const [],
      correctAnswer: json['correctAnswer'] as String,
      acceptedAnswers:
          (json['acceptedAnswers'] as List<dynamic>?)?.cast<String>() ??
          const [],
      explanation: json['explanation'] as String?,
      targetWord: json['targetWord'] as String?,
      paragraphIndex: json['paragraphIndex'] as int?,
    );
  }
}
