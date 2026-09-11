import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../data/models/home_models.dart';
import '../../data/repositories/home_repository.dart';
import '../../domain/practice_recommendation_engine.dart';

/// Provider for dynamic time greeting.
final timeGreetingProvider = Provider<String>((ref) {
  final now = DateTime.now();
  final hour = now.hour;
  if (hour >= 5 && hour < 12) {
    return 'Good morning 👋';
  } else if (hour >= 12 && hour < 17) {
    return 'Good afternoon 👋';
  } else {
    return 'Good evening 👋';
  }
});

/// Notifier for Daily Progress state.
class DailyProgressNotifier extends AsyncNotifier<DailyProgressState> {
  @override
  Future<DailyProgressState> build() async {
    final onboardingState = ref.watch(onboardingNotifierProvider);
    final target = onboardingState.dailyPracticeMinutes > 0
        ? onboardingState.dailyPracticeMinutes
        : 15;
    final repo = ref.watch(homeRepositoryProvider);
    return repo.getDailyProgress(DateTime.now(), targetMinutes: target);
  }

  /// Adds practiced minutes for a skill and reloads dependent state.
  Future<void> logPractice({
    required int minutes,
    required String skillType,
  }) async {
    final repo = ref.read(homeRepositoryProvider);
    await repo.logPracticeMinutes(DateTime.now(), minutes, skillType);
    ref.invalidateSelf();
    ref.invalidate(streakProvider);
    ref.invalidate(progressSnapshotProvider);
  }
}

final dailyProgressProvider =
    AsyncNotifierProvider<DailyProgressNotifier, DailyProgressState>(
      DailyProgressNotifier.new,
    );

/// Provider for user streak metrics.
final streakProvider = FutureProvider<StreakData>((ref) async {
  final repo = ref.watch(homeRepositoryProvider);
  final onboardingState = ref.watch(onboardingNotifierProvider);
  final target = onboardingState.dailyPracticeMinutes > 0
      ? onboardingState.dailyPracticeMinutes
      : 15;
  return repo.getStreakData(DateTime.now(), targetMinutes: target);
});

/// Notifier for the 5-item Daily Challenge.
class DailyChallengeNotifier extends AsyncNotifier<DailyChallengeState> {
  @override
  Future<DailyChallengeState> build() async {
    final repo = ref.watch(homeRepositoryProvider);
    return repo.getDailyChallenge(DateTime.now());
  }

  /// Toggles an activity's completion state.
  Future<void> toggleItem(String challengeId, bool isCompleted) async {
    final repo = ref.read(homeRepositoryProvider);
    await repo.toggleChallengeItem(DateTime.now(), challengeId, isCompleted);

    // Optimistically update or refresh
    final current = state.value;
    if (current != null) {
      final updatedItems = current.items.map((item) {
        if (item.id == challengeId) {
          return item.copyWith(isCompleted: isCompleted);
        }
        return item;
      }).toList();
      state = AsyncData(
        DailyChallengeState(dateKey: current.dateKey, items: updatedItems),
      );
    } else {
      ref.invalidateSelf();
    }
  }
}

final dailyChallengeProvider =
    AsyncNotifierProvider<DailyChallengeNotifier, DailyChallengeState>(
      DailyChallengeNotifier.new,
    );

/// Notifier for the Word of the Day.
class WordOfTheDayNotifier extends AsyncNotifier<WordOfTheDay> {
  @override
  Future<WordOfTheDay> build() async {
    final repo = ref.watch(homeRepositoryProvider);
    return repo.getWordOfTheDay(DateTime.now());
  }

  /// Toggles whether today's word is saved in bookmarks.
  Future<void> toggleBookmark() async {
    final current = state.value;
    if (current == null) return;

    final repo = ref.read(homeRepositoryProvider);
    final isSaved = await repo.toggleBookmarkWord(current);
    state = AsyncData(current.copyWith(isSaved: isSaved));
    ref.invalidate(progressSnapshotProvider);
  }
}

final wordOfTheDayProvider =
    AsyncNotifierProvider<WordOfTheDayNotifier, WordOfTheDay>(
      WordOfTheDayNotifier.new,
    );

/// Provider for personalized quick practice recommendations.
final quickPracticeRecommendationsProvider = Provider<List<QuickPracticeItem>>((
  ref,
) {
  final onboardingState = ref.watch(onboardingNotifierProvider);
  return PracticeRecommendationEngine.rankRecommendations(
    onboardingState.selectedGoals,
  );
});

/// Provider for Progress Snapshot summary statistics.
final progressSnapshotProvider = FutureProvider<ProgressSnapshotData>((
  ref,
) async {
  final repo = ref.watch(homeRepositoryProvider);
  final onboardingState = ref.watch(onboardingNotifierProvider);

  final rawLevel = onboardingState.currentLevel;
  String cefr = rawLevel != null ? rawLevel.toUpperCase() : 'B1';
  if (cefr == 'NOT_SURE' || cefr.isEmpty) {
    cefr = 'B1';
  }

  final levelTitles = {
    'A1': 'Beginner',
    'A2': 'Elementary',
    'B1': 'Intermediate',
    'B2': 'Upper Intermediate',
    'C1': 'Advanced',
    'C2': 'Mastery',
  };

  final title = levelTitles[cefr] ?? 'Intermediate';

  return repo.getProgressSnapshot(cefrLevel: cefr, levelTitle: title);
});
