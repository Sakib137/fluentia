/// Skill categories evaluated in the placement test.
enum PlacementCategory {
  grammar('Grammar'),
  vocabulary('Vocabulary'),
  reading('Reading'),
  sentenceCompletion('Sentence Structure'),
  conversation('Everyday Conversation');

  const PlacementCategory(this.displayName);
  final String displayName;
}

/// Model representing a single English placement test question.
class PlacementQuestionModel {
  const PlacementQuestionModel({
    required this.id,
    required this.category,
    required this.difficulty,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    this.context,
  });

  final String id;
  final PlacementCategory category;
  final String difficulty; // e.g. A1, A2, B1, B2
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final String? context;

  bool isCorrect(int selectedIndex) => selectedIndex == correctAnswerIndex;
}

/// Result assessment of the completed placement test.
class PlacementResultModel {
  const PlacementResultModel({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.estimatedLevel,
    required this.levelTitle,
    required this.levelDescription,
    required this.categoryScores,
    required this.categoryRatings,
  });

  final int totalQuestions;
  final int correctAnswers;
  final String estimatedLevel; // e.g. 'B1'
  final String levelTitle; // e.g. 'Intermediate'
  final String levelDescription;
  final Map<PlacementCategory, double> categoryScores; // 0.0 to 1.0
  final Map<PlacementCategory, String> categoryRatings; // e.g. 'Strong area', 'Good foundation', 'Needs practice'

  double get scorePercentage =>
      totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;
}
