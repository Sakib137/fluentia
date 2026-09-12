import 'package:flutter/material.dart';

import '../../../../app/theme/design_system.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../domain/services/writing_scoring.dart';

/// Production-ready writing editor widget featuring live word/sentence metrics,
/// target word progress bar, and adaptive styling.
class WritingEditor extends StatelessWidget {
  const WritingEditor({
    super.key,
    required this.controller,
    required this.onChanged,
    this.minWords = 0,
    this.maxWords = 0,
    this.hintText = 'Type your response here...',
    this.enabled = true,
    this.minLines = 5,
    this.maxLines = 14,
    this.wordCount = 0,
    this.sentenceCount = 0,
    this.characterCount = 0,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final int minWords;
  final int maxWords;
  final String hintText;
  final bool enabled;
  final int minLines;
  final int maxLines;
  final int wordCount;
  final int sentenceCount;
  final int characterCount;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    final lengthStatus = WritingScoring.checkWordCountRange(
      wordCount: wordCount,
      minWords: minWords,
      maxWords: maxWords,
    );

    // Color and label according to length status
    Color statusColor;
    String statusLabel;

    switch (lengthStatus) {
      case WritingLengthStatus.empty:
        statusColor = isDark
            ? AppColors.darkTextMuted
            : AppColors.lightTextSecondary;
        statusLabel = minWords > 0
            ? 'Goal: $minWords${maxWords > 0 ? "–$maxWords" : "+"} words'
            : 'Start writing';
        break;
      case WritingLengthStatus.belowMinimum:
        statusColor = AppColors.warning;
        final needed = minWords - wordCount;
        statusLabel = '$needed more word${needed == 1 ? '' : 's'} needed';
        break;
      case WritingLengthStatus.targetRange:
        statusColor = AppColors.success;
        statusLabel = 'Target length met';
        break;
      case WritingLengthStatus.aboveMaximum:
        statusColor = AppColors.warning;
        final excess = wordCount - maxWords;
        statusLabel = '$excess word${excess == 1 ? '' : 's'} above target';
        break;
    }

    // Progress computation for the progress bar
    double progress = 0.0;
    if (minWords > 0) {
      progress = (wordCount / minWords).clamp(0.0, 1.0);
    } else if (maxWords > 0) {
      progress = (wordCount / maxWords).clamp(0.0, 1.0);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Editor container with rounded border and subtle background
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: AppRadii.roundedLg,
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              // Text field input
              TextField(
                controller: controller,
                onChanged: onChanged,
                enabled: enabled,
                minLines: minLines,
                maxLines: maxLines,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(
                  fontSize: AppFontSizes.bodyMedium,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                  height: 1.6,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    fontSize: AppFontSizes.bodyMedium,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextSecondary,
                  ),
                  contentPadding: const EdgeInsets.all(AppSpacing.md),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),

              // Bottom metrics bar inside the editor
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.slate900 : AppColors.slate50,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? AppColors.darkBorder.withValues(alpha: 0.5)
                          : AppColors.lightBorder.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Word count indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs + 2,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: AppRadii.roundedFull,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: AppFontSizes.caption - 1,
                              fontWeight: AppFontWeights.semiBold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),

                    // Metrics: words, sentences, characters
                    Text(
                      '$wordCount words  •  $sentenceCount sent  •  $characterCount chars',
                      style: TextStyle(
                        fontSize: AppFontSizes.caption - 1,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Progress bar towards word count targets
        if (minWords > 0) ...[
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: AppRadii.roundedFull,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: isDark ? AppColors.slate800 : AppColors.slate200,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? AppColors.success : AppColors.teal500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
