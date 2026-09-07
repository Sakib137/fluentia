import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/design_system.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/progress_bar.dart';
import '../../data/models/home_models.dart';
import '../providers/home_providers.dart';

/// Interactive Daily Goal Card reflecting target practice minutes, real-time completion,
/// and dynamic action buttons.
class DailyGoalCard extends ConsumerWidget {
  const DailyGoalCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyProgressAsync = ref.watch(dailyProgressProvider);
    final isDark = context.isDarkMode;

    final progress = dailyProgressAsync.value ?? DailyProgressState.initial();

    final ctaLabel = progress.isCompleted
        ? 'Practice Again'
        : (progress.practicedMinutes > 0 ? 'Continue Practice' : "Start Today's Practice");

    final statusText = progress.isCompleted
        ? 'Daily target reached! 🎉'
        : '${progress.remainingMinutes} min remaining';

    return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            borderColor: progress.isCompleted
                ? (isDark ? AppColors.primary600.withValues(alpha: 0.5) : AppColors.primary300)
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.xs + 2),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.primary900 : AppColors.primary50,
                            borderRadius: AppRadii.roundedMd,
                          ),
                          child: Icon(
                            progress.isCompleted
                                ? Icons.check_circle_rounded
                                : Icons.flag_circle_rounded,
                            size: AppIconSizes.md,
                            color: isDark ? AppColors.primary300 : AppColors.primary600,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.dailyGoalTitle,
                              style: TextStyle(
                                fontSize: AppFontSizes.titleMedium,
                                fontWeight: AppFontWeights.semiBold,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              statusText,
                              style: TextStyle(
                                fontSize: AppFontSizes.caption,
                                fontWeight: AppFontWeights.medium,
                                color: progress.isCompleted
                                    ? (isDark ? AppColors.primary300 : AppColors.primary700)
                                    : (isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      '${progress.practicedMinutes} / ${progress.targetMinutes} min',
                      style: TextStyle(
                        fontSize: AppFontSizes.titleMedium,
                        fontWeight: AppFontWeights.bold,
                        color: isDark ? AppColors.primary300 : AppColors.primary600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                ProgressBar(
                  value: progress.progressFraction,
                  height: 8.0,
                  color: progress.isCompleted
                      ? AppColors.primary500
                      : (isDark ? AppColors.primary400 : AppColors.primary600),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        text: ctaLabel,
                        icon: Icon(
                          progress.isCompleted
                              ? Icons.refresh_rounded
                              : Icons.arrow_forward_rounded,
                          size: AppIconSizes.sm,
                        ),
                        onPressed: () {
                          context.go(AppRoutes.practice);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
  }
}
