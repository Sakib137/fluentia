import 'package:flutter/material.dart';
import '../../../../app/theme/design_system.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/models/speaking_mode.dart';

/// Card displayed on the Speaking Hub for each speaking mode.
class ModeSelectionCard extends StatelessWidget {
  const ModeSelectionCard({
    super.key,
    required this.mode,
    required this.activityCount,
    required this.onTap,
    this.badge,
  });

  final SpeakingMode mode;
  final int activityCount;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return AppCard(
      padding: AppSpacing.cardPadding,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mode Icon Box
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: isDark ? AppColors.slate800 : AppColors.primary50,
              borderRadius: AppRadii.roundedLg,
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.primary100,
              ),
            ),
            child: Icon(
              mode.icon,
              size: AppIconSizes.lg,
              color: isDark ? AppColors.primary300 : AppColors.primary700,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      mode.title,
                      style: TextStyle(
                        fontSize: AppFontSizes.titleMedium,
                        fontWeight: AppFontWeights.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs + 2,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.primary900.withValues(alpha: 0.5)
                              : AppColors.primary50,
                          borderRadius: AppRadii.roundedFull,
                          border: Border.all(
                            color: isDark
                                ? AppColors.primary700
                                : AppColors.primary200,
                          ),
                        ),
                        child: Text(
                          badge!,
                          style: TextStyle(
                            fontSize: AppFontSizes.caption - 1,
                            fontWeight: AppFontWeights.bold,
                            color: isDark
                                ? AppColors.primary300
                                : AppColors.primary700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  mode.description,
                  style: TextStyle(
                    fontSize: AppFontSizes.bodySmall,
                    height: 1.4,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Text(
                      '$activityCount activities',
                      style: TextStyle(
                        fontSize: AppFontSizes.caption,
                        fontWeight: AppFontWeights.medium,
                        color: isDark ? AppColors.slate400 : AppColors.slate600,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '•',
                      style: TextStyle(
                        color: isDark ? AppColors.slate500 : AppColors.slate400,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      mode.badgeText,
                      style: TextStyle(
                        fontSize: AppFontSizes.caption,
                        fontWeight: AppFontWeights.medium,
                        color: isDark
                            ? AppColors.primary300
                            : AppColors.primary700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Icon(
            Icons.chevron_right_rounded,
            color: isDark ? AppColors.slate500 : AppColors.slate400,
            size: AppIconSizes.md,
          ),
        ],
      ),
    );
  }
}
