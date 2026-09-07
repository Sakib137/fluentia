import 'package:flutter/material.dart';

import '../../app/theme/design_system.dart';
import '../extensions/context_extensions.dart';

enum CardVariant {
  /// Standard subtle border with flat surface
  outlined,

  /// Card with restrained elevation shadow
  elevated,

  /// Soft tinted surface variant
  filled,
}

/// A calm, minimalist container card with moderate corner radius and subtle border.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.cardPadding,
    this.margin,
    this.onTap,
    this.variant = CardVariant.outlined,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final CardVariant variant;
  final Color? backgroundColor;
  final Color? borderColor;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    final effectiveRadius = borderRadius ?? AppRadii.card;

    final effectiveBg =
        backgroundColor ??
        switch (variant) {
          CardVariant.outlined =>
            isDark ? AppColors.darkSurface : AppColors.lightSurface,
          CardVariant.elevated =>
            isDark ? AppColors.darkSurface : AppColors.lightSurface,
          CardVariant.filled =>
            isDark
                ? AppColors.darkSurfaceVariant
                : AppColors.lightSurfaceVariant,
        };

    final effectiveBorder =
        borderColor ??
        switch (variant) {
          CardVariant.outlined =>
            isDark ? AppColors.darkBorder : AppColors.lightBorder,
          CardVariant.elevated =>
            isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle,
          CardVariant.filled => Colors.transparent,
        };

    final shape = RoundedRectangleBorder(
      borderRadius: effectiveRadius,
      side: BorderSide(
        color: effectiveBorder,
        width: variant == CardVariant.filled ? 0 : 1,
      ),
    );

    Widget content = Material(
      color: effectiveBg,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              child: Padding(padding: padding, child: child),
            )
          : Padding(padding: padding, child: child),
    );

    if (variant == CardVariant.elevated) {
      content = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: effectiveRadius,
          boxShadow: isDark ? AppShadows.darkCard : AppShadows.card,
        ),
        child: content,
      );
    }

    if (margin != null) {
      return Padding(padding: margin!, child: content);
    }

    return content;
  }
}
