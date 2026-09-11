import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/design_system.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/level_badge.dart';
import '../../../../shared/widgets/secondary_button.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../domain/word_of_the_day_selector.dart';
import '../providers/home_providers.dart';

/// Word of the Day interactive card with audio pronunciation and bookmarking.
class WordOfTheDayCard extends ConsumerWidget {
  const WordOfTheDayCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordAsync = ref.watch(wordOfTheDayProvider);
    final isDark = context.isDarkMode;
    final word =
        wordAsync.value ?? WordOfTheDaySelector.selectWord(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: SectionHeader(
            title: 'Word of the Day',
            subtitle: 'Enrich your active vocabulary daily',
            leadingIcon: Icons.auto_stories_rounded,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              word.word,
                              style: TextStyle(
                                fontSize: AppFontSizes.headlineMedium,
                                fontWeight: AppFontWeights.bold,
                                letterSpacing: -0.5,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          LevelBadge(level: word.cefrLevel),
                        ],
                      ),
                    ),
                    // Listen pronunciation button
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded),
                      color: isDark
                          ? AppColors.primary300
                          : AppColors.primary600,
                      iconSize: AppIconSizes.md,
                      tooltip: 'Listen to pronunciation',
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Playing pronunciation for "${word.word}"',
                            ),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Row(
                  children: [
                    Text(
                      word.phonetic,
                      style: TextStyle(
                        fontSize: AppFontSizes.bodySmall,
                        fontFamily: 'monospace',
                        color: isDark
                            ? AppColors.primary300
                            : AppColors.primary700,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '•  ${word.partOfSpeech}',
                      style: TextStyle(
                        fontSize: AppFontSizes.bodySmall,
                        fontStyle: FontStyle.italic,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  word.definition,
                  style: TextStyle(
                    fontSize: AppFontSizes.bodyMedium,
                    fontWeight: AppFontWeights.regular,
                    height: 1.4,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.slate800 : AppColors.slate100,
                    borderRadius: AppRadii.roundedMd,
                    border: Border(
                      left: BorderSide(
                        color: isDark
                            ? AppColors.primary400
                            : AppColors.primary600,
                        width: 3.0,
                      ),
                    ),
                  ),
                  child: Text(
                    '"${word.example}"',
                    style: TextStyle(
                      fontSize: AppFontSizes.bodySmall,
                      fontStyle: FontStyle.italic,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        text: word.isSaved
                            ? 'Saved to Vocabulary'
                            : 'Save Word',
                        icon: Icon(
                          word.isSaved
                              ? Icons.bookmark_added_rounded
                              : Icons.bookmark_border_rounded,
                          size: AppIconSizes.sm,
                        ),
                        onPressed: () {
                          ref
                              .read(wordOfTheDayProvider.notifier)
                              .toggleBookmark();
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    IconButton.outlined(
                      icon: const Icon(Icons.arrow_forward_rounded),
                      tooltip: 'Explore Word in Depth',
                      onPressed: () {
                        context.go('/learn/vocabulary/word/${word.id}');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
