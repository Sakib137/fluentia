import 'package:flutter/material.dart';

import '../../app/theme/design_system.dart';
import '../extensions/context_extensions.dart';
import 'primary_button.dart';

/// Secondary action button for Fluentia.
/// Supports both neutral filled and outlined variants.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    this.text,
    this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = false,
    this.isOutlined = false,
    this.size = ButtonSize.medium,
  }) : assert(
         text != null || label != null,
         'Either text or label must be provided',
       );

  final String? text;
  final String? label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final bool expand;
  final bool isOutlined;
  final ButtonSize size;

  String get effectiveText => text ?? label ?? '';

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final isEnabled = onPressed != null && !isLoading;

    final double height = switch (size) {
      ButtonSize.small => AppSpacing.buttonHeightSm,
      ButtonSize.medium => AppSpacing.buttonHeightMd,
      ButtonSize.large => AppSpacing.buttonHeightLg,
    };

    final double fontSize = switch (size) {
      ButtonSize.small => AppFontSizes.labelMedium,
      ButtonSize.medium => AppFontSizes.labelLarge,
      ButtonSize.large => AppFontSizes.titleLarge,
    };

    final EdgeInsets padding = switch (size) {
      ButtonSize.small => const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      ButtonSize.medium => const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
      ),
      ButtonSize.large => const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
    };

    Widget childContent;
    if (isLoading) {
      childContent = SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            isDark ? AppColors.slate200 : AppColors.slate700,
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
            effectiveText,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: AppFontWeights.semiBold,
              letterSpacing: 0.1,
              color: isEnabled
                  ? (isDark ? AppColors.slate100 : AppColors.slate800)
                  : (isDark ? AppColors.slate600 : AppColors.slate400),
            ),
          ),
        ],
      );
    }

    final buttonStyle = OutlinedButton.styleFrom(
      elevation: 0,
      backgroundColor: isOutlined
          ? Colors.transparent
          : (isDark ? AppColors.slate800 : AppColors.slate100),
      side: isOutlined
          ? BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1.2,
            )
          : BorderSide.none,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.button),
      padding: padding,
    );

    final button = OutlinedButton(
      onPressed: isEnabled ? onPressed : null,
      style: buttonStyle,
      child: childContent,
    );

    if (expand) {
      return SizedBox(width: double.infinity, height: height, child: button);
    }

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: height),
      child: button,
    );
  }
}
