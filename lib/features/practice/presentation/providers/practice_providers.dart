import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../data/repositories/practice_repository.dart';
import '../../domain/models/practice_models.dart';
import '../../domain/services/practice_recommendation_service.dart';
import 'practice_session_controller.dart';

/// Provider for the pure recommendation and ordering service.
final practiceRecommendationServiceProvider =
    Provider<PracticeRecommendationService>((ref) {
      return const PracticeRecommendationService();
    });

/// Provider for the SQLite-backed practice repository.
final practiceRepositoryProvider = Provider<PracticeRepository>((ref) {
  final db = ref.watch(databaseServiceProvider);
  final recommender = ref.watch(practiceRecommendationServiceProvider);
  return SqlitePracticeRepository(db, recommender);
});

/// Provider yielding the 4 core practice modules ordered by user onboarding goals.
final practiceModulesProvider = Provider<List<PracticeModuleInfo>>((ref) {
  final onboarding = ref.watch(onboardingNotifierProvider);
  final recommender = ref.watch(practiceRecommendationServiceProvider);
  final orderedSkills = recommender.orderSkills(onboarding.selectedGoals);

  return orderedSkills.asMap().entries.map((entry) {
    final idx = entry.key;
    final skill = entry.value;
    final isFirst = idx == 0;
    final userLevel =
        (onboarding.estimatedLevel != null &&
            onboarding.estimatedLevel!.isNotEmpty)
        ? onboarding.estimatedLevel!
        : (onboarding.currentLevel != null &&
                  onboarding.currentLevel!.isNotEmpty &&
                  onboarding.currentLevel != 'not_sure'
              ? onboarding.currentLevel!
              : 'B1');

    return PracticeModuleInfo(
      skill: skill,
      title: skill.title,
      description: skill.description,
      durationMinutes: skill.defaultDurationMinutes,
      icon: skill.icon,
      badge: isFirst ? 'Recommended' : skill.badgeText,
      metadata: '$userLevel • 3 activities',
      isEnabled: true,
      isRecommended: isFirst,
    );
  }).toList();
});

/// Provider for the deterministically recommended Quick Practice activity.
final quickPracticeRecommendationProvider = FutureProvider<PracticeActivity>((
  ref,
) async {
  final repo = ref.watch(practiceRepositoryProvider);
  final onboarding = ref.watch(onboardingNotifierProvider);
  final userLevel =
      (onboarding.estimatedLevel != null &&
          onboarding.estimatedLevel!.isNotEmpty)
      ? onboarding.estimatedLevel!
      : (onboarding.currentLevel != null &&
                onboarding.currentLevel!.isNotEmpty &&
                onboarding.currentLevel != 'not_sure'
            ? onboarding.currentLevel!
            : 'B1');

  return repo.getRecommendedActivity(
    level: userLevel,
    goals: onboarding.selectedGoals,
    date: DateTime.now(),
  );
});

/// Controller provider managing active practice session flow.
final practiceSessionControllerProvider =
    NotifierProvider<PracticeSessionController, PracticeSessionState>(
      PracticeSessionController.new,
    );

/// Provider for completed practice history.
final practiceHistoryProvider = FutureProvider<List<PracticeSession>>((
  ref,
) async {
  final repo = ref.watch(practiceRepositoryProvider);
  return repo.getSessionHistory();
});
