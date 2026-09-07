import 'package:flutter/material.dart';

import '../../app/theme/design_system.dart';
import '../extensions/context_extensions.dart';

/// Animated progress indicator with optional label, percentage, and custom styling.
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value,
    this.label,
    this.trailingText,
    this.height = 6.0,
    this.color,
    this.backgroundColor,
    this.showPercentage = false,
    this.borderRadius = AppRadii.roundedFull,
  });

  /// Progress value between 0.0 and 1.0
  final double value;

  /// Optional label displayed above the bar on the left
  final String? label;

  /// Optional text displayed above the bar on the right
  final String? trailingText;

  /// Height of the progress bar track
  final double height;

  /// Active fill color
  final Color? color;

  /// Inactive track background color
  final Color? backgroundColor;

  /// Whether to display percentage on the right if [trailingText] is null
  final bool showPercentage;

  /// Track corner radius
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final clampedValue = value.clamp(0.0, 1.0);

    final activeColor =
        color ?? (isDark ? AppColors.primary400 : AppColors.primary600);
    final trackColor =
        backgroundColor ?? (isDark ? AppColors.slate800 : AppColors.slate200);

    final effectiveTrailing =
        trailingText ??
        (showPercentage ? '${(clampedValue * 100).toInt()}%' : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null || effectiveTrailing != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (label != null)
                Text(
                  label!,
                  style: TextStyle(
                    fontSize: AppFontSizes.bodySmall,
                    fontWeight: AppFontWeights.medium,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              if (effectiveTrailing != null)
                Text(
                  effectiveTrailing,
                  style: TextStyle(
                    fontSize: AppFontSizes.labelSmall,
                    fontWeight: AppFontWeights.semiBold,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        ClipRRect(
          borderRadius: borderRadius,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            tween: Tween<double>(begin: 0.0, end: clampedValue),
            builder: (context, animatedValue, _) {
              return LinearProgressIndicator(
                value: animatedValue,
                minHeight: height,
                backgroundColor: trackColor,
                valueColor: AlwaysStoppedAnimation<Color>(activeColor),
              );
            },
          ),
        ),
      ],
    );
  }
}
