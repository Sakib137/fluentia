import 'package:flutter/material.dart';

import '../../app/theme/design_system.dart';
import '../extensions/context_extensions.dart';
import 'app_card.dart';
import 'level_badge.dart';
import 'progress_bar.dart';

/// Educational skill card for speaking, listening, reading, writing, vocabulary, and grammar.
class SkillCard extends StatelessWidget {
  const SkillCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badgeText,
    this.level,
    this.progress,
    this.onTap,
    this.isCompleted = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? badgeText;
  final String? level;
  final double? progress;
  final VoidCallback? onTap;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return AppCard(
      onTap: onTap,
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.slate800 : AppColors.primary50,
                  borderRadius: AppRadii.roundedMd,
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.primary100,
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  size: AppIconSizes.lg,
                  color: isDark ? AppColors.primary300 : AppColors.primary700,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: AppFontSizes.titleMedium,
                              fontWeight: AppFontWeights.semiBold,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                        if (level != null) LevelBadge(level: level!),
                        if (badgeText != null && level == null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xxs,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.slate800
                                  : AppColors.slate100,
                              borderRadius: AppRadii.roundedFull,
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              badgeText!,
                              style: TextStyle(
                                fontSize: AppFontSizes.labelSmall,
                                fontWeight: AppFontWeights.medium,
                                color: isDark
                                    ? AppColors.slate300
                                    : AppColors.slate600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppFontSizes.bodySmall,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                isCompleted
                    ? Icons.check_circle_rounded
                    : Icons.arrow_forward_ios_rounded,
                size: isCompleted ? AppIconSizes.md : AppIconSizes.sm - 2,
                color: isCompleted
                    ? (isDark ? AppColors.sage500 : AppColors.sage600)
                    : (isDark ? AppColors.slate600 : AppColors.slate400),
              ),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: AppSpacing.md),
            ProgressBar(value: progress!, height: 4.0),
          ],
        ],
      ),
    );
  }
}
