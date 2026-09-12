import 'package:flutter_test/flutter_test.dart';
import 'package:fluentia/features/reading/domain/services/reading_scoring.dart';

void main() {
  group('ReadingScoring unit tests', () {
    test('normalizeText trims, lowercases, and strips punctuation', () {
      expect(
        ReadingScoring.normalizeText('   Artificial Intelligence!  '),
        equals('artificial intelligence'),
      );
      expect(
        ReadingScoring.normalizeText("It's a step-by-step process."),
        equals('its a stepbystep process'),
      );
      expect(
        ReadingScoring.normalizeText('Extra    whitespace     collapse.'),
        equals('extra whitespace collapse'),
      );
    });

    test('isAnswerCorrect works for multipleChoice', () {
      expect(ReadingScoring.isAnswerCorrect('Option B', 'Option B'), isTrue);
      expect(ReadingScoring.isAnswerCorrect('option b', 'Option B'), isTrue);
      expect(ReadingScoring.isAnswerCorrect('Option A', 'Option B'), isFalse);
    });

    test('isAnswerCorrect works for trueFalse format', () {
      expect(ReadingScoring.isAnswerCorrect('True', 'True'), isTrue);
      expect(ReadingScoring.isAnswerCorrect('true', 'True'), isTrue);
      expect(ReadingScoring.isAnswerCorrect('False', 'True'), isFalse);
    });

    test('isAnswerCorrect works with accepted alternatives', () {
      const accepted = ['Deep-sea vents', 'Ocean hydrothermal vents', 'Vents'];

      expect(
        ReadingScoring.isAnswerCorrect(
          'deep sea vents',
          'Deep sea vents',
          accepted,
        ),
        isTrue,
      );
      expect(
        ReadingScoring.isAnswerCorrect(
          'deep-sea vents',
          'Deep sea vents',
          accepted,
        ),
        isTrue,
      );
      expect(
        ReadingScoring.isAnswerCorrect(
          'ocean hydrothermal vents',
          'Deep sea vents',
          accepted,
        ),
        isTrue,
      );
      expect(
        ReadingScoring.isAnswerCorrect('vents', 'Deep sea vents', accepted),
        isTrue,
      );
      expect(
        ReadingScoring.isAnswerCorrect('mountains', 'Deep sea vents', accepted),
        isFalse,
      );
    });

    test('calculateScorePercentage handles calculations and edge cases', () {
      expect(
        ReadingScoring.calculateScorePercentage(correctCount: 3, totalCount: 4),
        equals(75.0),
      );
      expect(
        ReadingScoring.calculateScorePercentage(correctCount: 0, totalCount: 5),
        equals(0.0),
      );
      expect(
        ReadingScoring.calculateScorePercentage(correctCount: 5, totalCount: 5),
        equals(100.0),
      );
      expect(
        ReadingScoring.calculateScorePercentage(correctCount: 0, totalCount: 0),
        equals(0.0),
      );
    });

    test('calculateApproxWpm computes words per minute accurately', () {
      // 100 words in 30 seconds -> 200 WPM
      expect(
        ReadingScoring.calculateApproxWpm(
          wordCount: 100,
          duration: const Duration(seconds: 30),
        ),
        equals(200),
      );

      // 150 words in 1 minute -> 150 WPM
      expect(
        ReadingScoring.calculateApproxWpm(
          wordCount: 150,
          duration: const Duration(minutes: 1),
        ),
        equals(150),
      );

      // Zero or negative duration safeguards
      expect(
        ReadingScoring.calculateApproxWpm(
          wordCount: 150,
          duration: Duration.zero,
        ),
        equals(0),
      );

      // Less than 5 seconds returns 0 to avoid skewed division
      expect(
        ReadingScoring.calculateApproxWpm(
          wordCount: 150,
          duration: const Duration(seconds: 4),
        ),
        equals(0),
      );
    });

    test('generateImprovementInsight produces actionable feedback', () {
      final high = ReadingScoring.generateImprovementInsight(
        scorePercentage: 95.0,
        approxWpm: 220,
        level: 'B2',
      );
      expect(high, contains('Outstanding pace'));

      final low = ReadingScoring.generateImprovementInsight(
        scorePercentage: 40.0,
        approxWpm: 90,
        level: 'B1',
      );
      expect(low, contains('Take your time reading'));
    });
  });
}
