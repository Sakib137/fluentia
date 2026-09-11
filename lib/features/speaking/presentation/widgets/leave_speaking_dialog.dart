import 'package:flutter/material.dart';
import '../../../../app/theme/design_system.dart';
import '../../../../shared/extensions/context_extensions.dart';

/// Confirmation dialog warning the user before abandoning an active speaking session.
class LeaveSpeakingDialog extends StatelessWidget {
  const LeaveSpeakingDialog({super.key});

  /// Displays the confirmation dialog and returns true if user confirms leaving.
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LeaveSpeakingDialog(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(borderRadius: AppRadii.roundedXl),
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: isDark ? AppColors.warning400 : AppColors.warning600,
            size: AppIconSizes.md,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Leave practice?',
            style: TextStyle(
              fontSize: AppFontSizes.titleMedium,
              fontWeight: AppFontWeights.bold,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
      content: Text(
        'Your current response will not be saved as a completed practice session.',
        style: TextStyle(
          fontSize: AppFontSizes.bodyMedium,
          height: 1.45,
          color: isDark
              ? AppColors.darkTextMuted
              : AppColors.lightTextSecondary,
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Stay',
            style: TextStyle(
              fontSize: AppFontSizes.labelLarge,
              fontWeight: AppFontWeights.medium,
              color: isDark ? AppColors.primary300 : AppColors.primary700,
            ),
          ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: isDark ? AppColors.error500 : AppColors.error600,
            shape: RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text(
            'Leave',
            style: TextStyle(
              fontSize: AppFontSizes.labelLarge,
              fontWeight: AppFontWeights.semiBold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
