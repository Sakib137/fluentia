/// Schema definition for the app settings table.
/// Provides offline persistent key-value configuration directly within SQLite.
class AppSettingsTable {
  AppSettingsTable._();

  static const String tableName = 'app_settings';

  static const String columnKey = 'key';
  static const String columnValue = 'value';
  static const String columnUpdatedAt = 'updated_at';

  static const String createTableSql =
      '''
    CREATE TABLE IF NOT EXISTS $tableName (
      $columnKey TEXT PRIMARY KEY NOT NULL,
      $columnValue TEXT NOT NULL,
      $columnUpdatedAt TEXT NOT NULL
    );
  ''';
}
