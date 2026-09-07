import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/design_system.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../domain/models/practice_models.dart';
import '../providers/practice_providers.dart';

/// Screen celebrating session completion, displaying metrics and navigation actions.
class PracticeResultScreen extends ConsumerWidget {
  const PracticeResultScreen({
    super.key,
    required this.skillId,
  });

  final String skillId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDarkMode;
    final skill = PracticeSkill.fromId(skillId);
    final sessionState = ref.watch(practiceSessionControllerProvider);
    final session = sessionState.session;

    final durationMinutes = session != null ? (session.durationSeconds / 60).ceil() : 5;
    final scoreText = session?.score != null ? '${session!.score!.toInt()}%' : '85%';
    final activitiesCount = session?.totalActivities ?? 3;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _navigateBack(context, ref);
        }
      },
      child: Scaffold(
        appBar: const FluentAppBar(
          title: 'Session Result',
          showBackButton: false,
        ),
        body: SafeArea(
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                // Celebration Badge
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.primary900.withValues(alpha: 0.5) : AppColors.primary50,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.primary700 : AppColors.primary200,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: AppIconSizes.xxl,
                    color: isDark ? AppColors.primary300 : AppColors.primary600,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Practice Complete ✓',
                  style: TextStyle(
                    fontSize: AppFontSizes.headlineMedium,
                    fontWeight: AppFontWeights.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  skill.title,
                  style: TextStyle(
                    fontSize: AppFontSizes.titleMedium,
                    fontWeight: AppFontWeights.medium,
                    color: isDark ? AppColors.primary300 : AppColors.primary700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                // Stats Card
                Container(
                  padding: AppSpacing.cardPadding,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: AppRadii.roundedXl,
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                    boxShadow: isDark ? AppShadows.darkCard : AppShadows.card,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatColumn(
                        label: 'Practiced',
                        value: '$durationMinutes min',
                        icon: Icons.timer_outlined,
                        isDark: isDark,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                      _StatColumn(
                        label: 'Score',
                        value: scoreText,
                        icon: Icons.grade_outlined,
                        isDark: isDark,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                      _StatColumn(
                        label: 'Activities',
                        value: '$activitiesCount',
                        icon: Icons.task_alt_rounded,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Motivational note
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Text(
                    'Great work! Every focused session moves you closer to spontaneous, confident English fluency.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppFontSizes.bodyMedium,
                      height: 1.5,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
                const Spacer(),
                // Action Buttons
                PrimaryButton(
                  label: 'Continue',
                  icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                  onPressed: () => _navigateBack(context, ref),
                ),
                const SizedBox(height: AppSpacing.sm),
                SecondaryButton(
                  label: 'Practice Again',
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () {
                    ref.invalidate(dailyProgressProvider);
                    ref.invalidate(streakProvider);
                    ref.invalidate(progressSnapshotProvider);
                    ref.invalidate(practiceHistoryProvider);
                    context.pushReplacement('/practice/${skill.id}/intro');
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateBack(BuildContext context, WidgetRef ref) {
    // Refresh Home daily goal and streak providers so newly earned minutes display immediately
    ref.invalidate(dailyProgressProvider);
    ref.invalidate(streakProvider);
    ref.invalidate(progressSnapshotProvider);
    ref.invalidate(practiceHistoryProvider);
    context.go(AppRoutes.practice);
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.value,
    required this.icon,
    required this.isDark,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: AppIconSizes.md,
          color: isDark ? AppColors.primary300 : AppColors.primary700,
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          value,
          style: TextStyle(
            fontSize: AppFontSizes.titleMedium,
            fontWeight: AppFontWeights.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          label,
          style: TextStyle(
            fontSize: AppFontSizes.caption,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }
}
