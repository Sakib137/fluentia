import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' as sqflite;

import '../constants/app_constants.dart';
import '../errors/app_exception.dart';
import '../utils/app_logger.dart';
import 'database_service.dart';
import 'tables/app_settings_table.dart';
import 'tables/lessons_table.dart';
import 'tables/practice_sessions_table.dart';
import 'tables/user_progress_table.dart';
import 'tables/vocabulary_table.dart';

/// Concrete [DatabaseService] implementation backed by SQLite using the `sqflite` plugin.
class SqliteDatabaseService implements DatabaseService {
  SqliteDatabaseService({this.executor});

  final sqflite.DatabaseExecutor? executor;
  sqflite.Database? _database;
  Future<void>? _initFuture;

  Future<sqflite.DatabaseExecutor> _getExecutor() async {
    if (executor != null) return executor!;
    if (_database == null) {
      await initialize();
    }
    final exec = _database;
    if (exec == null) {
      throw const DatabaseException(
        message: 'Database has not been initialized. Call initialize() first.',
      );
    }
    return exec;
  }

  @override
  Future<void> initialize() async {
    if (_database != null) return;
    if (_initFuture != null) return _initFuture;
    _initFuture = _doInitialize();
    return _initFuture;
  }

  Future<void> _doInitialize() async {
    try {
      final dbPath = await sqflite.getDatabasesPath();
      final fullPath = p.join(dbPath, AppConstants.databaseName);

      AppLogger.info(
        'Initializing SQLite database at $fullPath',
        tag: 'Database',
      );

      _database = await sqflite.openDatabase(
        fullPath,
        version: AppConstants.databaseVersion,
        onConfigure: _onConfigure,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );

      AppLogger.info('SQLite database successfully opened', tag: 'Database');
    } catch (e, st) {
      _initFuture = null;
      AppLogger.error(
        'Failed to initialize SQLite database',
        error: e,
        stackTrace: st,
        tag: 'Database',
      );
      throw DatabaseException(
        message: 'Failed to initialize database: $e',
        details: e,
        stackTrace: st,
      );
    }
  }

  Future<void> _onConfigure(sqflite.Database db) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
    // Enable WAL journal mode for high performance offline reading & writing
    try {
      await db.rawQuery('PRAGMA journal_mode = WAL');
    } catch (_) {
      // WAL mode is optional if platform doesn't support it (e.g. in-memory or certain OS)
    }
  }

  Future<void> _onCreate(sqflite.Database db, int version) async {
    AppLogger.info(
      'Creating database tables for version $version',
      tag: 'Database',
    );

    final batch = db.batch();

    // 1. Lessons
    batch.execute(LessonsTable.createTableSql);
    batch.execute(LessonsTable.createSkillIndexSql);

    // 2. Vocabulary
    batch.execute(VocabularyTable.createTableSql);
    batch.execute(VocabularyTable.createReviewIndexSql);

    // 3. User Progress
    batch.execute(UserProgressTable.createTableSql);

    // 4. Practice Sessions
    batch.execute(PracticeSessionsTable.createTableSql);
    batch.execute(PracticeSessionsTable.createCompletedAtIndexSql);

    // 5. Settings
    batch.execute(AppSettingsTable.createTableSql);

    await batch.commit(noResult: true);
    AppLogger.info('All tables created successfully', tag: 'Database');
  }

  Future<void> _onUpgrade(
    sqflite.Database db,
    int oldVersion,
    int newVersion,
  ) async {
    AppLogger.info(
      'Upgrading database from $oldVersion to $newVersion',
      tag: 'Database',
    );
    // Future database migration scripts will be placed here incrementally
  }

  @override
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _initFuture = null;
      AppLogger.info('SQLite database closed', tag: 'Database');
    }
  }

  @override
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    int? conflictAlgorithm,
  }) async {
    try {
      final exec = await _getExecutor();
      return await exec.insert(
        table,
        values,
        nullColumnHack: nullColumnHack,
        conflictAlgorithm: conflictAlgorithm != null
            ? sqflite.ConflictAlgorithm.values[conflictAlgorithm]
            : sqflite.ConflictAlgorithm.replace,
      );
    } catch (e, st) {
      throw DatabaseException(
        message: 'Insert failed on table $table: $e',
        details: e,
        stackTrace: st,
      );
    }
  }

  @override
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
  }) async {
    try {
      final exec = await _getExecutor();
      return await exec.query(
        table,
        distinct: distinct,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
    } catch (e, st) {
      throw DatabaseException(
        message: 'Query failed on table $table: $e',
        details: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    int? conflictAlgorithm,
  }) async {
    try {
      final exec = await _getExecutor();
      return await exec.update(
        table,
        values,
        where: where,
        whereArgs: whereArgs,
        conflictAlgorithm: conflictAlgorithm != null
            ? sqflite.ConflictAlgorithm.values[conflictAlgorithm]
            : null,
      );
    } catch (e, st) {
      throw DatabaseException(
        message: 'Update failed on table $table: $e',
        details: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    try {
      final exec = await _getExecutor();
      return await exec.delete(table, where: where, whereArgs: whereArgs);
    } catch (e, st) {
      throw DatabaseException(
        message: 'Delete failed on table $table: $e',
        details: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    try {
      final exec = await _getExecutor();
      return await exec.rawQuery(sql, arguments);
    } catch (e, st) {
      throw DatabaseException(
        message: 'Raw query failed: $e',
        details: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) async {
    try {
      final exec = await _getExecutor();
      await exec.execute(sql, arguments);
    } catch (e, st) {
      throw DatabaseException(
        message: 'Execute failed: $e',
        details: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(DatabaseService txn) action,
  ) async {
    if (_database == null) {
      await initialize();
    }
    final db = _database;
    if (db == null) {
      throw const DatabaseException(
        message: 'Cannot run transaction on uninitialized database',
      );
    }

    try {
      return await db.transaction<T>((txn) async {
        final txnService = SqliteDatabaseService(executor: txn);
        return await action(txnService);
      });
    } catch (e, st) {
      if (e is AppException) rethrow;
      throw DatabaseException(
        message: 'Transaction failed: $e',
        details: e,
        stackTrace: st,
      );
    }
  }
}
