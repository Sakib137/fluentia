import 'package:flutter/material.dart';

import '../../app/theme/design_system.dart';
import '../extensions/context_extensions.dart';
import 'app_card.dart';

/// Card representing a distinct practice exercise or drill.
class PracticeCard extends StatelessWidget {
  const PracticeCard({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.psychology_rounded,
    this.durationMinutes,
    this.badge,
    this.onStart,
    this.isLocked = false,
  });

  final String title;
  final String description;
  final IconData icon;
  final int? durationMinutes;
  final String? badge;
  final VoidCallback? onStart;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return AppCard(
      onTap: isLocked ? null : onStart,
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  color: isLocked
                      ? (isDark ? AppColors.slate500 : AppColors.slate400)
                      : (isDark ? AppColors.primary300 : AppColors.primary700),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (durationMinutes != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs + 1,
                      ),
                      margin: const EdgeInsets.only(right: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.slate800 : AppColors.slate100,
                        borderRadius: AppRadii.roundedFull,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: AppIconSizes.xs,
                            color: isDark
                                ? AppColors.slate400
                                : AppColors.slate600,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            '$durationMinutes min',
                            style: TextStyle(
                              fontSize: AppFontSizes.caption,
                              fontWeight: AppFontWeights.medium,
                              color: isDark
                                  ? AppColors.slate300
                                  : AppColors.slate700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs + 1,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.slate800
                            : AppColors.primary50,
                        borderRadius: AppRadii.roundedFull,
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.primary100,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        badge!,
                        style: TextStyle(
                          fontSize: AppFontSizes.caption,
                          fontWeight: AppFontWeights.semiBold,
                          color: isDark
                              ? AppColors.primary300
                              : AppColors.primary700,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: TextStyle(
              fontSize: AppFontSizes.titleLarge,
              fontWeight: AppFontWeights.semiBold,
              color: isLocked
                  ? (isDark ? AppColors.slate500 : AppColors.slate400)
                  : (isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            description,
            style: TextStyle(
              fontSize: AppFontSizes.bodySmall,
              height: 1.45,
              color: isLocked
                  ? (isDark ? AppColors.slate600 : AppColors.slate400)
                  : (isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextSecondary),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(
                isLocked ? 'Locked' : 'Start Practice',
                style: TextStyle(
                  fontSize: AppFontSizes.labelMedium,
                  fontWeight: AppFontWeights.semiBold,
                  color: isLocked
                      ? (isDark ? AppColors.slate500 : AppColors.slate400)
                      : (isDark ? AppColors.primary400 : AppColors.primary600),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Icon(
                isLocked
                    ? Icons.lock_outline_rounded
                    : Icons.arrow_forward_rounded,
                size: AppIconSizes.sm,
                color: isLocked
                    ? (isDark ? AppColors.slate500 : AppColors.slate400)
                    : (isDark ? AppColors.primary400 : AppColors.primary600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
