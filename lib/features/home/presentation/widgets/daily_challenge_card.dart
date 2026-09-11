import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/design_system.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/progress_bar.dart';
import '../../data/models/home_models.dart';
import '../../domain/daily_challenge_generator.dart';
import '../providers/home_providers.dart';

/// Interactive Daily Challenge card displaying 5 deterministic activities for the day.
class DailyChallengeCard extends ConsumerWidget {
  const DailyChallengeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengeAsync = ref.watch(dailyChallengeProvider);
    final isDark = context.isDarkMode;
    final challenge =
        challengeAsync.value ??
        DailyChallengeGenerator.generate(date: DateTime.now());
    final completedCount = challenge.completedCount;
    final totalCount = challenge.totalCount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.task_alt_rounded,
                      size: AppIconSizes.md,
                      color: isDark
                          ? AppColors.primary300
                          : AppColors.primary600,
                    ),
                    const SizedBox(width: AppSpacing.xs + 2),
                    Text(
                      'Daily Challenge',
                      style: TextStyle(
                        fontSize: AppFontSizes.titleMedium,
                        fontWeight: AppFontWeights.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs + 1,
                  ),
                  decoration: BoxDecoration(
                    color: challenge.isAllCompleted
                        ? (isDark ? AppColors.primary900 : AppColors.primary50)
                        : (isDark ? AppColors.slate800 : AppColors.slate100),
                    borderRadius: AppRadii.roundedFull,
                    border: Border.all(
                      color: challenge.isAllCompleted
                          ? (isDark
                                ? AppColors.primary700
                                : AppColors.primary200)
                          : (isDark
                                ? AppColors.darkBorder
                                : AppColors.slate200),
                    ),
                  ),
                  child: Text(
                    '$completedCount / $totalCount completed',
                    style: TextStyle(
                      fontSize: AppFontSizes.caption,
                      fontWeight: AppFontWeights.semiBold,
                      color: challenge.isAllCompleted
                          ? (isDark
                                ? AppColors.primary300
                                : AppColors.primary700)
                          : (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ProgressBar(
              value: challenge.progressFraction,
              height: 6.0,
              color: challenge.isAllCompleted
                  ? AppColors.primary500
                  : (isDark ? AppColors.primary400 : AppColors.primary600),
            ),
            const SizedBox(height: AppSpacing.md),
            ...challenge.items.map((item) {
              return _ChallengeItemRow(
                item: item,
                onToggle: (val) {
                  ref
                      .read(dailyChallengeProvider.notifier)
                      .toggleItem(item.id, val);
                  if (val) {
                    // Also contribute duration minutes to today's practice
                    ref
                        .read(dailyProgressProvider.notifier)
                        .logPractice(
                          minutes: item.durationMinutes,
                          skillType: item.skillType,
                        );
                  }
                },
                onTapRow: () {
                  context.go(AppRoutes.practice);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ChallengeItemRow extends StatelessWidget {
  const _ChallengeItemRow({
    required this.item,
    required this.onToggle,
    required this.onTapRow,
  });

  final DailyChallengeItem item;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTapRow;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadii.roundedSm,
        child: InkWell(
          borderRadius: AppRadii.roundedSm,
          onTap: onTapRow,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xs + 2,
            ),
            child: Row(
              children: [
                // Accessible Checkbox tap target (min 48x48)
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: IconButton(
                      icon: Icon(
                        item.isCompleted
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: item.isCompleted
                            ? (isDark
                                  ? AppColors.primary400
                                  : AppColors.primary600)
                            : (isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.slate400),
                        size: AppIconSizes.md,
                      ),
                      onPressed: () => onToggle(!item.isCompleted),
                      tooltip: item.isCompleted
                          ? 'Mark incomplete'
                          : 'Mark complete',
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: AppFontSizes.bodyMedium,
                          fontWeight: AppFontWeights.medium,
                          decoration: item.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: item.isCompleted
                              ? (isDark
                                    ? AppColors.darkTextMuted
                                    : AppColors.lightTextMuted)
                              : (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.slate800
                                  : AppColors.slate100,
                              borderRadius: AppRadii.roundedXs,
                            ),
                            child: Text(
                              item.skillType,
                              style: TextStyle(
                                fontSize: AppFontSizes.labelSmall,
                                fontWeight: AppFontWeights.semiBold,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            '${item.durationMinutes} min',
                            style: TextStyle(
                              fontSize: AppFontSizes.labelSmall,
                              color: isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: AppIconSizes.sm,
                  color: isDark ? AppColors.darkTextMuted : AppColors.slate400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
