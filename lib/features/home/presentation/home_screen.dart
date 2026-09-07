import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/design_system.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/widgets.dart';

/// Dashboard screen displaying daily streak, daily challenge, quick practice skill cards, and foundation phase notice.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      appBar: const FluentAppBar(
        title: AppConstants.appName,
        subtitle: AppStrings.homeSubtitle,
      ),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          // Daily Target & Streak Card
          AppCard(
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.dailyGoalTitle,
                      style: TextStyle(
                        fontSize: AppFontSizes.labelMedium,
                        fontWeight: AppFontWeights.semiBold,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const StreakBadge(count: 3),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '0',
                      style: TextStyle(
                        fontSize: AppFontSizes.displayLarge,
                        fontWeight: AppFontWeights.bold,
                        letterSpacing: -0.5,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      ' / 15 min',
                      style: TextStyle(
                        fontSize: AppFontSizes.titleMedium,
                        fontWeight: AppFontWeights.medium,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const ProgressBar(value: 0.05, height: 6.0),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Daily Challenge Banner
          PracticeCard(
            title: AppStrings.dailyChallengeTitle,
            description: 'Review 10 words & practice pronunciation',
            icon: Icons.flag_rounded,
            badge: 'Daily',
            durationMinutes: 5,
            onStart: () => context.push(AppRoutes.challenge),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Quick Practice Section
          const SectionHeader(
            title: AppStrings.quickPracticeTitle,
            subtitle: 'Focus on your core language competencies',
          ),
          const SizedBox(height: AppSpacing.xs),

          SkillCard(
            icon: Icons.mic_rounded,
            title: AppStrings.speakingTitle,
            subtitle: AppStrings.speakingDesc,
            level: 'B1',
            onTap: () => context.push(AppRoutes.practiceSpeaking),
          ),
          const SizedBox(height: AppSpacing.sm),
          SkillCard(
            icon: Icons.headphones_rounded,
            title: AppStrings.listeningTitle,
            subtitle: AppStrings.listeningDesc,
            level: 'B1',
            onTap: () => context.push(AppRoutes.practiceListening),
          ),
          const SizedBox(height: AppSpacing.sm),
          SkillCard(
            icon: Icons.menu_book_rounded,
            title: AppStrings.readingTitle,
            subtitle: AppStrings.readingDesc,
            level: 'B1',
            onTap: () => context.push(AppRoutes.practiceReading),
          ),
          const SizedBox(height: AppSpacing.sm),
          SkillCard(
            icon: Icons.edit_note_rounded,
            title: AppStrings.writingTitle,
            subtitle: AppStrings.writingDesc,
            level: 'B1',
            onTap: () => context.push(AppRoutes.practiceWriting),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Foundation Phase info callout
          AppCard(
            backgroundColor: isDark
                ? AppColors.darkSurfaceElevated
                : AppColors.lightSurfaceSecondary,
            borderColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            padding: AppSpacing.cardPaddingDense,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: AppIconSizes.md,
                  color: isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    AppStrings.foundationPhaseNotice,
                    style: TextStyle(
                      fontSize: AppFontSizes.bodySmall,
                      height: 1.45,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
