import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/design_system.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/widgets.dart';

/// Progress screen displaying streaks, skill statistics, and milestone markers.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      appBar: const FluentAppBar(
        title: AppStrings.progressTitle,
        subtitle: AppStrings.progressSubtitle,
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            // Streak Highlight
            AppCard(
              padding: AppSpacing.cardPadding,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.slate800 : AppColors.sage50,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.sage700 : AppColors.sage100,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.local_fire_department_rounded,
                      size: AppIconSizes.xl,
                      color: isDark ? AppColors.sage400 : AppColors.sage600,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '3 Days Active',
                              style: TextStyle(
                                fontSize: AppFontSizes.titleMedium,
                                fontWeight: AppFontWeights.bold,
                                letterSpacing: -0.3,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            const StreakBadge(count: 3, compact: true),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Practice today to extend your streak to 4 days.',
                          style: TextStyle(
                            fontSize: AppFontSizes.bodySmall,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Overview Metrics Header
            SectionHeader(
              title: 'Overview Metrics',
              subtitle: 'Cumulative activity and retention',
              actionLabel: 'View Trends',
              onAction: () => context.push(AppRoutes.progressStatistics),
            ),
            const SizedBox(height: AppSpacing.xs),

            // Overview Metrics Grid
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Lessons Done',
                    value: '12',
                    icon: Icons.check_circle_outline_rounded,
                    iconColor: isDark
                        ? AppColors.primary400
                        : AppColors.primary600,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: StatCard(
                    label: 'Words Mastered',
                    value: '84',
                    icon: Icons.spellcheck_rounded,
                    iconColor: isDark ? AppColors.sage400 : AppColors.sage600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Study Time',
                    value: '1h 45m',
                    icon: Icons.timer_outlined,
                    iconColor: isDark
                        ? AppColors.warning400
                        : AppColors.warning600,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: StatCard(
                    label: 'Proficiency',
                    value: 'B1 Intermediate',
                    icon: Icons.trending_up_rounded,
                    iconColor: isDark
                        ? AppColors.info400
                        : AppColors.primary700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Practice Distribution Breakdown
            const SectionHeader(
              title: 'Skill Breakdown',
              subtitle: 'Targeted practice mastery by category',
            ),
            const SizedBox(height: AppSpacing.xs),

            AppCard(
              padding: AppSpacing.cardPadding,
              child: Column(
                children: [
                  _buildSkillBar(
                    context,
                    'Speaking',
                    0.35,
                    AppColors.primary500,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildSkillBar(
                    context,
                    'Listening',
                    0.50,
                    AppColors.primary700,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildSkillBar(context, 'Reading', 0.40, AppColors.sage500),
                  const SizedBox(height: AppSpacing.md),
                  _buildSkillBar(
                    context,
                    'Writing',
                    0.20,
                    AppColors.warning500,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            SecondaryButton(
              text: 'View Milestones & Badges',
              icon: const Icon(Icons.emoji_events_outlined, size: 18),
              onPressed: () => context.push(AppRoutes.progressAchievements),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillBar(
    BuildContext context,
    String skill,
    double ratio,
    Color color,
  ) {
    final isDark = context.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              skill,
              style: TextStyle(
                fontSize: AppFontSizes.bodyMedium,
                fontWeight: AppFontWeights.medium,
                color: isDark ? AppColors.slate300 : AppColors.slate700,
              ),
            ),
            Text(
              '${(ratio * 100).toInt()}%',
              style: TextStyle(
                fontSize: AppFontSizes.bodySmall,
                fontWeight: AppFontWeights.semiBold,
                color: isDark
                    ? AppColors.darkTextMuted
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ProgressBar(value: ratio, height: 6.0, color: color),
      ],
    );
  }
}
