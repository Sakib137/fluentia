/// Pure utility class for text normalization, answer matching, speed calculation, and feedback generation.
class ReadingScoring {
  ReadingScoring._();

  /// Normalizes text for comparison by trimming, collapsing spaces, removing punctuation, and lowercasing.
  static String normalizeText(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Evaluates whether a user's answer matches the target answer or any accepted alternate answers.
  static bool isAnswerCorrect(
    String userAnswer,
    String correctAnswer, [
    List<String> acceptedAnswers = const [],
  ]) {
    final normUser = normalizeText(userAnswer);
    if (normUser.isEmpty) return false;

    if (normUser == normalizeText(correctAnswer)) return true;

    for (final alt in acceptedAnswers) {
      if (normUser == normalizeText(alt)) return true;
    }

    return false;
  }

  /// Calculates approximate reading speed in Words Per Minute (WPM).
  ///
  /// WPM = words / minutes.
  /// If duration is less than 5 seconds, returns 0 to prevent skewed division.
  static int calculateApproxWpm({
    required int wordCount,
    required Duration duration,
  }) {
    if (wordCount <= 0 || duration.inSeconds < 5) return 0;
    final minutes = duration.inSeconds / 60.0;
    return (wordCount / minutes).round();
  }

  /// Calculates accuracy score percentage.
  static double calculateScorePercentage({
    required int correctCount,
    required int totalCount,
  }) {
    if (totalCount <= 0) return 0.0;
    return (correctCount / totalCount * 100.0).clamp(0.0, 100.0);
  }

  /// Generates a concise, constructive improvement insight based on accuracy and reading pacing.
  static String generateImprovementInsight({
    required double scorePercentage,
    required int approxWpm,
    required String level,
  }) {
    if (scorePercentage >= 90.0) {
      if (approxWpm >= 200) {
        return 'Outstanding pace and high comprehension. You grasp complex nuances effortlessly.';
      } else {
        return 'Excellent accuracy. Focus on maintaining this sharp comprehension as you naturally build reading cadence.';
      }
    } else if (scorePercentage >= 70.0) {
      return 'Solid understanding of the main text. Re-read ambiguous paragraphs before finalizing answers to eliminate small errors.';
    } else if (scorePercentage >= 50.0) {
      return 'Good foundation. Try scanning paragraph topic sentences first to capture the central theme before answering details.';
    } else {
      return 'Take your time reading each paragraph carefully. Tap vocabulary terms for context clues whenever words feel unfamiliar.';
    }
  }
}
