import '../models/writing_activity.dart';
import 'writing_scoring.dart';

/// The evaluated outcome of a user's writing submission.
class WritingEvaluationResult {
  const WritingEvaluationResult({
    required this.userAnswer,
    required this.wordCount,
    required this.sentenceCount,
    required this.characterCount,
    required this.isObjective,
    this.isCorrect,
    required this.lengthStatus,
    required this.improvementSuggestion,
    this.expectedAnswer,
    this.sampleAnswer,
    this.checkedItemsCount = 0,
    this.totalChecklistItems = 0,
  });

  final String userAnswer;
  final int wordCount;
  final int sentenceCount;
  final int characterCount;
  final bool isObjective;
  final bool? isCorrect;
  final WritingLengthStatus lengthStatus;
  final String improvementSuggestion;
  final String? expectedAnswer;
  final String? sampleAnswer;
  final int checkedItemsCount;
  final int totalChecklistItems;

  /// Whether the user achieved full compliance on checklist items (if applicable).
  bool get isChecklistComplete =>
      totalChecklistItems == 0 || checkedItemsCount >= totalChecklistItems;

  /// Effective accuracy score (0.0 - 1.0) for objective drills, or length fulfillment for open writing.
  double get score {
    if (isObjective) {
      return (isCorrect == true) ? 1.0 : 0.0;
    }
    if (lengthStatus == WritingLengthStatus.targetRange) {
      return 1.0;
    }
    if (lengthStatus == WritingLengthStatus.aboveMaximum) {
      return 0.85;
    }
    if (lengthStatus == WritingLengthStatus.belowMinimum) {
      return wordCount > 0 ? 0.6 : 0.0;
    }
    return 0.0;
  }
}

/// Abstract contract for evaluating writing practice responses.
///
/// Designed to be completely offline-first now, while accommodating future AI evaluation.
abstract class WritingEvaluationService {
  WritingEvaluationResult evaluate({
    required WritingActivity activity,
    required String userAnswer,
    Set<int> checkedChecklistIndices = const {},
  });
}

/// Production offline implementation providing deterministic, honest metrics.
class LocalWritingEvaluationService implements WritingEvaluationService {
  const LocalWritingEvaluationService();

  @override
  WritingEvaluationResult evaluate({
    required WritingActivity activity,
    required String userAnswer,
    Set<int> checkedChecklistIndices = const {},
  }) {
    final wordCount = WritingScoring.countWords(userAnswer);
    final sentenceCount = WritingScoring.countSentences(userAnswer);
    final characterCount = userAnswer.length;

    bool? isCorrect;
    if (activity.isObjective && activity.expectedAnswer != null) {
      isCorrect = WritingScoring.isObjectiveAnswerCorrect(
        userAnswer: userAnswer,
        expectedAnswer: activity.expectedAnswer!,
        acceptedAnswers: activity.acceptedAnswers,
      );
    }

    final lengthStatus = WritingScoring.checkWordCountRange(
      wordCount: wordCount,
      minWords: activity.minimumWords,
      maxWords: activity.maximumWords,
    );

    final suggestion = WritingScoring.generateImprovementSuggestion(
      wordCount: wordCount,
      sentenceCount: sentenceCount,
      minWords: activity.minimumWords,
      maxWords: activity.maximumWords,
      isObjective: activity.isObjective,
      isCorrect: isCorrect,
    );

    return WritingEvaluationResult(
      userAnswer: userAnswer,
      wordCount: wordCount,
      sentenceCount: sentenceCount,
      characterCount: characterCount,
      isObjective: activity.isObjective,
      isCorrect: isCorrect,
      lengthStatus: lengthStatus,
      improvementSuggestion: suggestion,
      expectedAnswer: activity.expectedAnswer,
      sampleAnswer: activity.sampleAnswer,
      checkedItemsCount: checkedChecklistIndices.length,
      totalChecklistItems: activity.checklist.length,
    );
  }
}
