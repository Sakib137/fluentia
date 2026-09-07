import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../extensions/context_extensions.dart';

enum FluentButtonVariant { primary, secondary, outline, text }

/// Accessible, modern button adhering to Fluentia's calm and intelligent aesthetic.
class FluentButton extends StatelessWidget {
  const FluentButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = FluentButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.expand = false,
    this.height = AppSpacing.buttonHeight,
  });

  final String text;
  final VoidCallback? onPressed;
  final FluentButtonVariant variant;
  final Widget? icon;
  final bool isLoading;
  final bool expand;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final isEnabled = onPressed != null && !isLoading;

    Widget childContent;
    if (isLoading) {
      childContent = SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            variant == FluentButtonVariant.primary
                ? AppColors.white
                : (isDark ? AppColors.slate200 : AppColors.slate700),
          ),
        ),
      );
    } else {
      childContent = Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[icon!, const SizedBox(width: AppSpacing.sm)],
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
              color: _getTextColor(context, isDark, isEnabled),
            ),
          ),
        ],
      );
    }

    final buttonStyle = _getButtonStyle(context, isDark, isEnabled);

    Widget button;
    switch (variant) {
      case FluentButtonVariant.primary:
        button = ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: buttonStyle,
          child: childContent,
        );
        break;
      case FluentButtonVariant.secondary:
      case FluentButtonVariant.outline:
        button = OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          style: buttonStyle,
          child: childContent,
        );
        break;
      case FluentButtonVariant.text:
        button = TextButton(
          onPressed: isEnabled ? onPressed : null,
          style: buttonStyle,
          child: childContent,
        );
        break;
    }

    if (expand) {
      return SizedBox(width: double.infinity, height: height, child: button);
    }

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: height),
      child: button,
    );
  }

  Color _getTextColor(BuildContext context, bool isDark, bool isEnabled) {
    if (!isEnabled) {
      return isDark ? AppColors.slate500 : AppColors.slate400;
    }
    switch (variant) {
      case FluentButtonVariant.primary:
        return AppColors.white;
      case FluentButtonVariant.secondary:
      case FluentButtonVariant.outline:
        return isDark ? AppColors.slate100 : AppColors.slate800;
      case FluentButtonVariant.text:
        return isDark ? AppColors.primary400 : AppColors.primary600;
    }
  }

  ButtonStyle _getButtonStyle(
    BuildContext context,
    bool isDark,
    bool isEnabled,
  ) {
    switch (variant) {
      case FluentButtonVariant.primary:
        return ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: isDark ? AppColors.primary500 : AppColors.primary600,
          disabledBackgroundColor: isDark
              ? AppColors.slate800
              : AppColors.slate200,
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.roundedMd,
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        );
      case FluentButtonVariant.secondary:
        return OutlinedButton.styleFrom(
          elevation: 0,
          backgroundColor: isDark ? AppColors.slate800 : AppColors.slate100,
          disabledBackgroundColor: Colors.transparent,
          side: BorderSide.none,
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.roundedMd,
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        );
      case FluentButtonVariant.outline:
        return OutlinedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          side: BorderSide(
            color: isDark ? AppColors.slate700 : AppColors.slate300,
            width: 1.2,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.roundedMd,
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        );
      case FluentButtonVariant.text:
        return TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.roundedSm,
          ),
        );
    }
  }
}
