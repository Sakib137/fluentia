import 'package:flutter/material.dart';

import '../../app/theme/design_system.dart';
import '../extensions/context_extensions.dart';
import 'primary_button.dart';

/// Minimalist, encouraging empty state for pending features, empty lists, or error views.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: isDark ? AppColors.slate800 : AppColors.slate100,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                size: AppIconSizes.hero,
                color: isDark ? AppColors.primary400 : AppColors.primary600,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFontSizes.headlineSmall,
                fontWeight: AppFontWeights.semiBold,
                letterSpacing: -0.2,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs + 2),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFontSizes.bodyMedium,
                height: 1.5,
                color: isDark
                    ? AppColors.darkTextMuted
                    : AppColors.lightTextSecondary,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(text: actionLabel!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}
