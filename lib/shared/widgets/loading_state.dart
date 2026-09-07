import 'package:flutter/material.dart';

import '../../app/theme/design_system.dart';
import '../extensions/context_extensions.dart';

/// Calm, branded loading indicator widget with optional progress text.
class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.message, this.isOverlay = false});

  final String? message;
  final bool isOverlay;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    Widget content = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? AppColors.primary400 : AppColors.primary600,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              message!,
              style: TextStyle(
                fontSize: AppFontSizes.bodySmall,
                fontWeight: AppFontWeights.medium,
                color: isDark
                    ? AppColors.darkTextMuted
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ],
      ),
    );

    if (isOverlay) {
      content = ColoredBox(
        color: (isDark ? AppColors.slate950 : AppColors.white).withValues(
          alpha: 0.8,
        ),
        child: content,
      );
    }

    return content;
  }
}
