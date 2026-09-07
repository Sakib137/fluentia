import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../extensions/context_extensions.dart';
import 'fluent_button.dart';

/// Minimalist, encouraging empty state for pending features, empty lists, or error views.
class FluentEmptyState extends StatelessWidget {
  const FluentEmptyState({
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
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark ? AppColors.slate800 : AppColors.slate100,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.slate700 : AppColors.slate200,
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                size: AppSpacing.iconXl,
                color: isDark ? AppColors.primary400 : AppColors.primary600,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
                color: isDark ? AppColors.slate100 : AppColors.slate900,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark ? AppColors.slate400 : AppColors.slate600,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              FluentButton(
                text: actionLabel!,
                onPressed: onAction,
                variant: FluentButtonVariant.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
