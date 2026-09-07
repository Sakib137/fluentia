/// Schema definition for the user progress and streak tracking table.
class UserProgressTable {
  UserProgressTable._();

  static const String tableName = 'user_progress';

  static const String columnDate = 'date'; // YYYY-MM-DD primary key
  static const String columnMinutesPracticed = 'minutes_practiced';
  static const String columnLessonsCompleted = 'lessons_completed';
  static const String columnWordsLearned = 'words_learned';
  static const String columnSpeakingMinutes = 'speaking_minutes';
  static const String columnListeningMinutes = 'listening_minutes';
  static const String columnReadingMinutes = 'reading_minutes';
  static const String columnWritingMinutes = 'writing_minutes';
  static const String columnGrammarMinutes = 'grammar_minutes';
  static const String columnDailyGoalMet = 'daily_goal_met';

  static const String createTableSql =
      '''
    CREATE TABLE IF NOT EXISTS $tableName (
      $columnDate TEXT PRIMARY KEY NOT NULL,
      $columnMinutesPracticed INTEGER NOT NULL DEFAULT 0,
      $columnLessonsCompleted INTEGER NOT NULL DEFAULT 0,
      $columnWordsLearned INTEGER NOT NULL DEFAULT 0,
      $columnSpeakingMinutes INTEGER NOT NULL DEFAULT 0,
      $columnListeningMinutes INTEGER NOT NULL DEFAULT 0,
      $columnReadingMinutes INTEGER NOT NULL DEFAULT 0,
      $columnWritingMinutes INTEGER NOT NULL DEFAULT 0,
      $columnGrammarMinutes INTEGER NOT NULL DEFAULT 0,
      $columnDailyGoalMet INTEGER NOT NULL DEFAULT 0
    );
  ''';
}
