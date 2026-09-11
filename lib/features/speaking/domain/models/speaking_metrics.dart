/// Individual word comparison token for accessible text diff rendering.
enum WordMatchStatus { matched, missing, extra, different }

class WordDiffToken {
  const WordDiffToken({
    required this.text,
    required this.status,
    this.expectedText,
    this.recognizedText,
  });

  final String text;
  final WordMatchStatus status;
  final String? expectedText;
  final String? recognizedText;

  bool get isMatched => status == WordMatchStatus.matched;
  bool get isMissing => status == WordMatchStatus.missing;
  bool get isExtra => status == WordMatchStatus.extra;
  bool get isDifferent => status == WordMatchStatus.different;
}

/// Metrics derived honestly from on-device speech transcription and local timing.
class SpeakingMetrics {
  const SpeakingMetrics({
    required this.durationSeconds,
    required this.wordCount,
    required this.wordsPerMinute,
    this.matchPercentage,
    required this.feedbackMessage,
    required this.nextRecommendation,
    this.wordTokens = const [],
    this.missingWords = const [],
    this.recognizedTranscript = '',
    this.expectedTranscript,
  });

  final int durationSeconds;
  final int wordCount;
  final int wordsPerMinute; // Clearly marked as approximate
  final double? matchPercentage; // Only for Read Aloud (0.0 - 100.0)
  final String feedbackMessage;
  final String nextRecommendation;
  final List<WordDiffToken> wordTokens;
  final List<String> missingWords;
  final String recognizedTranscript;
  final String? expectedTranscript;

  bool get hasExpectedText =>
      expectedTranscript != null && expectedTranscript!.isNotEmpty;
  bool get hasSpeechRecognized =>
      wordCount > 0 && recognizedTranscript.trim().isNotEmpty;
}
