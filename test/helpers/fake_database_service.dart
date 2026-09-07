import 'package:fluentia/core/database/database_service.dart';
import 'package:fluentia/core/database/tables/app_settings_table.dart';
import 'package:fluentia/core/database/tables/lessons_table.dart';
import 'package:fluentia/core/database/tables/practice_sessions_table.dart';
import 'package:fluentia/core/database/tables/user_progress_table.dart';
import 'package:fluentia/core/database/tables/vocabulary_table.dart';

/// In-memory mock [DatabaseService] for testing.
class FakeDatabaseService implements DatabaseService {
  final Map<String, List<Map<String, Object?>>> _tables = {};
  bool isInitialized = false;
  bool isClosed = false;

  @override
  Future<void> initialize() async {
    if (isInitialized) return;
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
    final list = _tables[table] ?? [];
    var results = List<Map<String, Object?>>.from(list);

    if (where != null && whereArgs != null && whereArgs.isNotEmpty) {
      if (where.contains('date = ?')) {
        results = results.where((r) => r['date'] == whereArgs.first).toList();
      } else if (where.contains('skill_type = ?')) {
        results = results.where((r) => r['skill_type'] == whereArgs.first).toList();
      } else if (where.contains('key = ?')) {
        results = results.where((r) => r['key'] == whereArgs.first).toList();
      } else if (where.contains('id = ?')) {
        results = results.where((r) => r['id'] == whereArgs.first).toList();
      }
    }

    if (orderBy != null && orderBy.toLowerCase().contains('desc')) {
      results = results.reversed.toList();
    }

    if (limit != null && results.length > limit) {
      results = results.sublist(0, limit);
    }

    return results;
  }

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    int? conflictAlgorithm,
  }) async {
    final list = _tables[table] ?? [];
    int count = 0;
    for (int i = 0; i < list.length; i++) {
      final row = Map<String, Object?>.from(list[i]);
      bool match = true;
      if (where != null && whereArgs != null && whereArgs.isNotEmpty) {
        if (where.contains('date = ?')) {
          match = row['date'] == whereArgs.first;
        } else if (where.contains('skill_type = ?')) {
          match = row['skill_type'] == whereArgs.first;
        } else if (where.contains('key = ?')) {
          match = row['key'] == whereArgs.first;
        } else if (where.contains('id = ?')) {
          match = row['id'] == whereArgs.first;
        }
      }
      if (match) {
        row.addAll(values);
        list[i] = row;
        count++;
      }
    }
    return count;
  }

  @override
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) async {
    final list = _tables[table] ?? [];
    final before = list.length;
    if (where != null && whereArgs != null && whereArgs.isNotEmpty) {
      list.removeWhere((row) =>
          row['date'] == whereArgs.first ||
          row['key'] == whereArgs.first ||
          row['id'] == whereArgs.first ||
          row['skill_type'] == whereArgs.first);
    } else {
      list.clear();
    }
    return before - list.length;
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(String sql, [List<Object?>? arguments]) async {
    final lower = sql.toLowerCase();
    if (lower.contains('count(*)')) {
      if (lower.contains(UserProgressTable.tableName)) {
        return [{'count': _tables[UserProgressTable.tableName]?.length ?? 0}];
      } else if (lower.contains(VocabularyTable.tableName)) {
        return [{'count': _tables[VocabularyTable.tableName]?.length ?? 0}];
      } else if (lower.contains(PracticeSessionsTable.tableName)) {
        return [{'count': _tables[PracticeSessionsTable.tableName]?.length ?? 0}];
      }
      return [{'count': 0}];
    }
    if (lower.contains('sum(minutes_practiced)')) {
      final rows = _tables[UserProgressTable.tableName] ?? [];
      int total = 0;
      for (final r in rows) {
        total += (r['minutes_practiced'] as int?) ?? 0;
      }
      return [{'total': total}];
    }
    return [];
  }

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) async {}

  @override
  Future<T> transaction<T>(Future<T> Function(DatabaseService txn) action) async {
    return action(this);
  }
}
