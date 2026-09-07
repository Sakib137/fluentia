import '../data/datasources/curated_vocabulary_data.dart';
import '../data/models/home_models.dart';

/// Pure domain selector for the deterministic Word of the Day.
///
/// Maps each calendar day (day of year + year salt) to an entry in the
/// curated vocabulary dataset so that the word remains constant for 24 hours.
class WordOfTheDaySelector {
  const WordOfTheDaySelector._();

  /// Selects the deterministic [WordOfTheDay] for [date].
  ///
  /// If [isSaved] is provided, the word entity will reflect the bookmark status.
  static WordOfTheDay selectWord(DateTime date, {bool isSaved = false}) {
    if (kCuratedVocabularyList.isEmpty) {
      return WordOfTheDay(
        id: 'vocab-fallback',
        word: 'fluent',
        phonetic: '/ˈfluː.ənt/',
        partOfSpeech: 'adjective',
        definition: 'Able to speak or write a particular foreign language easily and accurately.',
        example: 'With continuous daily practice, you will become fluent in English.',
        cefrLevel: 'B2',
        isSaved: isSaved,
      );
    }

    // Calculate day-of-year
    final startOfYear = DateTime.utc(date.year, 1, 1);
    final dayOfYear = DateTime.utc(date.year, date.month, date.day)
        .difference(startOfYear)
        .inDays;

    final index = (dayOfYear + date.year) % kCuratedVocabularyList.length;
    final template = kCuratedVocabularyList[index];

    return template.copyWith(isSaved: isSaved);
  }
}
