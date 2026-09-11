import 'package:fluentia/features/home/domain/word_of_the_day_selector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WordOfTheDaySelector Tests', () {
    final dateA = DateTime.utc(2026, 9, 7);
    final dateB = DateTime.utc(2026, 9, 8);

    test('Selects valid word entity with full lexical metadata', () {
      final word = WordOfTheDaySelector.selectWord(dateA);

      expect(word.id, isNotEmpty);
      expect(word.word, isNotEmpty);
      expect(word.phonetic, isNotEmpty);
      expect(word.partOfSpeech, isNotEmpty);
      expect(word.definition, isNotEmpty);
      expect(word.example, isNotEmpty);
      expect(word.cefrLevel, isNotEmpty);
      expect(word.isSaved, isFalse);
    });

    test(
      'Selection is completely deterministic on repeated invocations for same date',
      () {
        final word1 = WordOfTheDaySelector.selectWord(dateA);
        final word2 = WordOfTheDaySelector.selectWord(dateA);

        expect(word1.id, word2.id);
        expect(word1.word, word2.word);
        expect(word1.definition, word2.definition);
      },
    );

    test('Different calendar days produce different words in cycle', () {
      final wordA = WordOfTheDaySelector.selectWord(dateA);
      final wordB = WordOfTheDaySelector.selectWord(dateB);

      expect(wordA.word, isNot(equals(wordB.word)));
    });

    test('Reflects isSaved flag correctly', () {
      final savedWord = WordOfTheDaySelector.selectWord(dateA, isSaved: true);
      expect(savedWord.isSaved, isTrue);

      final unsavedWord = WordOfTheDaySelector.selectWord(
        dateA,
        isSaved: false,
      );
      expect(unsavedWord.isSaved, isFalse);
    });
  });
}
