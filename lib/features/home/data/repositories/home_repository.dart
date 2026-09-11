import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/database/database_service.dart';
import '../../../../core/database/tables/app_settings_table.dart';
import '../../../../core/database/tables/practice_sessions_table.dart';
import '../../../../core/database/tables/user_progress_table.dart';
import '../../../../core/database/tables/vocabulary_table.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/daily_challenge_generator.dart';
import '../../domain/streak_calculator.dart';
import '../../domain/word_of_the_day_selector.dart';
import '../models/home_models.dart';

/// Contract for Home feature data operations against local offline storage.
abstract class HomeRepository {
  /// Fetches the daily progress metrics for [date] with given [targetMinutes].
  Future<DailyProgressState> getDailyProgress(
    DateTime date, {
    int targetMinutes = 15,
  });

  /// Logs newly completed practice minutes for [skillType] on [date].
  Future<void> logPracticeMinutes(
    DateTime date,
    int additionalMinutes,
    String skillType,
  );

  /// Computes streak metrics up through [today].
  Future<StreakData> getStreakData(DateTime today, {int targetMinutes = 15});

  /// Loads today's 5-activity daily challenge state.
  Future<DailyChallengeState> getDailyChallenge(DateTime date);

  /// Toggles completion status of a challenge item.
  Future<void> toggleChallengeItem(
    DateTime date,
    String challengeId,
    bool isCompleted,
  );

  /// Loads the deterministic Word of the Day, reflecting local bookmark status.
  Future<WordOfTheDay> getWordOfTheDay(DateTime date);

  /// Toggles whether [word] is saved in local bookmarks.
  Future<bool> toggleBookmarkWord(WordOfTheDay word);

  /// Loads high-level summary metrics for the Progress Snapshot section.
  Future<ProgressSnapshotData> getProgressSnapshot({
    required String cefrLevel,
    required String levelTitle,
  });
}

/// SQLite-backed implementation of [HomeRepository].
class SqliteHomeRepository implements HomeRepository {
  const SqliteHomeRepository(this._db);

  final DatabaseService _db;

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
  Future<DailyProgressState> getDailyProgress(
    DateTime date, {
    int targetMinutes = 15,
  }) async {
    final dateKey = _formatDateKey(date);

    try {
      await _ensureInitialized();

      final rows = await _db.query(
        UserProgressTable.tableName,
        where: '${UserProgressTable.columnDate} = ?',
        whereArgs: [dateKey],
        limit: 1,
      );

      final countResult = await _db.rawQuery(
        'SELECT COUNT(*) as count FROM ${UserProgressTable.tableName}',
      );
      final totalRecordedDays =
          (countResult.firstOrNull?['count'] as int?) ?? 0;

      int practicedMinutes = 0;
      if (rows.isNotEmpty) {
        practicedMinutes =
            (rows.first[UserProgressTable.columnMinutesPracticed] as int?) ?? 0;
      }

      final isFirstDay =
          totalRecordedDays == 0 ||
          (totalRecordedDays == 1 && rows.isNotEmpty && practicedMinutes == 0);
      final isCompleted = practicedMinutes >= targetMinutes;
      final remainingMinutes = (targetMinutes - practicedMinutes).clamp(
        0,
        targetMinutes,
      );
      final progressFraction = targetMinutes > 0
          ? (practicedMinutes / targetMinutes).clamp(0.0, 1.0)
          : 0.0;

      return DailyProgressState(
        targetMinutes: targetMinutes,
        practicedMinutes: practicedMinutes,
        isCompleted: isCompleted,
        remainingMinutes: remainingMinutes,
        progressFraction: progressFraction,
        isFirstDay: isFirstDay,
      );
    } catch (e, st) {
      AppLogger.error(
        'Failed to get daily progress from database',
        error: e,
        stackTrace: st,
      );
      return DailyProgressState.initial(targetMinutes: targetMinutes);
    }
  }

  @override
  Future<void> logPracticeMinutes(
    DateTime date,
    int additionalMinutes,
    String skillType,
  ) async {
    final dateKey = _formatDateKey(date);
    final nowIso = DateTime.now().toIso8601String();

    try {
      await _ensureInitialized();

      await _db.transaction((txn) async {
        // 1. Check existing progress row
        final existingRows = await txn.query(
          UserProgressTable.tableName,
          where: '${UserProgressTable.columnDate} = ?',
          whereArgs: [dateKey],
          limit: 1,
        );

        final skillColumn = switch (skillType.toLowerCase()) {
          'speaking' => UserProgressTable.columnSpeakingMinutes,
          'listening' => UserProgressTable.columnListeningMinutes,
          'reading' => UserProgressTable.columnReadingMinutes,
          'writing' => UserProgressTable.columnWritingMinutes,
          'grammar' => UserProgressTable.columnGrammarMinutes,
          _ => UserProgressTable.columnSpeakingMinutes,
        };

        if (existingRows.isEmpty) {
          await txn.insert(UserProgressTable.tableName, {
            UserProgressTable.columnDate: dateKey,
            UserProgressTable.columnMinutesPracticed: additionalMinutes,
            UserProgressTable.columnLessonsCompleted: 1,
            UserProgressTable.columnWordsLearned: 0,
            skillColumn: additionalMinutes,
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
                  currentMinutes + additionalMinutes,
              UserProgressTable.columnLessonsCompleted: currentLessons + 1,
              skillColumn: currentSkillMinutes + additionalMinutes,
            },
            where: '${UserProgressTable.columnDate} = ?',
            whereArgs: [dateKey],
          );
        }

        // 2. Insert practice session log
        final sessionId = 'session_${DateTime.now().microsecondsSinceEpoch}';
        await txn.insert(PracticeSessionsTable.tableName, {
          PracticeSessionsTable.columnId: sessionId,
          PracticeSessionsTable.columnSkillType: skillType,
          PracticeSessionsTable.columnLessonId: null,
          PracticeSessionsTable.columnScore: 100.0,
          PracticeSessionsTable.columnDurationSeconds: additionalMinutes * 60,
          PracticeSessionsTable.columnMetadataJson: jsonEncode({
            'source': 'quick_practice',
          }),
          PracticeSessionsTable.columnCompletedAt: nowIso,
        });
      });
    } catch (e, st) {
      AppLogger.error(
        'Failed to log practice minutes in database',
        error: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<StreakData> getStreakData(
    DateTime today, {
    int targetMinutes = 15,
  }) async {
    try {
      await _ensureInitialized();

      final rows = await _db.query(
        UserProgressTable.tableName,
        columns: [
          UserProgressTable.columnDate,
          UserProgressTable.columnMinutesPracticed,
        ],
        where: '${UserProgressTable.columnMinutesPracticed} > 0',
        orderBy: '${UserProgressTable.columnDate} DESC',
      );

      final activeDates = <DateTime>[];
      for (final row in rows) {
        final dateStr = row[UserProgressTable.columnDate] as String?;
        if (dateStr != null) {
          final parsed = DateTime.tryParse(dateStr);
          if (parsed != null) {
            activeDates.add(parsed);
          }
        }
      }

      return StreakCalculator.calculate(activeDates: activeDates, today: today);
    } catch (e, st) {
      AppLogger.error(
        'Failed to get streak data from database',
        error: e,
        stackTrace: st,
      );
      return StreakData.empty();
    }
  }

  @override
  Future<DailyChallengeState> getDailyChallenge(DateTime date) async {
    final dateKey = _formatDateKey(date);
    final settingKey = 'daily_challenge_$dateKey';

    Set<String> completedIds = {};
    try {
      await _ensureInitialized();

      final settingRows = await _db.query(
        AppSettingsTable.tableName,
        where: '${AppSettingsTable.columnKey} = ?',
        whereArgs: [settingKey],
        limit: 1,
      );

      if (settingRows.isNotEmpty) {
        final rawVal =
            settingRows.first[AppSettingsTable.columnValue] as String?;
        if (rawVal != null && rawVal.isNotEmpty) {
          try {
            final list = (jsonDecode(rawVal) as List<dynamic>).cast<String>();
            completedIds = list.toSet();
          } catch (_) {}
        }
      }
    } catch (e, st) {
      AppLogger.error(
        'Failed to get daily challenge state from database',
        error: e,
        stackTrace: st,
      );
    }

    return DailyChallengeGenerator.generate(
      date: date,
      completedItemIds: completedIds,
    );
  }

  @override
  Future<void> toggleChallengeItem(
    DateTime date,
    String challengeId,
    bool isCompleted,
  ) async {
    final dateKey = _formatDateKey(date);
    final settingKey = 'daily_challenge_$dateKey';

    try {
      await _ensureInitialized();

      final settingRows = await _db.query(
        AppSettingsTable.tableName,
        where: '${AppSettingsTable.columnKey} = ?',
        whereArgs: [settingKey],
        limit: 1,
      );

      Set<String> completedIds = {};
      if (settingRows.isNotEmpty) {
        final rawVal =
            settingRows.first[AppSettingsTable.columnValue] as String?;
        if (rawVal != null && rawVal.isNotEmpty) {
          try {
            final list = (jsonDecode(rawVal) as List<dynamic>).cast<String>();
            completedIds = list.toSet();
          } catch (_) {}
        }
      }

      if (isCompleted) {
        completedIds.add(challengeId);
      } else {
        completedIds.remove(challengeId);
      }

      final nowIso = DateTime.now().toIso8601String();
      final jsonValue = jsonEncode(completedIds.toList());

      if (settingRows.isEmpty) {
        await _db.insert(AppSettingsTable.tableName, {
          AppSettingsTable.columnKey: settingKey,
          AppSettingsTable.columnValue: jsonValue,
          AppSettingsTable.columnUpdatedAt: nowIso,
        });
      } else {
        await _db.update(
          AppSettingsTable.tableName,
          {
            AppSettingsTable.columnValue: jsonValue,
            AppSettingsTable.columnUpdatedAt: nowIso,
          },
          where: '${AppSettingsTable.columnKey} = ?',
          whereArgs: [settingKey],
        );
      }
    } catch (e, st) {
      AppLogger.error(
        'Failed to toggle challenge item in database',
        error: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<WordOfTheDay> getWordOfTheDay(DateTime date) async {
    final baseWord = WordOfTheDaySelector.selectWord(date);

    try {
      await _ensureInitialized();

      final rows = await _db.query(
        VocabularyTable.tableName,
        where:
            '${VocabularyTable.columnId} = ? OR ${VocabularyTable.columnWord} = ?',
        whereArgs: [baseWord.id, baseWord.word],
        limit: 1,
      );

      final isSaved =
          rows.isNotEmpty &&
          ((rows.first[VocabularyTable.columnIsBookmarked] as int?) ?? 0) == 1;
      return baseWord.copyWith(isSaved: isSaved);
    } catch (e, st) {
      AppLogger.error(
        'Failed to get word of the day from database',
        error: e,
        stackTrace: st,
      );
      return baseWord;
    }
  }

  @override
  Future<bool> toggleBookmarkWord(WordOfTheDay word) async {
    try {
      await _ensureInitialized();

      final rows = await _db.query(
        VocabularyTable.tableName,
        where:
            '${VocabularyTable.columnId} = ? OR ${VocabularyTable.columnWord} = ?',
        whereArgs: [word.id, word.word],
        limit: 1,
      );

      final currentSaved =
          rows.isNotEmpty &&
          ((rows.first[VocabularyTable.columnIsBookmarked] as int?) ?? 0) == 1;
      final newSaved = !currentSaved;
      final nowIso = DateTime.now().toIso8601String();

      if (rows.isEmpty) {
        await _db.insert(VocabularyTable.tableName, {
          VocabularyTable.columnId: word.id,
          VocabularyTable.columnWord: word.word,
          VocabularyTable.columnPhonetic: word.phonetic,
          VocabularyTable.columnPartOfSpeech: word.partOfSpeech,
          VocabularyTable.columnDefinition: word.definition,
          VocabularyTable.columnExample: word.example,
          VocabularyTable.columnCefrLevel: word.cefrLevel,
          VocabularyTable.columnIsBookmarked: newSaved ? 1 : 0,
          VocabularyTable.columnMasteryLevel: 0,
          VocabularyTable.columnNextReviewDate: null,
          VocabularyTable.columnLastReviewedAt: null,
          VocabularyTable.columnCreatedAt: nowIso,
        });
      } else {
        await _db.update(
          VocabularyTable.tableName,
          {VocabularyTable.columnIsBookmarked: newSaved ? 1 : 0},
          where: '${VocabularyTable.columnId} = ?',
          whereArgs: [rows.first[VocabularyTable.columnId]],
        );
      }

      return newSaved;
    } catch (e, st) {
      AppLogger.error(
        'Failed to toggle bookmark word in database',
        error: e,
        stackTrace: st,
      );
      return !word.isSaved;
    }
  }

  @override
  Future<ProgressSnapshotData> getProgressSnapshot({
    required String cefrLevel,
    required String levelTitle,
  }) async {
    try {
      await _ensureInitialized();

      final minutesResult = await _db.rawQuery(
        'SELECT SUM(${UserProgressTable.columnMinutesPracticed}) as total FROM ${UserProgressTable.tableName}',
      );
      final totalMinutes = (minutesResult.firstOrNull?['total'] as int?) ?? 0;

      final wordsResult = await _db.rawQuery(
        'SELECT COUNT(*) as count FROM ${VocabularyTable.tableName}',
      );
      final wordsCount = (wordsResult.firstOrNull?['count'] as int?) ?? 0;

      final sessionsResult = await _db.rawQuery(
        'SELECT COUNT(*) as count FROM ${PracticeSessionsTable.tableName}',
      );
      final sessionsCount = (sessionsResult.firstOrNull?['count'] as int?) ?? 0;

      final streak = await getStreakData(DateTime.now());

      return ProgressSnapshotData(
        cefrLevel: cefrLevel,
        levelTitle: levelTitle,
        totalPracticeMinutes: totalMinutes,
        wordsLearnedCount: wordsCount,
        completedSessionsCount: sessionsCount,
        currentStreakDays: streak.currentStreak,
      );
    } catch (e, st) {
      AppLogger.error(
        'Failed to get progress snapshot from database',
        error: e,
        stackTrace: st,
      );
      return ProgressSnapshotData.initial(
        cefrLevel: cefrLevel,
        levelTitle: levelTitle,
      );
    }
  }
}

/// Provider for [HomeRepository].
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return SqliteHomeRepository(db);
});
