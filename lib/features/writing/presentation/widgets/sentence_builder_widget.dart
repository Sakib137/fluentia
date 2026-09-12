import 'package:flutter/material.dart';

import '../../../../app/theme/design_system.dart';
import '../../../../shared/extensions/context_extensions.dart';

/// Interactive sentence building widget for Sentence Builder practice drills.
class SentenceBuilderWidget extends StatelessWidget {
  const SentenceBuilderWidget({
    super.key,
    required this.selectedTokens,
    required this.availableTokens,
    required this.onTapAvailableToken,
    required this.onTapSelectedToken,
    required this.onReset,
    this.isSubmitted = false,
    this.isCorrect,
    this.expectedAnswer,
  });

  final List<String> selectedTokens;
  final List<String> availableTokens;
  final ValueChanged<int> onTapAvailableToken;
  final ValueChanged<int> onTapSelectedToken;
  final VoidCallback onReset;
  final bool isSubmitted;
  final bool? isCorrect;
  final String? expectedAnswer;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    Color stripBorderColor;
    Color stripBgColor;

    if (isSubmitted) {
      if (isCorrect == true) {
        stripBorderColor = AppColors.success;
        stripBgColor = isDark
            ? AppColors.success.withValues(alpha: 0.15)
            : AppColors.success.withValues(alpha: 0.08);
      } else {
        stripBorderColor = AppColors.warning;
        stripBgColor = isDark
            ? AppColors.warning.withValues(alpha: 0.15)
            : AppColors.warning.withValues(alpha: 0.08);
      }
    } else {
      stripBorderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
      stripBgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Assembled sentence area
        Container(
          constraints: const BoxConstraints(minHeight: 110),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: stripBgColor,
            borderRadius: AppRadii.roundedLg,
            border: Border.all(color: stripBorderColor, width: 1.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'YOUR SENTENCE',
                    style: TextStyle(
                      fontSize: AppFontSizes.caption - 1,
                      fontWeight: AppFontWeights.bold,
                      letterSpacing: 0.8,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const Spacer(),
                  if (!isSubmitted && selectedTokens.isNotEmpty)
                    InkWell(
                      onTap: onReset,
                      borderRadius: AppRadii.roundedSm,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.refresh_rounded,
                              size: 14,
                              color: isDark
                                  ? AppColors.teal300
                                  : AppColors.teal700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Reset',
                              style: TextStyle(
                                fontSize: AppFontSizes.caption,
                                fontWeight: AppFontWeights.semiBold,
                                color: isDark
                                    ? AppColors.teal300
                                    : AppColors.teal700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // Chips in assembled sentence
              if (selectedTokens.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Center(
                    child: Text(
                      'Tap words below to assemble your sentence...',
                      style: TextStyle(
                        fontSize: AppFontSizes.bodySmall,
                        fontStyle: FontStyle.italic,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(selectedTokens.length, (index) {
                    final token = selectedTokens[index];
                    return ActionChip(
                      onPressed: isSubmitted
                          ? null
                          : () => onTapSelectedToken(index),
                      label: Text(
                        token,
                        style: TextStyle(
                          fontSize: AppFontSizes.bodyMedium,
                          fontWeight: AppFontWeights.semiBold,
                          color: isDark ? AppColors.teal200 : AppColors.teal900,
                        ),
                      ),
                      backgroundColor: isDark
                          ? AppColors.teal900.withValues(alpha: 0.45)
                          : AppColors.teal50,
                      side: BorderSide(
                        color: isDark ? AppColors.teal700 : AppColors.teal300,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadii.roundedMd,
                      ),
                      avatar: isSubmitted
                          ? null
                          : Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: isDark
                                  ? AppColors.teal300
                                  : AppColors.teal700,
                            ),
                    );
                  }),
                ),
            ],
          ),
        ),

        // 2. Expected answer banner if submitted and incorrect
        if (isSubmitted && isCorrect == false && expectedAnswer != null) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.teal900.withValues(alpha: 0.25)
                  : AppColors.teal50,
              borderRadius: AppRadii.roundedMd,
              border: Border.all(
                color: isDark ? AppColors.teal700 : AppColors.teal300,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 16,
                      color: isDark ? AppColors.teal300 : AppColors.teal700,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Expected Sentence Order:',
                      style: TextStyle(
                        fontSize: AppFontSizes.caption,
                        fontWeight: AppFontWeights.bold,
                        color: isDark ? AppColors.teal300 : AppColors.teal700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  expectedAnswer!,
                  style: TextStyle(
                    fontSize: AppFontSizes.bodyMedium,
                    fontWeight: AppFontWeights.semiBold,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.lg),

        // 3. Word Bank Title
        Row(
          children: [
            Text(
              'WORD BANK',
              style: TextStyle(
                fontSize: AppFontSizes.caption - 1,
                fontWeight: AppFontWeights.bold,
                letterSpacing: 0.8,
                color: isDark
                    ? AppColors.darkTextMuted
                    : AppColors.lightTextSecondary,
              ),
            ),
            const Spacer(),
            Text(
              '${availableTokens.length} remaining',
              style: TextStyle(
                fontSize: AppFontSizes.caption,
                color: isDark
                    ? AppColors.darkTextMuted
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // 4. Word Bank Chips
        Container(
          constraints: const BoxConstraints(minHeight: 80),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: AppRadii.roundedLg,
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: availableTokens.isEmpty
              ? Center(
                  child: Text(
                    'All words have been placed.',
                    style: TextStyle(
                      fontSize: AppFontSizes.bodySmall,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(availableTokens.length, (index) {
                    final token = availableTokens[index];
                    return ActionChip(
                      onPressed: isSubmitted
                          ? null
                          : () => onTapAvailableToken(index),
                      label: Text(
                        token,
                        style: TextStyle(
                          fontSize: AppFontSizes.bodyMedium,
                          fontWeight: AppFontWeights.medium,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      backgroundColor: isDark
                          ? AppColors.slate800
                          : AppColors.slate100,
                      side: BorderSide(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadii.roundedMd,
                      ),
                    );
                  }),
                ),
        ),
      ],
    );
  }
}
