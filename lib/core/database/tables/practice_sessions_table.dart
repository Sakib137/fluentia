/// Schema definition for the practice sessions table.
/// Logs every completed practice attempt (e.g. speaking recording, listening quiz, writing drill).
class PracticeSessionsTable {
  PracticeSessionsTable._();

  static const String tableName = 'practice_sessions';

  static const String columnId = 'id';
  static const String columnSkillType = 'skill_type';
  static const String columnLessonId = 'lesson_id';
  static const String columnScore = 'score'; // e.g. percentage 0-100 or rating
  static const String columnDurationSeconds = 'duration_seconds';
  static const String columnMetadataJson = 'metadata_json';
  static const String columnCompletedAt = 'completed_at';

  static const String createTableSql =
      '''
    CREATE TABLE IF NOT EXISTS $tableName (
      $columnId TEXT PRIMARY KEY NOT NULL,
      $columnSkillType TEXT NOT NULL,
      $columnLessonId TEXT,
      $columnScore REAL,
      $columnDurationSeconds INTEGER NOT NULL DEFAULT 0,
      $columnMetadataJson TEXT,
      $columnCompletedAt TEXT NOT NULL
    );
  ''';

  static const String createCompletedAtIndexSql =
      '''
    CREATE INDEX IF NOT EXISTS idx_sessions_completed 
    ON $tableName ($columnCompletedAt);
  ''';
}
