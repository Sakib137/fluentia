import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../extensions/context_extensions.dart';

/// A calm, minimalist container card with refined border definition and subtle interaction.
class FluentCard extends StatelessWidget {
  const FluentCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final effectiveBg =
        backgroundColor ?? (isDark ? AppColors.slate800 : AppColors.white);
    final effectiveBorder =
        borderColor ?? (isDark ? AppColors.slate700 : AppColors.slate200);
    final effectiveRadius = borderRadius ?? AppSpacing.roundedLg;

    final shape = RoundedRectangleBorder(
      borderRadius: effectiveRadius,
      side: BorderSide(color: effectiveBorder, width: 1),
    );

    Widget content;
    if (onTap != null) {
      content = Material(
        color: effectiveBg,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      );
    } else {
      content = Material(
        color: effectiveBg,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: Padding(padding: padding, child: child),
      );
    }

    if (margin != null) {
      return Padding(padding: margin!, child: content);
    }

    return content;
  }
}
