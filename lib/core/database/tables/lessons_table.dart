/// Schema definition for the lessons table.
/// Stores offline modular lesson content across speaking, listening, reading, writing, and grammar.
class LessonsTable {
  LessonsTable._();

  static const String tableName = 'lessons';

  static const String columnId = 'id';
  static const String columnSkillType =
      'skill_type'; // speaking, listening, reading, writing, grammar, vocabulary
  static const String columnTitle = 'title';
  static const String columnDescription = 'description';
  static const String columnCefrLevel = 'cefr_level'; // A1, A2, B1, B2, C1, C2
  static const String columnEstimatedMinutes = 'estimated_minutes';
  static const String columnContentJson = 'content_json';
  static const String columnOrderIndex = 'order_index';
  static const String columnIsCompleted = 'is_completed';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';

  static const String createTableSql =
      '''
    CREATE TABLE IF NOT EXISTS $tableName (
      $columnId TEXT PRIMARY KEY NOT NULL,
      $columnSkillType TEXT NOT NULL,
      $columnTitle TEXT NOT NULL,
      $columnDescription TEXT,
      $columnCefrLevel TEXT NOT NULL,
      $columnEstimatedMinutes INTEGER NOT NULL DEFAULT 5,
      $columnContentJson TEXT NOT NULL,
      $columnOrderIndex INTEGER NOT NULL DEFAULT 0,
      $columnIsCompleted INTEGER NOT NULL DEFAULT 0,
      $columnCreatedAt TEXT NOT NULL,
      $columnUpdatedAt TEXT NOT NULL
    );
  ''';

  static const String createSkillIndexSql =
      '''
    CREATE INDEX IF NOT EXISTS idx_lessons_skill_level 
    ON $tableName ($columnSkillType, $columnCefrLevel);
  ''';
}
