import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/preferences_service.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../data/datasources/reading_content.dart';
import '../../data/repositories/reading_repository_impl.dart';
import '../../domain/models/reading_activity.dart';
import '../../domain/models/reading_mode.dart';
import '../../domain/repositories/reading_repository.dart';
import '../../domain/services/daily_reading_selector.dart';

/// Provider supplying the [ReadingRepository] instance.
final readingRepositoryProvider = Provider<ReadingRepository>((ref) {
  return const ReadingRepositoryImpl();
});

/// Provider supplying all bundled reading activities across CEFR levels.
final allReadingActivitiesProvider = Provider<List<ReadingActivity>>((ref) {
  return ReadingContent.activities;
});

/// Family provider filtering reading activities by [ReadingMode].
final readingActivitiesByModeProvider =
    Provider.family<List<ReadingActivity>, ReadingMode>((ref, mode) {
      final all = ref.watch(allReadingActivitiesProvider);
      return all.where((a) => a.mode == mode).toList();
    });

/// Family provider filtering reading activities by CEFR level.
final readingActivitiesByLevelProvider =
    Provider.family<List<ReadingActivity>, String>((ref, level) {
      final all = ref.watch(allReadingActivitiesProvider);
      if (level.toUpperCase() == 'ALL') return all;
      return all
          .where((a) => a.level.toUpperCase() == level.toUpperCase())
          .toList();
    });

/// Notifier managing the active level filter on the Reading Hub screen.
class SelectedReadingLevelFilterNotifier extends Notifier<String> {
  @override
  String build() => 'All';

  @override
  set state(String value) => super.state = value;

  void setLevel(String level) {
    state = level;
  }
}

/// Active level filter on the Reading Hub screen ('All', 'A1', 'A2', 'B1', 'B2', 'C1').
final selectedReadingLevelFilterProvider =
    NotifierProvider<SelectedReadingLevelFilterNotifier, String>(
      SelectedReadingLevelFilterNotifier.new,
    );

/// Filtered reading activities according to the selected CEFR level filter.
final filteredReadingActivitiesProvider = Provider<List<ReadingActivity>>((
  ref,
) {
  final level = ref.watch(selectedReadingLevelFilterProvider);
  return ref.watch(readingActivitiesByLevelProvider(level));
});

/// Provider for today's deterministic Daily Reading Challenge adapted to the user's level.
final dailyReadingChallengeProvider = Provider<ReadingActivity>((ref) {
  final all = ref.watch(allReadingActivitiesProvider);
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

  return DailyReadingSelector.selectDailyActivity(
    activities: all,
    date: DateTime.now(),
    userLevel: userLevel,
  );
});

/// Recommended reading activity based on the user's onboarding level.
final recommendedReadingActivityProvider = Provider<ReadingActivity?>((ref) {
  final all = ref.watch(allReadingActivitiesProvider);
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

/// Local preference keys for saving unfinished continue-reading session state.
const String kContinueReadingActivityIdKey =
    'fluentia_continue_reading_activity_id';
const String kContinueReadingQuestionIndexKey =
    'fluentia_continue_reading_question_index';

/// Provider inspecting local storage for an unfinished reading session.
final unfinishedReadingSessionProvider = Provider<ReadingActivity?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final activityId = prefs.getString(kContinueReadingActivityIdKey);
  if (activityId == null || activityId.isEmpty) return null;

  final all = ref.watch(allReadingActivitiesProvider);
  try {
    return all.firstWhere((a) => a.id == activityId);
  } catch (_) {
    return null;
  }
});
