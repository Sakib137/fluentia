import 'package:flutter/material.dart';

import '../../../../app/theme/design_system.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/models/reading_mode.dart';

/// Card component representing a reading practice mode on the Reading Hub.
class ReadingModeCard extends StatelessWidget {
  const ReadingModeCard({
    super.key,
    required this.mode,
    required this.activityCount,
    this.badge,
    required this.onTap,
  });

  final ReadingMode mode;
  final int activityCount;
  final String? badge;
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
          // Icon and count badge row
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.teal900.withValues(alpha: 0.3)
                      : AppColors.teal50,
                  borderRadius: AppRadii.roundedMd,
                ),
                child: Center(
                  child: Icon(
                    mode.icon,
                    color: isDark ? AppColors.teal300 : AppColors.teal700,
                    size: AppIconSizes.md,
                  ),
                ),
              ),
              const Spacer(),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.teal900.withValues(alpha: 0.3)
                        : AppColors.teal50,
                    borderRadius: AppRadii.roundedFull,
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      fontSize: AppFontSizes.caption,
                      fontWeight: AppFontWeights.bold,
                      color: isDark ? AppColors.teal300 : AppColors.teal700,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs + 2,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.slate800 : AppColors.slate100,
                    borderRadius: AppRadii.roundedFull,
                  ),
                  child: Text(
                    '$activityCount drills',
                    style: TextStyle(
                      fontSize: AppFontSizes.caption,
                      fontWeight: AppFontWeights.medium,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Title
          Text(
            mode.title,
            style: TextStyle(
              fontSize: AppFontSizes.bodyLarge,
              fontWeight: AppFontWeights.bold,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // Description
          Text(
            mode.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppFontSizes.bodySmall,
              height: 1.4,
              color: isDark
                  ? AppColors.darkTextMuted
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Footer link
          Row(
            children: [
              Text(
                'Start Practice',
                style: TextStyle(
                  fontSize: AppFontSizes.bodySmall,
                  fontWeight: AppFontWeights.semiBold,
                  color: isDark ? AppColors.teal300 : AppColors.teal700,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: isDark ? AppColors.teal300 : AppColors.teal700,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
