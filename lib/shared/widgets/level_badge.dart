import 'package:flutter/material.dart';

import '../../app/theme/design_system.dart';
import '../extensions/context_extensions.dart';

/// Pill badge for CEFR proficiency indicators (A1, A2, B1, B2, C1, C2).
class LevelBadge extends StatelessWidget {
  const LevelBadge({super.key, required this.level, this.isFilled = false});

  final String level;
  final bool isFilled;

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
        borderRadius: AppRadii.roundedFull,
        border: Border.all(color: border, width: 1),
      ),
      child: Text(
        level.toUpperCase(),
        style: TextStyle(
          fontSize: AppFontSizes.caption,
          fontWeight: AppFontWeights.bold,
          letterSpacing: 0.5,
          color: fg,
        ),
      ),
    );
  }

  (Color bg, Color fg, Color border) _getColors(bool isDark) {
    final upper = level.toUpperCase();

    if (upper.startsWith('C')) {
      // Advanced - Sage / Emerald
      return isFilled
          ? (
              isDark ? AppColors.sage600 : AppColors.sage500,
              isDark ? AppColors.slate950 : AppColors.white,
              Colors.transparent,
            )
          : (
              isDark ? AppColors.slate800 : AppColors.sage50,
              isDark ? AppColors.sage500 : AppColors.sage700,
              isDark ? AppColors.sage700 : AppColors.sage200,
            );
    } else if (upper.startsWith('B')) {
      // Intermediate - Primary Teal
      return isFilled
          ? (
              isDark ? AppColors.primary500 : AppColors.primary600,
              isDark ? AppColors.slate950 : AppColors.white,
              Colors.transparent,
            )
          : (
              isDark ? AppColors.slate800 : AppColors.primary50,
              isDark ? AppColors.primary300 : AppColors.primary700,
              isDark ? AppColors.primary800 : AppColors.primary200,
            );
    } else {
      // Elementary - Sky / Info
      return isFilled
          ? (
              isDark ? AppColors.info500 : AppColors.info600,
              isDark ? AppColors.slate950 : AppColors.white,
              Colors.transparent,
            )
          : (
              isDark ? AppColors.slate800 : AppColors.info50,
              isDark ? AppColors.info500 : AppColors.info600,
              isDark ? AppColors.slate700 : AppColors.info100,
            );
    }
  }
}
