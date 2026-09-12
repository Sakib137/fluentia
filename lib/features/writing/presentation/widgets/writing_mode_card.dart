import 'package:flutter/material.dart';

import '../../../../app/theme/design_system.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/models/writing_mode.dart';

/// Card component representing a writing practice mode on the Writing Hub.
class WritingModeCard extends StatelessWidget {
  const WritingModeCard({
    super.key,
    required this.mode,
    required this.activityCount,
    this.badge,
    required this.onTap,
  });

  final WritingMode mode;
  final int activityCount;
  final String? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
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
              fontSize: AppFontSizes.titleSmall,
              fontWeight: AppFontWeights.bold,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),

          // Description
          Text(
            mode.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppFontSizes.caption,
              color: isDark
                  ? AppColors.darkTextMuted
                  : AppColors.lightTextSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
