import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../extensions/context_extensions.dart';

enum FluentBadgeVariant { primary, neutral, success, warning }

/// A compact pill badge for levels, tags, and status counters.
class FluentBadge extends StatelessWidget {
  const FluentBadge({
    super.key,
    required this.label,
    this.variant = FluentBadgeVariant.primary,
    this.icon,
  });

  final String label;
  final FluentBadgeVariant variant;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    final (bg, fg, border) = _getColors(isDark);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppSpacing.roundedFull,
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  (Color bg, Color fg, Color border) _getColors(bool isDark) {
    switch (variant) {
      case FluentBadgeVariant.primary:
        return isDark
            ? (AppColors.slate800, AppColors.primary400, AppColors.primary700)
            : (AppColors.primary50, AppColors.primary700, AppColors.primary200);
      case FluentBadgeVariant.neutral:
        return isDark
            ? (AppColors.slate800, AppColors.slate300, AppColors.slate700)
            : (AppColors.slate100, AppColors.slate700, AppColors.slate200);
      case FluentBadgeVariant.success:
        return isDark
            ? (AppColors.slate800, AppColors.sage500, AppColors.sage600)
            : (AppColors.sage50, AppColors.sage600, AppColors.sage100);
      case FluentBadgeVariant.warning:
        return isDark
            ? (AppColors.slate800, AppColors.warning500, AppColors.warning600)
            : (AppColors.warning50, AppColors.warning600, AppColors.warning100);
    }
  }
}
