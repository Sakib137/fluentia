/// Abstract interface for local database operations in Fluentia.
/// Decouples the application layers from the concrete database engine (e.g. SQLite/sqflite).
abstract class DatabaseService {
  /// Initializes the database, runs migrations, and configures pragmas.
  Future<void> initialize();

  /// Closes the database connection.
  Future<void> close();

  /// Inserts a row into [table] and returns the generated row ID.
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    int? conflictAlgorithm,
  });

  /// Queries the given [table] and returns the matched rows.
  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  });

  /// Updates rows in [table] and returns the count of updated rows.
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    int? conflictAlgorithm,
  });

  /// Deletes rows from [table] matching [where] and returns the count of deleted rows.
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs});

  /// Executes a raw SQL query.
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]);

  /// Executes a raw SQL command (CREATE, DROP, ALTER, etc.).
  Future<void> execute(String sql, [List<Object?>? arguments]);

  /// Runs operations inside a single database transaction.
  Future<T> transaction<T>(Future<T> Function(DatabaseService txn) action);
}
