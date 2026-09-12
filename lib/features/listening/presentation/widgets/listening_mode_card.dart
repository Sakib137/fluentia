import 'package:flutter/material.dart';

import '../../../../app/theme/design_system.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../domain/models/listening_mode.dart';

/// Reusable card displaying a Listening Mode with level badge, duration, and activity count.
class ListeningModeCard extends StatelessWidget {
  const ListeningModeCard({
    super.key,
    required this.mode,
    required this.activityCount,
    this.badge,
    required this.onTap,
  });

  final ListeningMode mode;
  final int activityCount;
  final String? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.roundedXl,
        child: Container(
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: AppRadii.roundedXl,
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Icon, Title & Badges
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.primary900.withValues(alpha: 0.4)
                          : AppColors.primary50,
                      borderRadius: AppRadii.roundedLg,
                      border: Border.all(
                        color: isDark
                            ? AppColors.primary700
                            : AppColors.primary200,
                      ),
                    ),
                    child: Icon(
                      mode.icon,
                      color: isDark
                          ? AppColors.primary300
                          : AppColors.primary700,
                      size: AppIconSizes.md,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                mode.title,
                                style: TextStyle(
                                  fontSize: AppFontSizes.titleMedium,
                                  fontWeight: AppFontWeights.bold,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                            ),
                            if (badge != null) ...[
                              const SizedBox(width: AppSpacing.xs),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xs,
                                  vertical: AppSpacing.xxs,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.primary900
                                      : AppColors.primary100,
                                  borderRadius: AppRadii.roundedFull,
                                ),
                                child: Text(
                                  badge!,
                                  style: TextStyle(
                                    fontSize: AppFontSizes.caption,
                                    fontWeight: AppFontWeights.bold,
                                    color: isDark
                                        ? AppColors.primary200
                                        : AppColors.primary800,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          mode.description,
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
              const SizedBox(height: AppSpacing.md),

              // Bottom Metadata Row: Recommended Level, Duration, Count
              Row(
                children: [
                  _buildMetaTag(
                    icon: Icons.signal_cellular_alt_rounded,
                    label: mode.recommendedLevel,
                    isDark: isDark,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _buildMetaTag(
                    icon: Icons.timer_outlined,
                    label: '${mode.defaultDurationMinutes} min',
                    isDark: isDark,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        '$activityCount ${activityCount == 1 ? 'drill' : 'drills'}',
                        style: TextStyle(
                          fontSize: AppFontSizes.caption,
                          fontWeight: AppFontWeights.semiBold,
                          color: isDark
                              ? AppColors.primary300
                              : AppColors.primary700,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: isDark
                            ? AppColors.primary300
                            : AppColors.primary700,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaTag({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs + 2,
        vertical: AppSpacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800 : AppColors.slate100,
        borderRadius: AppRadii.roundedFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isDark
                ? AppColors.darkTextMuted
                : AppColors.lightTextSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
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
    );
  }
}
