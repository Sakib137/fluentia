/// Schema definition for the vocabulary table.
/// Stores offline flashcards, definitions, phonetic transcriptions, examples, and spaced repetition metrics.
class VocabularyTable {
  VocabularyTable._();

  static const String tableName = 'vocabulary';

  static const String columnId = 'id';
  static const String columnWord = 'word';
  static const String columnPhonetic = 'phonetic';
  static const String columnPartOfSpeech = 'part_of_speech';
  static const String columnDefinition = 'definition';
  static const String columnExample = 'example';
  static const String columnCefrLevel = 'cefr_level';
  static const String columnIsBookmarked = 'is_bookmarked';
  static const String columnMasteryLevel =
      'mastery_level'; // 0 to 5 (Spaced Repetition)
  static const String columnNextReviewDate = 'next_review_date';
  static const String columnLastReviewedAt = 'last_reviewed_at';
  static const String columnCreatedAt = 'created_at';

  static const String createTableSql =
      '''
    CREATE TABLE IF NOT EXISTS $tableName (
      $columnId TEXT PRIMARY KEY NOT NULL,
      $columnWord TEXT NOT NULL UNIQUE,
      $columnPhonetic TEXT,
      $columnPartOfSpeech TEXT,
      $columnDefinition TEXT NOT NULL,
      $columnExample TEXT,
      $columnCefrLevel TEXT NOT NULL,
      $columnIsBookmarked INTEGER NOT NULL DEFAULT 0,
      $columnMasteryLevel INTEGER NOT NULL DEFAULT 0,
      $columnNextReviewDate TEXT,
      $columnLastReviewedAt TEXT,
      $columnCreatedAt TEXT NOT NULL
    );
  ''';

  static const String createReviewIndexSql =
      '''
    CREATE INDEX IF NOT EXISTS idx_vocab_review 
    ON $tableName ($columnNextReviewDate, $columnMasteryLevel);
  ''';
}
