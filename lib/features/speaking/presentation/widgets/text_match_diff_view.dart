import 'package:flutter/material.dart';
import '../../../../app/theme/design_system.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../domain/models/speaking_metrics.dart';

/// Accessible visual comparison displaying expected vs recognized speech with token-level highlights.
class TextMatchDiffView extends StatelessWidget {
  const TextMatchDiffView({
    super.key,
    required this.expectedText,
    required this.recognizedText,
    required this.wordTokens,
    this.matchPercentage,
    this.missingWords = const [],
  });

  final String expectedText;
  final String recognizedText;
  final List<WordDiffToken> wordTokens;
  final double? matchPercentage;
  final List<String> missingWords;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Match header badge
        if (matchPercentage != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Speech Match',
                style: TextStyle(
                  fontSize: AppFontSizes.labelMedium,
                  fontWeight: AppFontWeights.bold,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: matchPercentage! >= 90.0
                      ? (isDark ? AppColors.slate800 : AppColors.sage50)
                      : matchPercentage! >= 75.0
                      ? (isDark
                            ? AppColors.primary900.withValues(alpha: 0.4)
                            : AppColors.primary50)
                      : (isDark ? AppColors.slate800 : AppColors.slate100),
                  borderRadius: AppRadii.roundedFull,
                  border: Border.all(
                    color: matchPercentage! >= 90.0
                        ? (isDark ? AppColors.sage700 : AppColors.sage200)
                        : (isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      matchPercentage! >= 90.0
                          ? Icons.check_circle_outline_rounded
                          : Icons.insights_rounded,
                      size: AppIconSizes.xs + 2,
                      color: matchPercentage! >= 90.0
                          ? (isDark ? AppColors.sage400 : AppColors.sage700)
                          : (isDark
                                ? AppColors.primary300
                                : AppColors.primary700),
                    ),
                    const SizedBox(width: AppSpacing.xxs + 1),
                    Text(
                      '${matchPercentage!.round()}% Match',
                      style: TextStyle(
                        fontSize: AppFontSizes.caption,
                        fontWeight: AppFontWeights.bold,
                        color: matchPercentage! >= 90.0
                            ? (isDark ? AppColors.sage400 : AppColors.sage700)
                            : (isDark
                                  ? AppColors.primary300
                                  : AppColors.primary700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Compares recognized speech words against the target sentence.',
            style: TextStyle(
              fontSize: AppFontSizes.caption,
              color: isDark
                  ? AppColors.darkTextMuted
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // 1. Expected Box
        Container(
          width: double.infinity,
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            color: isDark ? AppColors.slate800 : AppColors.slate50,
            borderRadius: AppRadii.roundedLg,
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.format_quote_rounded,
                    size: AppIconSizes.sm,
                    color: isDark ? AppColors.primary300 : AppColors.primary700,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Target Sentence',
                    style: TextStyle(
                      fontSize: AppFontSizes.labelSmall,
                      fontWeight: AppFontWeights.bold,
                      color: isDark ? AppColors.slate400 : AppColors.slate600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                expectedText,
                style: TextStyle(
                  fontSize: AppFontSizes.bodyMedium,
                  fontWeight: AppFontWeights.medium,
                  height: 1.5,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // 2. Recognized Box with Token Highlights
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
              Row(
                children: [
                  Icon(
                    Icons.mic_none_rounded,
                    size: AppIconSizes.sm,
                    color: isDark ? AppColors.primary300 : AppColors.primary700,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'What Was Recognized',
                    style: TextStyle(
                      fontSize: AppFontSizes.labelSmall,
                      fontWeight: AppFontWeights.bold,
                      color: isDark ? AppColors.slate400 : AppColors.slate600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              if (recognizedText.trim().isEmpty)
                Text(
                  'No speech recognized.',
                  style: TextStyle(
                    fontSize: AppFontSizes.bodyMedium,
                    fontStyle: FontStyle.italic,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextSecondary,
                  ),
                )
              else
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: wordTokens.map((token) {
                    return _WordTokenChip(token: token, isDark: isDark);
                  }).toList(),
                ),
            ],
          ),
        ),

        // 3. Missing Words Warning Banner
        if (missingWords.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.slate900
                  : AppColors.primary50.withValues(alpha: 0.5),
              borderRadius: AppRadii.roundedMd,
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.primary100,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: AppIconSizes.sm,
                  color: isDark ? AppColors.primary300 : AppColors.primary700,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'Missed word(s): "${missingWords.join(', ')}"',
                    style: TextStyle(
                      fontSize: AppFontSizes.caption,
                      fontWeight: AppFontWeights.medium,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _WordTokenChip extends StatelessWidget {
  const _WordTokenChip({required this.token, required this.isDark});

  final WordDiffToken token;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (token.isMatched) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: isDark ? AppColors.slate800 : AppColors.sage50,
          borderRadius: AppRadii.roundedSm,
          border: Border.all(
            color: isDark ? AppColors.sage700 : AppColors.sage200,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_rounded,
              size: 11,
              color: isDark ? AppColors.sage400 : AppColors.sage700,
            ),
            const SizedBox(width: 3),
            Text(
              token.text,
              style: TextStyle(
                fontSize: AppFontSizes.bodyMedium,
                fontWeight: AppFontWeights.medium,
                color: isDark ? AppColors.sage400 : AppColors.sage700,
              ),
            ),
          ],
        ),
      );
    }

    if (token.isMissing) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: isDark ? AppColors.slate800 : AppColors.slate100,
          borderRadius: AppRadii.roundedSm,
          border: Border.all(
            color: isDark ? AppColors.slate700 : AppColors.slate300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.remove_rounded,
              size: 11,
              color: isDark ? AppColors.slate400 : AppColors.slate600,
            ),
            const SizedBox(width: 3),
            Text(
              token.text,
              style: TextStyle(
                fontSize: AppFontSizes.bodyMedium,
                decoration: TextDecoration.lineThrough,
                color: isDark ? AppColors.slate400 : AppColors.slate600,
              ),
            ),
          ],
        ),
      );
    }

    if (token.isDifferent) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.primary900.withValues(alpha: 0.5)
              : AppColors.primary50,
          borderRadius: AppRadii.roundedSm,
          border: Border.all(
            color: isDark ? AppColors.primary800 : AppColors.primary300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sync_alt_rounded,
              size: 11,
              color: isDark ? AppColors.primary300 : AppColors.primary700,
            ),
            const SizedBox(width: 3),
            Text(
              token.text,
              style: TextStyle(
                fontSize: AppFontSizes.bodyMedium,
                fontWeight: AppFontWeights.medium,
                color: isDark ? AppColors.primary300 : AppColors.primary800,
              ),
            ),
          ],
        ),
      );
    }

    // Extra words
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800 : AppColors.slate100,
        borderRadius: AppRadii.roundedSm,
      ),
      child: Text(
        '+ ${token.text}',
        style: TextStyle(
          fontSize: AppFontSizes.bodyMedium,
          fontStyle: FontStyle.italic,
          color: isDark ? AppColors.slate400 : AppColors.slate600,
        ),
      ),
    );
  }
}
