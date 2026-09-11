import '../models/speaking_activity.dart';
import '../models/speaking_metrics.dart';
import '../models/speaking_mode.dart';
import 'text_comparison_service.dart';

/// Contract abstracting speaking analysis for current local derivation and future AI expansion.
abstract class SpeakingAnalysisService {
  /// Analyzes recognized speech against the activity parameters.
  Future<SpeakingMetrics> analyze({
    required SpeakingActivity activity,
    required String recognizedText,
    required Duration speakingDuration,
  });
}

/// Local offline implementation deriving honest metrics without cloud AI calls.
class LocalSpeakingAnalysisService implements SpeakingAnalysisService {
  const LocalSpeakingAnalysisService([
    this._comparisonService = const TextComparisonService(),
  ]);

  final TextComparisonService _comparisonService;

  @override
  Future<SpeakingMetrics> analyze({
    required SpeakingActivity activity,
    required String recognizedText,
    required Duration speakingDuration,
  }) async {
    final durationSeconds = speakingDuration.inSeconds;
    final words = TextComparisonService.tokenizeWords(recognizedText);
    final wordCount = words.length;

    // Approximate words per minute
    final wpm = (durationSeconds > 0 && wordCount > 0)
        ? ((wordCount / (durationSeconds / 60.0)).round()).clamp(0, 300)
        : 0;

    // Mode 1: Read Aloud comparison
    if (activity.mode == SpeakingMode.readAloud && activity.hasExpectedText) {
      final comp = _comparisonService.compare(
        expectedText: activity.expectedText!,
        recognizedText: recognizedText,
      );

      final nextRec = comp.matchPercentage >= 90.0
          ? 'Challenge yourself with an Upper-Intermediate or Advanced sentence next.'
          : 'Read the sentence once silently before speaking to master the word order.';

      return SpeakingMetrics(
        durationSeconds: durationSeconds,
        wordCount: wordCount,
        wordsPerMinute: wpm,
        matchPercentage: comp.matchPercentage,
        feedbackMessage: comp.feedbackMessage,
        nextRecommendation: nextRec,
        wordTokens: comp.wordTokens,
        missingWords: comp.missingWords,
        recognizedTranscript: recognizedText,
        expectedTranscript: activity.expectedText,
      );
    }

    // Modes 2, 3, 4: Free Speaking (Speak About It, Quick Response, Daily Speaking)
    if (wordCount == 0 || recognizedText.trim().isEmpty) {
      return SpeakingMetrics(
        durationSeconds: durationSeconds,
        wordCount: 0,
        wordsPerMinute: 0,
        feedbackMessage:
            'No speech was recognized. Please try again in a quieter environment.',
        nextRecommendation:
            'Speak closer to the microphone and articulate your thoughts clearly.',
        recognizedTranscript: '',
      );
    }

    // Honest feedback based on measurable volume and duration
    final String feedback;
    final String nextRecommendation;

    if (activity.mode == SpeakingMode.quickResponse) {
      if (wordCount < 12) {
        feedback =
            'Nice start. In quick response, try to answer with at least two full sentences.';
        nextRecommendation =
            'Use the 10-second preparation time to outline your main thought.';
      } else if (wordCount <= 35) {
        feedback = 'Good job! You delivered a concise and spontaneous answer.';
        nextRecommendation =
            'Try connecting your sentences with words like "because" or "also".';
      } else {
        feedback =
            'Great response! You spoke smoothly and filled the time effectively.';
        nextRecommendation =
            'Keep up the prompt pacing in real-world conversations.';
      }
    } else {
      // Speak About It / Daily Speaking
      if (wordCount < 20 || durationSeconds < 15) {
        feedback =
            'Nice start. Try speaking for a little longer to expand your thoughts.';
        nextRecommendation =
            'Add one more detail or an example to your answer next time.';
      } else if (wordCount <= 55) {
        feedback =
            'Good job keeping your answer going. You maintained a steady response.';
        nextRecommendation =
            'Try expanding on your reasoning to sustain your speech even further.';
      } else {
        feedback = 'Great work! Your response was detailed and sustained.';
        nextRecommendation =
            'Focus on varied vocabulary and natural sentence connectors next time.';
      }
    }

    return SpeakingMetrics(
      durationSeconds: durationSeconds,
      wordCount: wordCount,
      wordsPerMinute: wpm,
      matchPercentage: null,
      feedbackMessage: feedback,
      nextRecommendation: nextRecommendation,
      recognizedTranscript: recognizedText,
    );
  }
}
