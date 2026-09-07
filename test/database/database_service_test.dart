import 'package:flutter_test/flutter_test.dart';
import 'package:fluentia/core/database/database_service.dart';
import 'package:fluentia/core/database/tables/app_settings_table.dart';
import 'package:fluentia/core/database/tables/lessons_table.dart';
import 'package:fluentia/core/database/tables/practice_sessions_table.dart';
import 'package:fluentia/core/database/tables/user_progress_table.dart';
import 'package:fluentia/core/database/tables/vocabulary_table.dart';

/// In-memory mock implementation of [DatabaseService] for unit testing.
class FakeDatabaseService implements DatabaseService {
  final Map<String, List<Map<String, Object?>>> _tables = {};
  bool isInitialized = false;
  bool isClosed = false;

  @override
  Future<void> initialize() async {
    isInitialized = true;
    _tables[LessonsTable.tableName] = [];
    _tables[VocabularyTable.tableName] = [];
    _tables[UserProgressTable.tableName] = [];
    _tables[PracticeSessionsTable.tableName] = [];
    _tables[AppSettingsTable.tableName] = [];
  }

  @override
  Future<void> close() async {
    isClosed = true;
  }

  @override
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    int? conflictAlgorithm,
  }) async {
    _tables.putIfAbsent(table, () => []);
    _tables[table]!.add(Map<String, Object?>.from(values));
    return _tables[table]!.length;
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
    return List<Map<String, Object?>>.from(_tables[table] ?? []);
  }

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    int? conflictAlgorithm,
  }) async {
    return 1;
  }

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final count = _tables[table]?.length ?? 0;
    _tables[table]?.clear();
    return count;
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    return [];
  }

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) async {}

  @override
  Future<T> transaction<T>(
    Future<T> Function(DatabaseService txn) action,
  ) async {
    return await action(this);
  }
}

void main() {
  group('DatabaseService and Table Schemas', () {
    late FakeDatabaseService db;

    setUp(() async {
      db = FakeDatabaseService();
      await db.initialize();
    });

    tearDown(() async {
      await db.close();
    });

    test('Table schemas have non-empty create SQL statements', () {
      expect(
        LessonsTable.createTableSql,
        contains('CREATE TABLE IF NOT EXISTS lessons'),
      );
      expect(
        VocabularyTable.createTableSql,
        contains('CREATE TABLE IF NOT EXISTS vocabulary'),
      );
      expect(
        UserProgressTable.createTableSql,
        contains('CREATE TABLE IF NOT EXISTS user_progress'),
      );
      expect(
        PracticeSessionsTable.createTableSql,
        contains('CREATE TABLE IF NOT EXISTS practice_sessions'),
      );
      expect(
        AppSettingsTable.createTableSql,
        contains('CREATE TABLE IF NOT EXISTS app_settings'),
      );
    });

    test('Can insert and query offline records via DatabaseService', () async {
      final lessonData = {
        LessonsTable.columnId: 'lesson-01',
        LessonsTable.columnSkillType: 'speaking',
        LessonsTable.columnTitle: 'Vowel Clarity',
        LessonsTable.columnCefrLevel: 'A2',
        LessonsTable.columnEstimatedMinutes: 5,
        LessonsTable.columnContentJson: '{}',
        LessonsTable.columnCreatedAt: DateTime.now().toIso8601String(),
        LessonsTable.columnUpdatedAt: DateTime.now().toIso8601String(),
      };

      await db.insert(LessonsTable.tableName, lessonData);

      final records = await db.query(LessonsTable.tableName);
      expect(records.length, equals(1));
      expect(records.first[LessonsTable.columnTitle], equals('Vowel Clarity'));
    });
  });
}
