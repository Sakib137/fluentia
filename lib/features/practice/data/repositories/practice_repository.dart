import 'dart:convert';

import '../../../../core/database/database_service.dart';
import '../../../../core/database/tables/practice_sessions_table.dart';
import '../../../../core/database/tables/user_progress_table.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/models/practice_models.dart';
import '../../domain/services/practice_recommendation_service.dart';
import '../datasources/bundled_practice_content.dart';
import '../../../speaking/data/datasources/speaking_content.dart';

/// Contract for accessing practice activities and persisting practice sessions.
abstract class PracticeRepository {
  /// Fetches all activities for a specific [skill].
  Future<List<PracticeActivity>> getActivitiesBySkill(PracticeSkill skill);

  /// Fetches all activities matching [level].
  Future<List<PracticeActivity>> getActivitiesByLevel(String level);

  /// Fetches an activity by its unique [id].
  Future<PracticeActivity?> getActivityById(String id);

  /// Selects a recommended practice activity based on [level], [goals], and [date].
  Future<PracticeActivity> getRecommendedActivity({
    required String level,
    required List<String> goals,
    required DateTime date,
  });

  /// Persists a completed or abandoned [session] to local offline storage.
  Future<void> saveSession(PracticeSession session);

  /// Retrieves practice history, optionally filtered by [skill].
  Future<List<PracticeSession>> getSessionHistory({
    PracticeSkill? skill,
    int? limit,
  });

  /// Retrieves today's total recorded practice minutes.
  Future<int> getTodayPracticeMinutes({DateTime? date});

  /// Retrieves all-time recorded practice minutes.
  Future<int> getTotalPracticeMinutes();
}

/// SQLite-backed implementation of [PracticeRepository].
class SqlitePracticeRepository implements PracticeRepository {
  const SqlitePracticeRepository(
    this._db, [
    this._recommendationService = const PracticeRecommendationService(),
  ]);

  final DatabaseService _db;
  final PracticeRecommendationService _recommendationService;

  String _formatDateKey(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _ensureInitialized() async {
    try {
      await _db.initialize();
    } catch (_) {}
  }

  @override
  Future<List<PracticeActivity>> getActivitiesBySkill(
    PracticeSkill skill,
  ) async {
    return BundledPracticeContent.allActivities
        .where((a) => a.skill == skill)
        .toList();
  }

  @override
  Future<List<PracticeActivity>> getActivitiesByLevel(String level) async {
    final normLevel = level.toUpperCase();
    return BundledPracticeContent.allActivities
        .where((a) => a.level.toUpperCase() == normLevel)
        .toList();
  }

  @override
  Future<PracticeActivity?> getActivityById(String id) async {
    try {
      return BundledPracticeContent.allActivities.firstWhere((a) => a.id == id);
    } catch (_) {
      try {
        return SpeakingContent.activities
            .firstWhere((a) => a.id == id)
            .toPracticeActivity();
      } catch (_) {
        return null;
      }
    }
  }

  @override
  Future<PracticeActivity> getRecommendedActivity({
    required String level,
    required List<String> goals,
    required DateTime date,
  }) async {
    final recommendedSkill = _recommendationService.selectQuickPracticeSkill(
      userGoals: goals,
      date: date,
    );

    final skillActivities = await getActivitiesBySkill(recommendedSkill);
    if (skillActivities.isEmpty) {
      return BundledPracticeContent.allActivities.first;
    }

    // Try matching level first, fallback to first activity for skill
    final normLevel = level.toUpperCase();
    final matchedLevel = skillActivities.firstWhere(
      (a) => a.level.toUpperCase() == normLevel,
      orElse: () => skillActivities.first,
    );

    return matchedLevel;
  }

  @override
  Future<void> saveSession(PracticeSession session) async {
    try {
      await _ensureInitialized();

      final nowIso = (session.completedAt ?? DateTime.now()).toIso8601String();
      final dateKey = _formatDateKey(session.completedAt ?? DateTime.now());
      final durationMinutes = (session.durationSeconds / 60).ceil();

      await _db.transaction((txn) async {
        // 1. Insert session log
        await txn.insert(PracticeSessionsTable.tableName, {
          PracticeSessionsTable.columnId: session.id,
          PracticeSessionsTable.columnSkillType: session.skill.id,
          PracticeSessionsTable.columnLessonId: session.activityIds.firstOrNull,
          PracticeSessionsTable.columnScore: session.score ?? 100.0,
          PracticeSessionsTable.columnDurationSeconds: session.durationSeconds,
          PracticeSessionsTable.columnMetadataJson: jsonEncode({
            'activityIds': session.activityIds,
            'status': session.status.name,
            'level': session.level,
            'totalActivities': session.totalActivities,
          }),
          PracticeSessionsTable.columnCompletedAt: nowIso,
        });

        // 2. Only credit daily practice minutes if session was completed
        if (session.isCompleted && durationMinutes > 0) {
          final existingRows = await txn.query(
            UserProgressTable.tableName,
            where: '${UserProgressTable.columnDate} = ?',
            whereArgs: [dateKey],
            limit: 1,
          );

          final skillColumn = switch (session.skill) {
            PracticeSkill.speaking => UserProgressTable.columnSpeakingMinutes,
            PracticeSkill.listening => UserProgressTable.columnListeningMinutes,
            PracticeSkill.reading => UserProgressTable.columnReadingMinutes,
            PracticeSkill.writing => UserProgressTable.columnWritingMinutes,
          };

          if (existingRows.isEmpty) {
            await txn.insert(UserProgressTable.tableName, {
              UserProgressTable.columnDate: dateKey,
              UserProgressTable.columnMinutesPracticed: durationMinutes,
              UserProgressTable.columnLessonsCompleted: 1,
              UserProgressTable.columnWordsLearned: 0,
              skillColumn: durationMinutes,
              UserProgressTable.columnDailyGoalMet: 0,
            });
          } else {
            final currentMinutes =
                (existingRows.first[UserProgressTable.columnMinutesPracticed]
                    as int?) ??
                0;
            final currentLessons =
                (existingRows.first[UserProgressTable.columnLessonsCompleted]
                    as int?) ??
                0;
            final currentSkillMinutes =
                (existingRows.first[skillColumn] as int?) ?? 0;

            await txn.update(
              UserProgressTable.tableName,
              {
                UserProgressTable.columnMinutesPracticed:
                    currentMinutes + durationMinutes,
                UserProgressTable.columnLessonsCompleted: currentLessons + 1,
                skillColumn: currentSkillMinutes + durationMinutes,
              },
              where: '${UserProgressTable.columnDate} = ?',
              whereArgs: [dateKey],
            );
          }
        }
      });

      AppLogger.info(
        'Practice session saved: ${session.id} (Status: ${session.status.name}, Skill: ${session.skill.id})',
        tag: 'PracticeRepository',
      );
    } catch (e, st) {
      AppLogger.error(
        'Failed to save practice session',
        error: e,
        stackTrace: st,
        tag: 'PracticeRepository',
      );
    }
  }

  @override
  Future<List<PracticeSession>> getSessionHistory({
    PracticeSkill? skill,
    int? limit,
  }) async {
    try {
      await _ensureInitialized();

      String? where;
      List<Object?>? whereArgs;

      if (skill != null) {
        where = '${PracticeSessionsTable.columnSkillType} = ?';
        whereArgs = [skill.id];
      }

      final rows = await _db.query(
        PracticeSessionsTable.tableName,
        where: where,
        whereArgs: whereArgs,
        orderBy: '${PracticeSessionsTable.columnCompletedAt} DESC',
        limit: limit,
      );

      return rows.map((r) {
        final id = r[PracticeSessionsTable.columnId] as String? ?? '';
        final skillStr =
            r[PracticeSessionsTable.columnSkillType] as String? ?? 'speaking';
        final score = (r[PracticeSessionsTable.columnScore] as num?)
            ?.toDouble();
        final durationSec =
            (r[PracticeSessionsTable.columnDurationSeconds] as int?) ?? 0;
        final completedAtStr =
            r[PracticeSessionsTable.columnCompletedAt] as String? ?? '';
        final completedAt = DateTime.tryParse(completedAtStr) ?? DateTime.now();

        Map<String, dynamic> metadata = {};
        final rawMeta = r[PracticeSessionsTable.columnMetadataJson] as String?;
        if (rawMeta != null && rawMeta.isNotEmpty) {
          try {
            metadata = jsonDecode(rawMeta) as Map<String, dynamic>;
          } catch (_) {}
        }

        final statusStr =
            metadata['status'] as String? ??
            PracticeSessionStatus.completed.name;
        final level = metadata['level'] as String? ?? 'B1';
        final activityIds =
            (metadata['activityIds'] as List<dynamic>?)?.cast<String>() ??
            [(r[PracticeSessionsTable.columnLessonId] as String? ?? '')];
        final totalActivities =
            metadata['totalActivities'] as int? ?? activityIds.length;

        final status = PracticeSessionStatus.values.firstWhere(
          (s) => s.name == statusStr,
          orElse: () => PracticeSessionStatus.completed,
        );

        return PracticeSession(
          id: id,
          skill: PracticeSkill.fromId(skillStr),
          activityIds: activityIds,
          level: level,
          startedAt: completedAt.subtract(Duration(seconds: durationSec)),
          completedAt: completedAt,
          durationSeconds: durationSec,
          score: score,
          status: status,
          currentActivityIndex: totalActivities,
          totalActivities: totalActivities,
        );
      }).toList();
    } catch (e, st) {
      AppLogger.error(
        'Failed to get session history',
        error: e,
        stackTrace: st,
        tag: 'PracticeRepository',
      );
      return const [];
    }
  }

  @override
  Future<int> getTodayPracticeMinutes({DateTime? date}) async {
    final dt = date ?? DateTime.now();
    final dateKey = _formatDateKey(dt);

    try {
      await _ensureInitialized();

      final rows = await _db.query(
        UserProgressTable.tableName,
        columns: [UserProgressTable.columnMinutesPracticed],
        where: '${UserProgressTable.columnDate} = ?',
        whereArgs: [dateKey],
        limit: 1,
      );

      if (rows.isNotEmpty) {
        return (rows.first[UserProgressTable.columnMinutesPracticed] as int?) ??
            0;
      }
      return 0;
    } catch (e, st) {
      AppLogger.error(
        'Failed to get today practice minutes',
        error: e,
        stackTrace: st,
        tag: 'PracticeRepository',
      );
      return 0;
    }
  }

  @override
  Future<int> getTotalPracticeMinutes() async {
    try {
      await _ensureInitialized();

      final res = await _db.rawQuery(
        'SELECT SUM(${UserProgressTable.columnMinutesPracticed}) as total FROM ${UserProgressTable.tableName}',
      );
      return (res.firstOrNull?['total'] as int?) ?? 0;
    } catch (e, st) {
      AppLogger.error(
        'Failed to get total practice minutes',
        error: e,
        stackTrace: st,
        tag: 'PracticeRepository',
      );
      return 0;
    }
  }
}
