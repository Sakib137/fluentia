import 'package:flutter/material.dart';

import '../../app/theme/design_system.dart';
import '../extensions/context_extensions.dart';

enum ButtonSize { small, medium, large }

/// Primary prominent action button for Fluentia.
/// Uses the brand teal/green accent with accessible tap targets and loading feedback.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    this.text,
    this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = false,
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
            isDark ? AppColors.slate950 : AppColors.white,
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
                  ? (isDark ? AppColors.slate950 : AppColors.white)
                  : (isDark ? AppColors.slate500 : AppColors.slate400),
            ),
          ),
        ],
      );
    }

    final buttonStyle = ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: isDark ? AppColors.primary400 : AppColors.primary600,
      disabledBackgroundColor: isDark ? AppColors.slate800 : AppColors.slate200,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.button),
      padding: padding,
    );

    final button = ElevatedButton(
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
