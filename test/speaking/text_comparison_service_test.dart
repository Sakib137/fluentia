import 'package:flutter_test/flutter_test.dart';
import 'package:fluentia/features/speaking/domain/models/speaking_metrics.dart';
import 'package:fluentia/features/speaking/domain/services/text_comparison_service.dart';

void main() {
  const service = TextComparisonService();

  group('TextComparisonService Unit Tests', () {
    test('Exact match yields 100% match and all matched tokens', () {
      const expected = 'Good morning, how are you today?';
      const spoken = 'Good morning, how are you today?';

      final diff = service.compare(
        expectedText: expected,
        recognizedText: spoken,
      );

      expect(diff.matchPercentage, 100.0);
      expect(diff.matchedWords.length, 6);
      expect(diff.missingWords.length, 0);
      expect(diff.extraWords.length, 0);
      expect(diff.differentWords.length, 0);
      expect(
        diff.wordTokens.every((t) => t.status == WordMatchStatus.matched),
        isTrue,
      );
    });

    test('Case insensitivity and punctuation normalization', () {
      const expected = 'Welcome to Fluentia, your English practice partner!';
      const spoken = 'welcome to fluentia your english practice partner';

      final diff = service.compare(
        expectedText: expected,
        recognizedText: spoken,
      );

      expect(diff.matchPercentage, 100.0);
      expect(diff.wordTokens.length, 7);
      expect(
        diff.wordTokens.every((t) => t.status == WordMatchStatus.matched),
        isTrue,
      );
    });

    test('Detects missing words when speaker omits words', () {
      const expected = 'I would like a cup of coffee please';
      const spoken = 'I like a coffee';

      final diff = service.compare(
        expectedText: expected,
        recognizedText: spoken,
      );

      expect(diff.matchPercentage, lessThan(100.0));
      expect(diff.missingWords, isNotEmpty);
      expect(diff.missingWords, containsAll(['would', 'cup', 'of', 'please']));
      expect(
        diff.wordTokens.any((t) => t.status == WordMatchStatus.missing),
        isTrue,
      );
    });

    test('Detects extra words inserted by speaker', () {
      const expected = 'The weather is very nice today';
      const spoken = 'The weather is actually very nice today really';

      final diff = service.compare(
        expectedText: expected,
        recognizedText: spoken,
      );

      expect(diff.extraWords, isNotEmpty);
      expect(diff.extraWords, containsAll(['actually', 'really']));
      expect(
        diff.wordTokens.any((t) => t.status == WordMatchStatus.extra),
        isTrue,
      );
    });

    test('Detects substituted/different words', () {
      const expected = 'She walked to the store';
      const spoken = 'She ran to the shop';

      final diff = service.compare(
        expectedText: expected,
        recognizedText: spoken,
      );

      expect(diff.matchedWords, containsAll(['she', 'to', 'the']));
      expect(diff.matchPercentage, greaterThan(0.0));
      expect(diff.matchPercentage, lessThan(100.0));
    });

    test('Handles empty spoken input gracefully', () {
      const expected = 'Any valid sentence';
      const spoken = '';

      final diff = service.compare(
        expectedText: expected,
        recognizedText: spoken,
      );

      expect(diff.matchPercentage, 0.0);
      expect(diff.matchedWords, isEmpty);
      expect(diff.missingWords.length, 3);
      expect(diff.extraWords, isEmpty);
      expect(
        diff.wordTokens.every((t) => t.status == WordMatchStatus.missing),
        isTrue,
      );
    });

    test('Handles empty expected input gracefully', () {
      const expected = '';
      const spoken = 'Some spoken words';

      final diff = service.compare(
        expectedText: expected,
        recognizedText: spoken,
      );

      expect(diff.matchPercentage, 0.0);
      expect(
        diff.wordTokens.every((t) => t.status == WordMatchStatus.extra),
        isTrue,
      );
    });

    test('Handles both empty strings gracefully', () {
      final diff = service.compare(expectedText: '', recognizedText: '');

      expect(diff.matchPercentage, 100.0);
      expect(diff.wordTokens, isEmpty);
      expect(diff.feedbackMessage, isNotEmpty);
    });

    test(
      'TextComparisonService.normalize handles non-alphanumeric symbols and whitespace',
      () {
        expect(
          TextComparisonService.normalize('  "Hello... world!!"  '),
          'hello world',
        );
        expect(TextComparisonService.normalize('don\'t stop!'), 'dont stop');
        expect(TextComparisonService.normalize(''), '');
      },
    );

    test('TextComparisonService.tokenizeWords splits into clean tokens', () {
      final tokens = TextComparisonService.tokenizeWords(
        '  Fluentia: Practice makes progress!  ',
      );
      expect(tokens, ['fluentia', 'practice', 'makes', 'progress']);
    });
  });
}
