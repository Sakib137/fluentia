import 'package:flutter/material.dart';

import '../../app/theme/design_system.dart';
import '../extensions/context_extensions.dart';

/// Dedicated streak indicator badge with fire icon and count.
class StreakBadge extends StatelessWidget {
  const StreakBadge({
    super.key,
    required this.count,
    this.isActive = true,
    this.compact = false,
  });

  final int count;
  final bool isActive;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    final Color bg = isActive
        ? (isDark ? AppColors.slate800 : AppColors.sage50)
        : (isDark ? AppColors.slate800 : AppColors.slate100);

    final Color fg = isActive
        ? (isDark ? AppColors.sage500 : AppColors.sage600)
        : (isDark ? AppColors.slate500 : AppColors.slate400);

    final Color border = isActive
        ? (isDark ? AppColors.sage700 : AppColors.sage100)
        : (isDark ? AppColors.darkBorder : AppColors.slate200);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.xs + 2 : AppSpacing.sm,
        vertical: AppSpacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadii.roundedFull,
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            size: compact ? AppIconSizes.xs : AppIconSizes.sm - 2,
            color: fg,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            compact ? '$count' : '$count Day Streak',
            style: TextStyle(
              fontSize: AppFontSizes.caption,
              fontWeight: AppFontWeights.bold,
              color: fg,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
