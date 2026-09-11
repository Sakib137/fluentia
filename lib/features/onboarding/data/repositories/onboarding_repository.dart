import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/database_service.dart';
import '../../../../core/database/tables/app_settings_table.dart';
import '../../../../core/services/preferences_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/onboarding_state_model.dart';

/// Contract for accessing and saving onboarding preferences and placement results.
abstract class OnboardingRepository {
  Future<bool> hasCompletedOnboarding();
  Future<OnboardingStateModel> getOnboardingState();
  Future<void> saveOnboardingState(OnboardingStateModel state);
  Future<void> completeOnboarding(OnboardingStateModel state);
}

/// Concrete local storage implementation using SharedPreferences and SQLite.
class LocalOnboardingRepository implements OnboardingRepository {
  LocalOnboardingRepository({
    required PreferencesService preferencesService,
    required DatabaseService databaseService,
  }) : _prefs = preferencesService,
       _db = databaseService;

  final PreferencesService _prefs;
  final DatabaseService _db;

  static const String _onboardingDataKey = 'fluentia_onboarding_full_state';

  @override
  Future<bool> hasCompletedOnboarding() async {
    return _prefs.getBool(StorageKeys.hasCompletedOnboarding) ?? false;
  }

  @override
  Future<OnboardingStateModel> getOnboardingState() async {
    try {
      final jsonString = _prefs.getString(_onboardingDataKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        return OnboardingStateModel.fromJson(jsonString);
      }

      // Check SQLite fallback
      final dbResults = await _db.query(
        AppSettingsTable.tableName,
        where: '${AppSettingsTable.columnKey} = ?',
        whereArgs: [_onboardingDataKey],
      );

      if (dbResults.isNotEmpty) {
        final rawJson =
            dbResults.first[AppSettingsTable.columnValue] as String?;
        if (rawJson != null && rawJson.isNotEmpty) {
          return OnboardingStateModel.fromJson(rawJson);
        }
      }
    } catch (e, st) {
      AppLogger.error(
        'Failed to read onboarding state from local storage',
        error: e,
        stackTrace: st,
        tag: 'OnboardingRepo',
      );
    }

    return const OnboardingStateModel();
  }

  @override
  Future<void> saveOnboardingState(OnboardingStateModel state) async {
    try {
      final jsonString = state.toJson();

      // Save to SharedPreferences
      await _prefs.setString(_onboardingDataKey, jsonString);
      await _prefs.setBool(
        StorageKeys.hasCompletedOnboarding,
        state.onboardingCompleted,
      );
      await _prefs.setInt(
        StorageKeys.dailyGoalMinutes,
        state.dailyPracticeMinutes,
      );
      await _prefs.setBool(
        StorageKeys.dailyReminderEnabled,
        state.remindersEnabled,
      );
      if (state.currentLevel != null) {
        await _prefs.setString(
          StorageKeys.preferredLanguageLevel,
          state.currentLevel!,
        );
      }

      // Persist to SQLite AppSettingsTable
      final now = DateTime.now().toIso8601String();
      await _db.insert(AppSettingsTable.tableName, {
        AppSettingsTable.columnKey: _onboardingDataKey,
        AppSettingsTable.columnValue: jsonString,
        AppSettingsTable.columnUpdatedAt: now,
      });
    } catch (e, st) {
      AppLogger.error(
        'Failed to persist onboarding state',
        error: e,
        stackTrace: st,
        tag: 'OnboardingRepo',
      );
    }
  }

  @override
  Future<void> completeOnboarding(OnboardingStateModel state) async {
    final completedState = state.copyWith(onboardingCompleted: true);
    await saveOnboardingState(completedState);
  }
}

/// Riverpod provider exposing the [OnboardingRepository].
final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  final prefs = ref.watch(preferencesServiceProvider);
  final db = ref.watch(databaseServiceProvider);
  return LocalOnboardingRepository(
    preferencesService: prefs,
    databaseService: db,
  );
});
