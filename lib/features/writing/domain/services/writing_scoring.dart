/// Evaluation status of user's writing length relative to requested bounds.
enum WritingLengthStatus { empty, belowMinimum, targetRange, aboveMaximum }

/// Pure deterministic service for text normalization, word/sentence counting,
/// objective answer verification, and constructive feedback generation.
class WritingScoring {
  WritingScoring._();

  /// Normalizes text for objective comparison by trimming, lowercasing,
  /// removing punctuation, and collapsing multiple whitespace characters.
  static String normalizeText(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Reliably counts whitespace-separated words in user input.
  ///
  /// Examples:
  /// - "" -> 0
  /// - "   " -> 0
  /// - "Hello, world!" -> 2
  /// - "  One   two   three  " -> 3
  static int countWords(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }

  /// Accurately counts sentences based on terminal punctuation marks (. ! ?).
  static int countSentences(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;

    final parts = trimmed.split(RegExp(r'[.!?]+'));
    int count = 0;
    for (final part in parts) {
      if (part.trim().isNotEmpty && RegExp(r'\w').hasMatch(part)) {
        count++;
      }
    }
    return count > 0 ? count : (trimmed.isNotEmpty ? 1 : 0);
  }

  /// Evaluates whether an objective answer (Sentence Builder or Complete the Sentence)
  /// matches the expected sentence or any pre-approved acceptable variants.
  static bool isObjectiveAnswerCorrect({
    required String userAnswer,
    required String expectedAnswer,
    List<String> acceptedAnswers = const [],
  }) {
    final normUser = normalizeText(userAnswer);
    if (normUser.isEmpty) return false;

    if (normUser == normalizeText(expectedAnswer)) return true;

    for (final alt in acceptedAnswers) {
      if (normUser == normalizeText(alt)) return true;
    }

    return false;
  }

  /// Determines the word count range status relative to target constraints.
  static WritingLengthStatus checkWordCountRange({
    required int wordCount,
    required int minWords,
    required int maxWords,
  }) {
    if (wordCount <= 0) return WritingLengthStatus.empty;
    if (minWords > 0 && wordCount < minWords) {
      return WritingLengthStatus.belowMinimum;
    }
    if (maxWords > 0 && wordCount > maxWords) {
      return WritingLengthStatus.aboveMaximum;
    }
    return WritingLengthStatus.targetRange;
  }

  /// Generates a supportive, measurable improvement suggestion without making
  /// unsupported AI claims about grammatical accuracy.
  static String generateImprovementSuggestion({
    required int wordCount,
    required int sentenceCount,
    required int minWords,
    required int maxWords,
    required bool isObjective,
    bool? isCorrect,
  }) {
    if (isObjective) {
      if (isCorrect == true) {
        return 'Excellent! Your sentence construction matches standard English grammar and natural word order.';
      } else {
        return 'Review the expected sentence structure above to see the conventional word order.';
      }
    }

    final status = checkWordCountRange(
      wordCount: wordCount,
      minWords: minWords,
      maxWords: maxWords,
    );

    switch (status) {
      case WritingLengthStatus.empty:
        return 'Write a response before submitting to complete this practice.';
      case WritingLengthStatus.belowMinimum:
        final needed = minWords - wordCount;
        return 'Add a few more details ($needed more word${needed == 1 ? '' : 's'}) to reach the recommended length.';
      case WritingLengthStatus.aboveMaximum:
        final excess = wordCount - maxWords;
        return 'Your response is $excess word${excess == 1 ? '' : 's'} above the target. Consider editing for conciseness.';
      case WritingLengthStatus.targetRange:
        if (sentenceCount <= 1 && wordCount > 25) {
          return 'Good length! Try breaking longer thoughts into multiple clear sentences.';
        }
        return 'Good length. Your response meets the target word count.';
    }
  }
}
