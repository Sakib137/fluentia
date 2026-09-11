import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/design_system.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/streak_badge.dart';
import '../providers/home_providers.dart';

/// Personalized top header displaying time-aware greeting, subtitle, and streak indicator.
class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greeting = ref.watch(timeGreetingProvider);
    final streakAsync = ref.watch(streakProvider);
    final dailyProgressAsync = ref.watch(dailyProgressProvider);
    final isDark = context.isDarkMode;

    final subtitle = dailyProgressAsync.when(
      data: (progress) {
        if (progress.isCompleted) {
          return 'Goal achieved today! Outstanding dedication. 🎉';
        } else if (progress.practicedMinutes > 0) {
          return "You're making solid progress. Keep going!";
        } else if (progress.isFirstDay) {
          return 'Welcome to your daily English habit.';
        } else {
          return "Ready for today's English practice?";
        }
      },
      loading: () => "Ready for today's English practice?",
      error: (_, _) => "Ready for today's English practice?",
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    fontSize: AppFontSizes.headlineLarge,
                    fontWeight: AppFontWeights.bold,
                    letterSpacing: -0.5,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs + 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: AppFontSizes.bodyMedium,
                    fontWeight: AppFontWeights.regular,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          streakAsync.when(
            data: (streak) => StreakBadge(
              count: streak.currentStreak,
              isActive: streak.isMaintainedToday,
            ),
            loading: () => const StreakBadge(count: 0, isActive: false),
            error: (_, _) => const StreakBadge(count: 0, isActive: false),
          ),
        ],
      ),
    );
  }
}
