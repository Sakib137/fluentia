import 'package:flutter_test/flutter_test.dart';
import 'package:fluentia/features/listening/domain/services/listening_scoring.dart';

void main() {
  group('ListeningScoring unit tests', () {
    test(
      'normalizeText collapses whitespace, lowercases, and strips punctuation',
      () {
        expect(
          ListeningScoring.normalizeText(
            '  Hello, World! How are you doing?  ',
          ),
          equals('hello world how are you doing'),
        );
        expect(
          ListeningScoring.normalizeText("It's seven o'clock."),
          equals('its seven oclock'),
        );
        expect(
          ListeningScoring.normalizeText('Multi    space   collapse...'),
          equals('multi space collapse'),
        );
      },
    );

    test('evaluateTextAnswer accepts normalized and alternate answers', () {
      expect(
        ListeningScoring.evaluateTextAnswer(
          userAnswer: 'At seven oclock',
          expectedAnswer: "At seven o'clock.",
        ),
        isTrue,
      );

      expect(
        ListeningScoring.evaluateTextAnswer(
          userAnswer: '7 am',
          expectedAnswer: 'At 7:00 AM',
          acceptedAnswers: ['7 am', 'seven am'],
        ),
        isTrue,
      );

      expect(
        ListeningScoring.evaluateTextAnswer(
          userAnswer: 'At six',
          expectedAnswer: 'At seven',
        ),
        isFalse,
      );
    });

    test('evaluateTrueFalse checks boolean values correctly', () {
      expect(
        ListeningScoring.evaluateTrueFalse(
          userChoice: true,
          expectedValue: true,
        ),
        isTrue,
      );
      expect(
        ListeningScoring.evaluateTrueFalse(
          userChoice: false,
          expectedValue: true,
        ),
        isFalse,
      );
      expect(
        ListeningScoring.evaluateTrueFalse(
          userChoice: false,
          expectedValue: false,
        ),
        isTrue,
      );
    });

    test('evaluateMultipleChoice validates correct option', () {
      expect(
        ListeningScoring.evaluateMultipleChoice(
          selectedOption: 'Organic olive oil',
          correctOption: 'organic olive oil',
        ),
        isTrue,
      );
      expect(
        ListeningScoring.evaluateMultipleChoice(
          selectedOption: 'Pasta sauce',
          correctOption: 'Organic olive oil',
        ),
        isFalse,
      );
    });

    test('evaluateMissingWords evaluates blanks positionally', () {
      final results = ListeningScoring.evaluateMissingWords(
        userAnswers: {0: 'tea', 1: 'toast'},
        expectedWords: ['tea', 'toast'],
      );
      expect(results[0], isTrue);
      expect(results[1], isTrue);

      final partialResults = ListeningScoring.evaluateMissingWords(
        userAnswers: {0: 'coffee', 1: 'Toast!'},
        expectedWords: ['tea', 'toast'],
      );
      expect(partialResults[0], isFalse);
      expect(partialResults[1], isTrue);
    });

    group('evaluateDictation', () {
      test('Detects exact match with normalization', () {
        final result = ListeningScoring.evaluateDictation(
          userText: 'I usually go to the library after class.',
          expectedTranscript: 'i usually go to the library after class',
        );

        expect(result.isExactMatch, isTrue);
        expect(result.matchedWordsCount, equals(8));
        expect(result.totalExpectedWords, equals(8));
        expect(result.accuracyPercentage, equals(100.0));
        expect(result.missingWords, isEmpty);
        expect(result.extraWords, isEmpty);
        expect(result.correctWords.length, equals(8));
      });

      test('Detects missing words accurately', () {
        // Expected 8 words: i usually go to the library after class
        // User omits 'to the': i usually go library after class (6 words)
        final result = ListeningScoring.evaluateDictation(
          userText: 'i usually go library after class',
          expectedTranscript: 'I usually go to the library after class.',
        );

        expect(result.isExactMatch, isFalse);
        expect(result.matchedWordsCount, equals(6));
        expect(result.totalExpectedWords, equals(8));
        expect(result.accuracyPercentage, equals(75.0));
        expect(result.missingWords, containsAll(['to', 'the']));
        expect(result.summaryText, contains('6 of 8 words matched (75%)'));
      });

      test('Detects extra words accurately', () {
        // User adds extra word 'today'
        final result = ListeningScoring.evaluateDictation(
          userText: 'I usually go to the library after class today',
          expectedTranscript: 'I usually go to the library after class.',
        );

        expect(result.isExactMatch, isFalse);
        expect(result.matchedWordsCount, equals(8));
        expect(result.totalExpectedWords, equals(8));
        expect(result.extraWords, contains('today'));
      });
    });
  });
}
