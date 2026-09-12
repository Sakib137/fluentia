import 'package:flutter/material.dart';

import '../../../../app/theme/design_system.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/models/writing_activity.dart';

/// Card displaying a writing activity preview in the Writing Hub list.
class WritingPromptCard extends StatelessWidget {
  const WritingPromptCard({
    super.key,
    required this.activity,
    required this.onTap,
  });

  final WritingActivity activity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return AppCard(
      onTap: onTap,
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Level + Mode + Duration
          Row(
            children: [
              // CEFR Level pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs + 2,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.teal900.withValues(alpha: 0.3)
                      : AppColors.teal50,
                  borderRadius: AppRadii.roundedSm,
                  border: Border.all(
                    color: isDark
                        ? AppColors.teal700.withValues(alpha: 0.4)
                        : AppColors.teal200,
                  ),
                ),
                child: Text(
                  activity.level,
                  style: TextStyle(
                    fontSize: AppFontSizes.caption,
                    fontWeight: AppFontWeights.bold,
                    color: isDark ? AppColors.teal300 : AppColors.teal700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),

              // Mode pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs + 2,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.slate800 : AppColors.slate100,
                  borderRadius: AppRadii.roundedSm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      activity.mode.icon,
                      size: 12,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      activity.mode.title,
                      style: TextStyle(
                        fontSize: AppFontSizes.caption,
                        fontWeight: AppFontWeights.medium,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Duration
              Text(
                '~${activity.estimatedDurationMinutes} min',
                style: TextStyle(
                  fontSize: AppFontSizes.caption,
                  color: isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Title
          Text(
            activity.title,
            style: TextStyle(
              fontSize: AppFontSizes.bodyLarge,
              fontWeight: AppFontWeights.semiBold,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),

          // Prompt Snippet
          Text(
            activity.prompt,
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
          const SizedBox(height: AppSpacing.sm),

          // Footer Row: Category and Word Constraint or Action
          Row(
            children: [
              Text(
                activity.category,
                style: TextStyle(
                  fontSize: AppFontSizes.caption,
                  fontWeight: AppFontWeights.medium,
                  color: isDark ? AppColors.teal300 : AppColors.teal700,
                ),
              ),
              if (activity.minimumWords > 0 || activity.maximumWords > 0) ...[
                Text(
                  ' • ',
                  style: TextStyle(
                    fontSize: AppFontSizes.caption,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextSecondary,
                  ),
                ),
                Text(
                  activity.maximumWords > 0
                      ? '${activity.minimumWords}–${activity.maximumWords} words'
                      : 'Min ${activity.minimumWords} words',
                  style: TextStyle(
                    fontSize: AppFontSizes.caption,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: isDark
                    ? AppColors.darkTextMuted
                    : AppColors.lightTextSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
