import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/design_system.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../domain/models/listening_activity.dart';
import '../providers/listening_session_controller.dart';

/// Interactive UI for True / False statement listening drills.
class TrueFalseView extends ConsumerWidget {
  const TrueFalseView({super.key, required this.activity});

  final ListeningActivity activity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDarkMode;
    final state = ref.watch(listeningSessionControllerProvider);
    final controller = ref.read(listeningSessionControllerProvider.notifier);

    final statement =
        activity.question ?? 'Evaluate the statement based on the audio:';
    final isSubmitted = state.isSubmitted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Statement Card
        Container(
          width: double.infinity,
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: AppRadii.roundedLg,
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'STATEMENT',
                style: TextStyle(
                  fontSize: AppFontSizes.caption,
                  fontWeight: AppFontWeights.bold,
                  letterSpacing: 1.1,
                  color: isDark ? AppColors.primary300 : AppColors.primary700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                statement,
                style: TextStyle(
                  fontSize: AppFontSizes.bodyLarge,
                  fontWeight: AppFontWeights.medium,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // True / False Action Buttons
        Row(
          children: [
            Expanded(
              child: _buildChoiceCard(
                context: context,
                label: 'True',
                icon: Icons.check_circle_outline_rounded,
                isSelected: state.selectedOption?.toLowerCase() == 'true',
                isSubmitted: isSubmitted,
                isCorrectTarget:
                    activity.correctAnswer?.toLowerCase() == 'true',
                onTap: isSubmitted
                    ? null
                    : () => controller.selectOption('True'),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildChoiceCard(
                context: context,
                label: 'False',
                icon: Icons.highlight_off_rounded,
                isSelected: state.selectedOption?.toLowerCase() == 'false',
                isSubmitted: isSubmitted,
                isCorrectTarget:
                    activity.correctAnswer?.toLowerCase() == 'false',
                onTap: isSubmitted
                    ? null
                    : () => controller.selectOption('False'),
                isDark: isDark,
              ),
            ),
          ],
        ),

        // Feedback Explanation Banner
        if (state.isSubmitted && activity.explanation != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: isDark
                  ? (state.isCorrect
                        ? AppColors.success900.withValues(alpha: 0.2)
                        : AppColors.danger900.withValues(alpha: 0.2))
                  : (state.isCorrect
                        ? AppColors.success50
                        : AppColors.danger50),
              borderRadius: AppRadii.roundedLg,
              border: Border.all(
                color: state.isCorrect
                    ? (isDark ? AppColors.success800 : AppColors.success200)
                    : (isDark ? AppColors.danger800 : AppColors.danger200),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  state.isCorrect
                      ? Icons.check_circle_rounded
                      : Icons.error_outline_rounded,
                  color: state.isCorrect
                      ? (isDark ? AppColors.success400 : AppColors.success600)
                      : (isDark ? AppColors.danger400 : AppColors.danger600),
                  size: AppIconSizes.md,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.isCorrect
                            ? 'Correct Evaluation'
                            : 'Incorrect Evaluation',
                        style: TextStyle(
                          fontSize: AppFontSizes.bodyMedium,
                          fontWeight: AppFontWeights.bold,
                          color: state.isCorrect
                              ? (isDark
                                    ? AppColors.success300
                                    : AppColors.success800)
                              : (isDark
                                    ? AppColors.danger300
                                    : AppColors.danger800),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        activity.explanation!,
                        style: TextStyle(
                          fontSize: AppFontSizes.bodySmall,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildChoiceCard({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required bool isSubmitted,
    required bool isCorrectTarget,
    required VoidCallback? onTap,
    required bool isDark,
  }) {
    Color cardBg;
    Color borderColor;
    Color iconColor;
    Color textColor;

    if (!isSubmitted) {
      if (isSelected) {
        cardBg = isDark
            ? AppColors.primary900.withValues(alpha: 0.3)
            : AppColors.primary50;
        borderColor = isDark ? AppColors.primary400 : AppColors.primary600;
        iconColor = isDark ? AppColors.primary400 : AppColors.primary600;
        textColor = isDark ? AppColors.primary300 : AppColors.primary800;
      } else {
        cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
        borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
        iconColor = isDark
            ? AppColors.darkTextMuted
            : AppColors.lightTextSecondary;
        textColor = isDark
            ? AppColors.darkTextPrimary
            : AppColors.lightTextPrimary;
      }
    } else {
      if (isCorrectTarget) {
        cardBg = isDark
            ? AppColors.success900.withValues(alpha: 0.3)
            : AppColors.success50;
        borderColor = isDark ? AppColors.success400 : AppColors.success600;
        iconColor = isDark ? AppColors.success400 : AppColors.success600;
        textColor = isDark ? AppColors.success300 : AppColors.success800;
      } else if (isSelected && !isCorrectTarget) {
        cardBg = isDark
            ? AppColors.danger900.withValues(alpha: 0.3)
            : AppColors.danger50;
        borderColor = isDark ? AppColors.danger400 : AppColors.danger600;
        iconColor = isDark ? AppColors.danger400 : AppColors.danger600;
        textColor = isDark ? AppColors.danger300 : AppColors.danger800;
      } else {
        cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
        borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
        iconColor = isDark
            ? AppColors.darkTextMuted
            : AppColors.lightTextSecondary;
        textColor = isDark
            ? AppColors.darkTextMuted
            : AppColors.lightTextSecondary;
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.roundedLg,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.lg,
            horizontal: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: AppRadii.roundedLg,
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Column(
            children: [
              Icon(icon, size: 36, color: iconColor),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: TextStyle(
                  fontSize: AppFontSizes.titleMedium,
                  fontWeight: AppFontWeights.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
