import 'package:flutter_test/flutter_test.dart';
import 'package:fluentia/features/writing/domain/services/writing_scoring.dart';

void main() {
  group('WritingScoring Deterministic Services', () {
    test('normalizeText collapses whitespace and strips punctuation', () {
      expect(WritingScoring.normalizeText('Hello, World!'), 'hello world');
      expect(
        WritingScoring.normalizeText(
          '   Because my train was delayed,   I arrived late! ',
        ),
        'because my train was delayed i arrived late',
      );
      expect(WritingScoring.normalizeText(''), '');
    });

    test(
      'countWords accurately handles empty, whitespace, and punctuation',
      () {
        expect(WritingScoring.countWords(''), 0);
        expect(WritingScoring.countWords('   '), 0);
        expect(WritingScoring.countWords('word'), 1);
        expect(WritingScoring.countWords('  Two words  '), 2);
        expect(WritingScoring.countWords('One, two, three, four!'), 4);
        expect(
          WritingScoring.countWords(
            'First line.\nSecond line with five words.',
          ),
          7,
        );
      },
    );

    test('countSentences detects sentence terminators', () {
      expect(WritingScoring.countSentences(''), 0);
      expect(WritingScoring.countSentences('   '), 0);
      expect(WritingScoring.countSentences('This is one sentence.'), 1);
      expect(
        WritingScoring.countSentences('First sentence! Second one? Third.'),
        3,
      );
      expect(WritingScoring.countSentences('Sentence without final period'), 1);
    });

    test('isObjectiveAnswerCorrect matches expected and accepted variants', () {
      const expected = 'I usually drink coffee in the morning.';
      const accepted = [
        'In the morning I usually drink coffee.',
        'I drink coffee in the morning usually.',
      ];

      // Exact match with differing punctuation or case
      expect(
        WritingScoring.isObjectiveAnswerCorrect(
          userAnswer: 'I usually drink coffee in the morning',
          expectedAnswer: expected,
          acceptedAnswers: accepted,
        ),
        isTrue,
      );

      // Accepted variant match
      expect(
        WritingScoring.isObjectiveAnswerCorrect(
          userAnswer: 'in the morning, I usually drink coffee.',
          expectedAnswer: expected,
          acceptedAnswers: accepted,
        ),
        isTrue,
      );

      // Incorrect answer
      expect(
        WritingScoring.isObjectiveAnswerCorrect(
          userAnswer: 'I coffee drink in morning.',
          expectedAnswer: expected,
          acceptedAnswers: accepted,
        ),
        isFalse,
      );
    });

    test('checkWordCountRange categorizes lengths properly', () {
      expect(
        WritingScoring.checkWordCountRange(
          wordCount: 0,
          minWords: 10,
          maxWords: 20,
        ),
        WritingLengthStatus.empty,
      );
      expect(
        WritingScoring.checkWordCountRange(
          wordCount: 5,
          minWords: 10,
          maxWords: 20,
        ),
        WritingLengthStatus.belowMinimum,
      );
      expect(
        WritingScoring.checkWordCountRange(
          wordCount: 15,
          minWords: 10,
          maxWords: 20,
        ),
        WritingLengthStatus.targetRange,
      );
      expect(
        WritingScoring.checkWordCountRange(
          wordCount: 25,
          minWords: 10,
          maxWords: 20,
        ),
        WritingLengthStatus.aboveMaximum,
      );
    });

    test('generateImprovementSuggestion gives constructive feedback', () {
      final objectiveCorrect = WritingScoring.generateImprovementSuggestion(
        wordCount: 7,
        sentenceCount: 1,
        minWords: 0,
        maxWords: 0,
        isObjective: true,
        isCorrect: true,
      );
      expect(objectiveCorrect, contains('matches standard English grammar'));

      final belowMin = WritingScoring.generateImprovementSuggestion(
        wordCount: 10,
        sentenceCount: 1,
        minWords: 20,
        maxWords: 40,
        isObjective: false,
      );
      expect(belowMin, contains('10 more words'));

      final metTarget = WritingScoring.generateImprovementSuggestion(
        wordCount: 25,
        sentenceCount: 2,
        minWords: 20,
        maxWords: 40,
        isObjective: false,
      );
      expect(metTarget, contains('meets the target word count'));
    });
  });
}
