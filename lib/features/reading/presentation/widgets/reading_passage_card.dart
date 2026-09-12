import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/design_system.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/models/reading_activity.dart';
import '../providers/reading_session_controller.dart';

/// Card presenting the reading passage with comfortable typography and vocabulary highlights.
class ReadingPassageCard extends ConsumerWidget {
  const ReadingPassageCard({
    super.key,
    required this.activity,
    this.showActionToQuestions = true,
    this.onProceedToQuestions,
  });

  final ReadingActivity activity;
  final bool showActionToQuestions;
  final VoidCallback? onProceedToQuestions;

  void _showVocabularyDefinition(
    BuildContext context,
    ReadingVocabularyItem item,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: AppSpacing.screenPadding,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.teal900.withValues(alpha: 0.3)
                            : AppColors.teal50,
                        borderRadius: AppRadii.roundedFull,
                      ),
                      child: Text(
                        item.partOfSpeech,
                        style: TextStyle(
                          fontSize: AppFontSizes.caption,
                          fontWeight: AppFontWeights.bold,
                          color: isDark ? AppColors.teal300 : AppColors.teal700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      item.word,
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
                const SizedBox(height: AppSpacing.md),
                Text(
                  item.definition,
                  style: TextStyle(
                    fontSize: AppFontSizes.bodyMedium,
                    height: 1.5,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                if (item.contextSentence != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'In context: "${item.contextSentence!}"',
                    style: TextStyle(
                      fontSize: AppFontSizes.bodySmall,
                      fontStyle: FontStyle.italic,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDarkMode;
    final fontSizeDelta = ref
        .watch(readingSessionControllerProvider)
        .fontSizeDelta;
    final baseFontSize = AppFontSizes.bodyMedium + fontSizeDelta;

    final paragraphs = activity.effectiveParagraphs;

    return AppCard(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info bar
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.teal900.withValues(alpha: 0.3)
                      : AppColors.teal50,
                  borderRadius: AppRadii.roundedFull,
                ),
                child: Text(
                  '${activity.level} • ${activity.category}',
                  style: TextStyle(
                    fontSize: AppFontSizes.caption,
                    fontWeight: AppFontWeights.bold,
                    color: isDark ? AppColors.teal300 : AppColors.teal700,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.schedule_rounded,
                size: 14,
                color: isDark
                    ? AppColors.darkTextMuted
                    : AppColors.lightTextSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '~${activity.estimatedDurationMinutes} min (${activity.wordCount} words)',
                style: TextStyle(
                  fontSize: AppFontSizes.caption,
                  color: isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Title
          Text(
            activity.title,
            style: TextStyle(
              fontSize: AppFontSizes.titleMedium + (fontSizeDelta * 0.5),
              fontWeight: AppFontWeights.bold,
              letterSpacing: -0.3,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),

          // Paragraphs
          ...paragraphs.map((para) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: SelectableText(
                para,
                style: TextStyle(
                  fontSize: baseFontSize,
                  height: 1.65,
                  letterSpacing: 0.1,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            );
          }),

          // Vocabulary Glossary Highlights
          if (activity.vocabularyItems.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Key Vocabulary (Tap to define):',
              style: TextStyle(
                fontSize: AppFontSizes.caption,
                fontWeight: AppFontWeights.bold,
                color: isDark
                    ? AppColors.darkTextMuted
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: activity.vocabularyItems.map((v) {
                return InkWell(
                  onTap: () => _showVocabularyDefinition(context, v, isDark),
                  borderRadius: AppRadii.roundedSm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs + 2,
                      vertical: AppSpacing.xxs + 1,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.slate800 : AppColors.slate100,
                      borderRadius: AppRadii.roundedSm,
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.help_outline_rounded,
                          size: 12,
                          color: isDark ? AppColors.teal300 : AppColors.teal700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          v.word,
                          style: TextStyle(
                            fontSize: AppFontSizes.caption,
                            fontWeight: AppFontWeights.medium,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          if (showActionToQuestions && onProceedToQuestions != null) ...[
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: 'Proceed to Questions →',
                onPressed: onProceedToQuestions!,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
