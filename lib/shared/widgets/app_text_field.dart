import 'package:flutter/material.dart';

import '../../app/theme/design_system.dart';
import '../extensions/context_extensions.dart';

/// Standardized text input field for Fluentia forms and prompts.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.hint,
    this.labelText,
    this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.errorText,
    this.obscureText = false,
    this.maxLines = 1,
    this.onChanged,
    this.keyboardType,
    this.readOnly = false,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final String? hintText;
  final String? hint;
  final String? labelText;
  final String? label;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? errorText;
  final bool obscureText;
  final int? maxLines;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool readOnly;
  final bool enabled;

  String? get effectiveLabel => labelText ?? label;
  String? get effectiveHint => hintText ?? hint;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (effectiveLabel != null) ...[
          Text(
            effectiveLabel!,
            style: TextStyle(
              fontSize: AppFontSizes.labelMedium,
              fontWeight: AppFontWeights.medium,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        TextField(
          controller: controller,
          obscureText: obscureText,
          maxLines: maxLines,
          onChanged: onChanged,
          keyboardType: keyboardType,
          readOnly: readOnly,
          enabled: enabled,
          style: TextStyle(
            fontSize: AppFontSizes.bodyMedium,
            fontWeight: AppFontWeights.regular,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
          decoration: InputDecoration(
            hintText: effectiveHint,
            errorText: errorText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            prefixIconColor: isDark ? AppColors.slate400 : AppColors.slate500,
            suffixIconColor: isDark ? AppColors.slate400 : AppColors.slate500,
          ),
        ),
      ],
    );
  }
}
