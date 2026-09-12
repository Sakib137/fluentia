import 'dart:math' as math;

/// Status for individual words in dictation diffing.
enum DictationWordStatus {
  correct,
  missing,
  extra;

  String get displayName => switch (this) {
    correct => 'Correct',
    missing => 'Missing',
    extra => 'Extra Word',
  };
}

/// Token representation of a word analyzed in dictation.
class DictationWordItem {
  const DictationWordItem({required this.word, required this.status});

  final String word;
  final DictationWordStatus status;
}

/// Measurable result returned from dictation scoring.
class DictationResult {
  const DictationResult({
    required this.isExactMatch,
    required this.matchedWordsCount,
    required this.totalExpectedWords,
    required this.accuracyPercentage,
    required this.wordItems,
    required this.correctWords,
    required this.missingWords,
    required this.extraWords,
    required this.summaryText,
    this.measurementNote =
        'Measures text-based listening comprehension only, not pronunciation.',
  });

  final bool isExactMatch;
  final int matchedWordsCount;
  final int totalExpectedWords;
  final double accuracyPercentage;
  final List<DictationWordItem> wordItems;
  final List<String> correctWords;
  final List<String> missingWords;
  final List<String> extraWords;
  final String summaryText;
  final String measurementNote;
}

/// Pure utility class providing standardized scoring, normalization, and diffing.
class ListeningScoring {
  ListeningScoring._();

  /// Normalizes user text inputs for deterministic comparison:
  /// - Converts to lowercase
  /// - Strips basic punctuation (!, ?, ., ,, ;, :, ", ', (, ), -, _)
  /// - Trims and collapses multiple contiguous whitespace characters into a single space.
  static String normalizeText(String input) {
    return input
        .toLowerCase()
        // Replace common punctuation with space to prevent glued words
        .replaceAll(RegExp(r'[.,!?;:()\[\]"{}_—-]'), ' ')
        // Remove apostrophes directly (e.g. o'clock -> oclock, don't -> dont)
        .replaceAll("'", '')
        .replaceAll('’', '')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Extracts clean token list from a string after normalization.
  static List<String> tokenize(String input) {
    final normalized = normalizeText(input);
    if (normalized.isEmpty) return const [];
    return normalized.split(' ').where((w) => w.isNotEmpty).toList();
  }

  /// Evaluates exact match or accepted alternate answers.
  static bool evaluateTextAnswer({
    required String userAnswer,
    required String expectedAnswer,
    List<String> acceptedAnswers = const [],
  }) {
    final normUser = normalizeText(userAnswer);
    final normExpected = normalizeText(expectedAnswer);

    if (normUser == normExpected) return true;

    for (final alt in acceptedAnswers) {
      if (normUser == normalizeText(alt)) {
        return true;
      }
    }
    return false;
  }

  /// Evaluates True/False statement answers.
  static bool evaluateTrueFalse({
    required bool userChoice,
    required bool expectedValue,
  }) {
    return userChoice == expectedValue;
  }

  /// Evaluates Multiple Choice option selection.
  static bool evaluateMultipleChoice({
    required String selectedOption,
    required String correctOption,
  }) {
    return normalizeText(selectedOption) == normalizeText(correctOption);
  }

  /// Evaluates Fill in the Missing Words blanks.
  /// [userAnswers] maps blank index (0-based) to user-entered word.
  /// [expectedWords] contains the expected missing words in order.
  static Map<int, bool> evaluateMissingWords({
    required Map<int, String> userAnswers,
    required List<String> expectedWords,
  }) {
    final results = <int, bool>{};
    for (var i = 0; i < expectedWords.length; i++) {
      final userWord = userAnswers[i] ?? '';
      results[i] = normalizeText(userWord) == normalizeText(expectedWords[i]);
    }
    return results;
  }

  /// Performs accurate Longest Common Subsequence (LCS) token diffing for Dictation.
  static DictationResult evaluateDictation({
    required String userText,
    required String expectedTranscript,
  }) {
    final userTokens = tokenize(userText);
    final expectedTokens = tokenize(expectedTranscript);

    if (expectedTokens.isEmpty) {
      return const DictationResult(
        isExactMatch: true,
        matchedWordsCount: 0,
        totalExpectedWords: 0,
        accuracyPercentage: 100.0,
        wordItems: [],
        correctWords: [],
        missingWords: [],
        extraWords: [],
        summaryText: 'Empty transcript.',
      );
    }

    final n = expectedTokens.length;
    final m = userTokens.length;

    // Build LCS dynamic programming matrix
    final dp = List.generate(n + 1, (_) => List<int>.filled(m + 1, 0));
    for (var i = 1; i <= n; i++) {
      for (var j = 1; j <= m; j++) {
        if (expectedTokens[i - 1] == userTokens[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1] + 1;
        } else {
          dp[i][j] = math.max(dp[i - 1][j], dp[i][j - 1]);
        }
      }
    }

    // Backtrack to construct aligned diff
    final wordItems = <DictationWordItem>[];
    final correctWords = <String>[];
    final missingWords = <String>[];
    final extraWords = <String>[];

    var i = n;
    var j = m;
    final reversedItems = <DictationWordItem>[];

    while (i > 0 || j > 0) {
      if (i > 0 && j > 0 && expectedTokens[i - 1] == userTokens[j - 1]) {
        final word = expectedTokens[i - 1];
        reversedItems.add(
          DictationWordItem(word: word, status: DictationWordStatus.correct),
        );
        correctWords.add(word);
        i--;
        j--;
      } else if (j > 0 && (i == 0 || dp[i][j - 1] >= dp[i - 1][j])) {
        final word = userTokens[j - 1];
        reversedItems.add(
          DictationWordItem(word: word, status: DictationWordStatus.extra),
        );
        extraWords.add(word);
        j--;
      } else if (i > 0) {
        final word = expectedTokens[i - 1];
        reversedItems.add(
          DictationWordItem(word: word, status: DictationWordStatus.missing),
        );
        missingWords.add(word);
        i--;
      }
    }

    wordItems.addAll(reversedItems.reversed);
    correctWords.setAll(0, correctWords.reversed.toList());
    missingWords.setAll(0, missingWords.reversed.toList());
    extraWords.setAll(0, extraWords.reversed.toList());

    final matchedWords = correctWords.length;
    final accuracy = (matchedWords / n * 100).clamp(0.0, 100.0);
    final isExact = matchedWords == n && extraWords.isEmpty;

    final summary =
        '$matchedWords of $n words matched (${accuracy.toStringAsFixed(0)}%).';

    return DictationResult(
      isExactMatch: isExact,
      matchedWordsCount: matchedWords,
      totalExpectedWords: n,
      accuracyPercentage: accuracy,
      wordItems: wordItems,
      correctWords: correctWords,
      missingWords: missingWords,
      extraWords: extraWords,
      summaryText: summary,
    );
  }
}
