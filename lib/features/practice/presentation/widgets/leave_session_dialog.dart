import 'package:flutter/material.dart';

import '../../../../app/theme/design_system.dart';
import '../../../../shared/extensions/context_extensions.dart';

/// Modal dialog confirming whether to abandon an active practice session.
class LeaveSessionDialog extends StatelessWidget {
  const LeaveSessionDialog({super.key});

  /// Displays the confirmation dialog and returns true if user confirmed leaving.
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const LeaveSessionDialog(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(borderRadius: AppRadii.roundedXl),
      title: Text(
        'Leave practice?',
        style: TextStyle(
          fontSize: AppFontSizes.titleLarge,
          fontWeight: AppFontWeights.semiBold,
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
      ),
      content: Text(
        'Your current session will not be completed and your progress will not be saved.',
        style: TextStyle(
          fontSize: AppFontSizes.bodyMedium,
          height: 1.45,
          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
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
              fontWeight: AppFontWeights.semiBold,
              color: isDark ? AppColors.primary300 : AppColors.primary700,
            ),
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: isDark ? AppColors.error400 : AppColors.error600,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
          ),
          child: const Text('Leave'),
        ),
      ],
    );
  }
}
