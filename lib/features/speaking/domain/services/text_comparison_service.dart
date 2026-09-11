import 'dart:math' as math;
import '../models/speaking_metrics.dart';

/// Result container for normalized Read Aloud sentence comparison.
class TextComparisonResult {
  const TextComparisonResult({
    required this.expectedText,
    required this.recognizedText,
    required this.matchedWords,
    required this.missingWords,
    required this.extraWords,
    required this.differentWords,
    required this.matchPercentage,
    required this.wordTokens,
    required this.feedbackMessage,
  });

  final String expectedText;
  final String recognizedText;
  final List<String> matchedWords;
  final List<String> missingWords;
  final List<String> extraWords;
  final List<String> differentWords;
  final double matchPercentage; // 0.0 - 100.0
  final List<WordDiffToken> wordTokens;
  final String feedbackMessage;
}

/// Reusable service comparing expected text with recognized speech.
class TextComparisonService {
  const TextComparisonService();

  /// Normalizes text by lowercasing, removing punctuation, and collapsing whitespace.
  static String normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'''[.,!?;:'"“”’()[\]{}—\-_/\\#@$%^&*~`]'''), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Splits text into normalized words list.
  static List<String> tokenizeWords(String text) {
    final cleaned = normalize(text);
    if (cleaned.isEmpty) return const [];
    return cleaned.split(' ').where((w) => w.isNotEmpty).toList();
  }

  /// Compares [expectedText] with [recognizedText] using word-level alignment.
  TextComparisonResult compare({
    required String expectedText,
    required String recognizedText,
  }) {
    final expectedWords = tokenizeWords(expectedText);
    final recognizedWords = tokenizeWords(recognizedText);

    if (expectedWords.isEmpty && recognizedWords.isEmpty) {
      return TextComparisonResult(
        expectedText: expectedText,
        recognizedText: recognizedText,
        matchedWords: const [],
        missingWords: const [],
        extraWords: const [],
        differentWords: const [],
        matchPercentage: 100.0,
        wordTokens: const [],
        feedbackMessage: 'No text to compare.',
      );
    }

    if (recognizedWords.isEmpty) {
      final tokens = expectedWords
          .map(
            (w) => WordDiffToken(
              text: w,
              status: WordMatchStatus.missing,
              expectedText: w,
            ),
          )
          .toList();

      return TextComparisonResult(
        expectedText: expectedText,
        recognizedText: recognizedText,
        matchedWords: const [],
        missingWords: List.from(expectedWords),
        extraWords: const [],
        differentWords: const [],
        matchPercentage: 0.0,
        wordTokens: tokens,
        feedbackMessage:
            'No speech was recognized. Please try again in a quieter environment.',
      );
    }

    // Levenshtein sequence alignment on words
    final m = expectedWords.length;
    final n = recognizedWords.length;

    // dp[i][j] stores minimum operations to transform expected[0..i) to recognized[0..j)
    final dp = List.generate(m + 1, (_) => List<int>.filled(n + 1, 0));

    for (int i = 0; i <= m; i++) {
      dp[i][0] = i;
    }
    for (int j = 0; j <= n; j++) {
      dp[0][j] = j;
    }

    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        if (expectedWords[i - 1] == recognizedWords[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1];
        } else {
          final substitution = dp[i - 1][j - 1] + 1;
          final deletion = dp[i - 1][j] + 1;
          final insertion = dp[i][j - 1] + 1;
          dp[i][j] = math.min(substitution, math.min(deletion, insertion));
        }
      }
    }

    // Backtrack to extract aligned operations
    int i = m;
    int j = n;
    final List<WordDiffToken> reversedTokens = [];
    final List<String> matched = [];
    final List<String> missing = [];
    final List<String> extra = [];
    final List<String> different = [];

    while (i > 0 || j > 0) {
      if (i > 0 && j > 0 && expectedWords[i - 1] == recognizedWords[j - 1]) {
        final word = expectedWords[i - 1];
        reversedTokens.add(
          WordDiffToken(
            text: word,
            status: WordMatchStatus.matched,
            expectedText: word,
            recognizedText: word,
          ),
        );
        matched.add(word);
        i--;
        j--;
      } else if (i > 0 && j > 0 && dp[i][j] == dp[i - 1][j - 1] + 1) {
        final exp = expectedWords[i - 1];
        final rec = recognizedWords[j - 1];
        reversedTokens.add(
          WordDiffToken(
            text: '$exp ($rec)',
            status: WordMatchStatus.different,
            expectedText: exp,
            recognizedText: rec,
          ),
        );
        different.add(exp);
        i--;
        j--;
      } else if (i > 0 && dp[i][j] == dp[i - 1][j] + 1) {
        final exp = expectedWords[i - 1];
        reversedTokens.add(
          WordDiffToken(
            text: exp,
            status: WordMatchStatus.missing,
            expectedText: exp,
          ),
        );
        missing.add(exp);
        i--;
      } else {
        final rec = recognizedWords[j - 1];
        reversedTokens.add(
          WordDiffToken(
            text: rec,
            status: WordMatchStatus.extra,
            recognizedText: rec,
          ),
        );
        extra.add(rec);
        j--;
      }
    }

    final tokens = reversedTokens.reversed.toList();
    final matchedWords = matched.reversed.toList();
    final missingWords = missing.reversed.toList();
    final extraWords = extra.reversed.toList();
    final differentWords = different.reversed.toList();

    // Match percentage based on expected words matched
    final double matchPercentage = m > 0
        ? ((matchedWords.length / m) * 100.0).clamp(0.0, 100.0)
        : 0.0;

    // Generate accurate, encouraging, and honest feedback
    final String feedback;
    if (matchPercentage >= 95.0 && extraWords.isEmpty) {
      feedback =
          'Excellent match. You spoke the sentence clearly and accurately.';
    } else if (missingWords.isNotEmpty) {
      final missingPhrase = missingWords.take(4).join(' ');
      feedback = 'Good effort. You missed: "$missingPhrase".';
    } else if (differentWords.isNotEmpty) {
      feedback =
          'Good match. Notice the difference in: "${differentWords.take(3).join(', ')}".';
    } else if (matchPercentage >= 75.0) {
      feedback = 'Good match. Review the highlighted words and try again.';
    } else {
      feedback = 'Keep practicing. Take your time to speak each word clearly.';
    }

    return TextComparisonResult(
      expectedText: expectedText,
      recognizedText: recognizedText,
      matchedWords: matchedWords,
      missingWords: missingWords,
      extraWords: extraWords,
      differentWords: differentWords,
      matchPercentage: matchPercentage,
      wordTokens: tokens,
      feedbackMessage: feedback,
    );
  }
}
