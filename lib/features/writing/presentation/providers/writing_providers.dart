import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/services/preferences_service.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../data/datasources/writing_content.dart';
import '../../data/repositories/writing_repository_impl.dart';
import '../../domain/models/writing_activity.dart';
import '../../domain/models/writing_mode.dart';
import '../../domain/repositories/writing_repository.dart';
import '../../domain/services/daily_writing_selector.dart';
import '../../domain/services/writing_evaluation_service.dart';

/// Representation of an unfinished writing draft saved in local storage.
class UnfinishedWritingData {
  const UnfinishedWritingData({
    required this.activity,
    required this.draftText,
    required this.wordCount,
    required this.lastSaved,
  });

  final WritingActivity activity;
  final String draftText;
  final int wordCount;
  final DateTime lastSaved;
}

/// Provider supplying the [WritingRepository] instance.
final writingRepositoryProvider = Provider<WritingRepository>((ref) {
  return const WritingRepositoryImpl();
});

/// Provider supplying the [WritingEvaluationService] instance.
final writingEvaluationServiceProvider = Provider<WritingEvaluationService>((
  ref,
) {
  return const LocalWritingEvaluationService();
});

/// Provider supplying all bundled writing activities across CEFR levels.
final allWritingActivitiesProvider = Provider<List<WritingActivity>>((ref) {
  return WritingContent.activities;
});

/// Family provider filtering writing activities by [WritingMode].
final writingActivitiesByModeProvider =
    Provider.family<List<WritingActivity>, WritingMode>((ref, mode) {
      final all = ref.watch(allWritingActivitiesProvider);
      return all.where((a) => a.mode == mode).toList();
    });

/// Family provider filtering writing activities by CEFR level.
final writingActivitiesByLevelProvider =
    Provider.family<List<WritingActivity>, String>((ref, level) {
      final all = ref.watch(allWritingActivitiesProvider);
      if (level.toUpperCase() == 'ALL') return all;
      return all
          .where((a) => a.level.toUpperCase() == level.toUpperCase())
          .toList();
    });

/// Notifier managing the active level filter on the Writing Hub screen.
class SelectedWritingLevelFilterNotifier extends Notifier<String> {
  @override
  String build() => 'All';

  @override
  set state(String value) => super.state = value;

  void setLevel(String level) {
    state = level;
  }
}

/// Active level filter on the Writing Hub screen ('All', 'A1', 'A2', 'B1', 'B2', 'C1').
final selectedWritingLevelFilterProvider =
    NotifierProvider<SelectedWritingLevelFilterNotifier, String>(
      SelectedWritingLevelFilterNotifier.new,
    );

/// Filtered writing activities according to the selected CEFR level filter.
final filteredWritingActivitiesProvider = Provider<List<WritingActivity>>((
  ref,
) {
  final level = ref.watch(selectedWritingLevelFilterProvider);
  return ref.watch(writingActivitiesByLevelProvider(level));
});

/// Provider for today's deterministic Daily Writing Challenge adapted to the user's level.
final dailyWritingChallengeProvider = Provider<WritingActivity>((ref) {
  final all = ref.watch(allWritingActivitiesProvider);
  final onboarding = ref.watch(onboardingNotifierProvider);
  final userLevel =
      (onboarding.estimatedLevel != null &&
          onboarding.estimatedLevel!.isNotEmpty)
      ? onboarding.estimatedLevel
      : (onboarding.currentLevel != null &&
                onboarding.currentLevel!.isNotEmpty &&
                onboarding.currentLevel != 'not_sure'
            ? onboarding.currentLevel
            : null);

  return DailyWritingSelector.selectDailyActivity(
    activities: all,
    date: DateTime.now(),
    userLevel: userLevel,
  );
});

/// Recommended writing activity based on the user's onboarding level.
final recommendedWritingActivityProvider = Provider<WritingActivity?>((ref) {
  final all = ref.watch(allWritingActivitiesProvider);
  if (all.isEmpty) return null;

  final onboarding = ref.watch(onboardingNotifierProvider);
  final userLevel =
      (onboarding.estimatedLevel != null &&
          onboarding.estimatedLevel!.isNotEmpty)
      ? onboarding.estimatedLevel
      : (onboarding.currentLevel != null &&
                onboarding.currentLevel!.isNotEmpty &&
                onboarding.currentLevel != 'not_sure'
            ? onboarding.currentLevel
            : null);

  if (userLevel != null && userLevel.isNotEmpty) {
    final matching = all
        .where((a) => a.level.toUpperCase() == userLevel.toUpperCase())
        .toList();
    if (matching.isNotEmpty) return matching.first;
  }

  return all.first;
});

/// Provider inspecting local storage for an unfinished writing session draft.
final unfinishedWritingSessionProvider = Provider<UnfinishedWritingData?>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final rawData = prefs.getString(StorageKeys.unfinishedWritingSession);
  if (rawData == null || rawData.isEmpty) return null;

  try {
    final map = jsonDecode(rawData) as Map<String, dynamic>;
    final activityId = map['activityId'] as String?;
    if (activityId == null || activityId.isEmpty) return null;

    final all = ref.watch(allWritingActivitiesProvider);
    final activity = all.firstWhere((a) => a.id == activityId);

    final draftText = map['draftText'] as String? ?? '';
    final wordCount = map['wordCount'] as int? ?? 0;
    final lastSavedMillis = map['lastSaved'] as int?;
    final lastSaved = lastSavedMillis != null
        ? DateTime.fromMillisecondsSinceEpoch(lastSavedMillis)
        : DateTime.now();

    return UnfinishedWritingData(
      activity: activity,
      draftText: draftText,
      wordCount: wordCount,
      lastSaved: lastSaved,
    );
  } catch (_) {
    return null;
  }
});
