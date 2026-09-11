import '../../data/models/placement_question_model.dart';

/// Pure business logic for evaluating English placement assessment results.
class PlacementTestEvaluator {
  const PlacementTestEvaluator._();

  /// Evaluates answers against provided questions and generates a qualitative result.
  static PlacementResultModel evaluate({
    required List<PlacementQuestionModel> questions,
    required Map<int, int>
    selectedAnswers, // questionIndex -> selectedOptionIndex
  }) {
    if (questions.isEmpty) {
      return const PlacementResultModel(
        totalQuestions: 0,
        correctAnswers: 0,
        estimatedLevel: 'B1',
        levelTitle: 'Intermediate',
        levelDescription: 'Default baseline for self-paced learning.',
        categoryScores: {},
        categoryRatings: {},
      );
    }

    int correctCount = 0;
    final categoryTotals = <PlacementCategory, int>{};
    final categoryCorrects = <PlacementCategory, int>{};

    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      categoryTotals[q.category] = (categoryTotals[q.category] ?? 0) + 1;

      final selectedAnswer = selectedAnswers[i];
      if (selectedAnswer != null && q.isCorrect(selectedAnswer)) {
        correctCount++;
        categoryCorrects[q.category] = (categoryCorrects[q.category] ?? 0) + 1;
      }
    }

    // Determine estimated CEFR level
    final (estimatedLevel, levelTitle, levelDescription) = _determineLevel(
      correctCount,
      questions.length,
    );

    // Calculate category percentages and qualitative labels
    final categoryScores = <PlacementCategory, double>{};
    final categoryRatings = <PlacementCategory, String>{};

    for (final entry in categoryTotals.entries) {
      final category = entry.key;
      final total = entry.value;
      final correct = categoryCorrects[category] ?? 0;
      final ratio = total > 0 ? correct / total : 0.0;

      categoryScores[category] = ratio;
      categoryRatings[category] = _categoryRating(ratio);
    }

    return PlacementResultModel(
      totalQuestions: questions.length,
      correctAnswers: correctCount,
      estimatedLevel: estimatedLevel,
      levelTitle: levelTitle,
      levelDescription: levelDescription,
      categoryScores: categoryScores,
      categoryRatings: categoryRatings,
    );
  }

  static (String level, String title, String description) _determineLevel(
    int correct,
    int total,
  ) {
    final ratio = total > 0 ? correct / total : 0.0;

    if (ratio >= 0.80) {
      return (
        'B2',
        'Upper Intermediate',
        'You possess strong comprehension and command of nuanced English structures. Fluentia will refine your conversational spontaneity and advanced stylistic expression.',
      );
    } else if (ratio >= 0.55) {
      return (
        'B1',
        'Intermediate',
        'You have a solid functional grasp of English in familiar situations. Fluentia will expand your vocabulary depth, sentence complexity, and speaking ease.',
      );
    } else if (ratio >= 0.30) {
      return (
        'A2',
        'Elementary',
        'You understand essential phrases and everyday communicative contexts. Fluentia will build consistent habit loops to elevate your confidence and listening agility.',
      );
    } else {
      return (
        'A1',
        'Beginner',
        'You are building your foundation in English. Fluentia will guide you with structured high-frequency vocabulary, essential speech patterns, and clear explanations.',
      );
    }
  }

  static String _categoryRating(double ratio) {
    if (ratio >= 0.75) {
      return 'Strong area';
    } else if (ratio >= 0.40) {
      return 'Good foundation';
    } else {
      return 'Needs practice';
    }
  }
}
