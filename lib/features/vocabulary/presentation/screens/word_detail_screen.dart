import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/design_system.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/level_badge.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../home/data/datasources/curated_vocabulary_data.dart';
import '../../../home/data/models/home_models.dart';
import '../../../home/presentation/providers/home_providers.dart';

/// Screen presenting in-depth lexical breakdown for a selected vocabulary word.
class WordDetailScreen extends ConsumerWidget {
  const WordDetailScreen({
    super.key,
    required this.wordId,
  });

  final String wordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDarkMode;

    // Search in curated list or fallback
    final word = kCuratedVocabularyList.firstWhere(
      (w) => w.id == wordId || w.word.toLowerCase() == wordId.toLowerCase(),
      orElse: () => WordOfTheDay(
        id: wordId,
        word: wordId.capitalizeFirst(),
        phonetic: '/.../',
        partOfSpeech: 'noun',
        definition: 'Offline vocabulary term entry.',
        example: 'Continuous practice improves your active vocabulary.',
        cefrLevel: 'B2',
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          word.word,
          style: TextStyle(
            fontSize: AppFontSizes.titleMedium,
            fontWeight: AppFontWeights.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_rounded),
            tooltip: 'Listen to pronunciation',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Playing audio for "${word.word}"'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      word.word,
                      style: TextStyle(
                        fontSize: AppFontSizes.displayMedium,
                        fontWeight: AppFontWeights.bold,
                        letterSpacing: -0.5,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    LevelBadge(level: word.cefrLevel),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Row(
                  children: [
                    Text(
                      word.phonetic,
                      style: TextStyle(
                        fontSize: AppFontSizes.bodyMedium,
                        fontFamily: 'monospace',
                        color: isDark ? AppColors.primary300 : AppColors.primary700,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '•  ${word.partOfSpeech}',
                      style: TextStyle(
                        fontSize: AppFontSizes.bodySmall,
                        fontStyle: FontStyle.italic,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Definition',
                  style: TextStyle(
                    fontSize: AppFontSizes.labelMedium,
                    fontWeight: AppFontWeights.bold,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  word.definition,
                  style: TextStyle(
                    fontSize: AppFontSizes.bodyLarge,
                    height: 1.45,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Example in Context',
                  style: TextStyle(
                    fontSize: AppFontSizes.labelMedium,
                    fontWeight: AppFontWeights.bold,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.slate800 : AppColors.slate100,
                    borderRadius: AppRadii.roundedMd,
                    border: Border(
                      left: BorderSide(
                        color: isDark ? AppColors.primary400 : AppColors.primary600,
                        width: 4.0,
                      ),
                    ),
                  ),
                  child: Text(
                    '"${word.example}"',
                    style: TextStyle(
                      fontSize: AppFontSizes.bodyMedium,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  text: 'Practice This Word',
                  icon: const Icon(Icons.quiz_rounded, size: AppIconSizes.sm),
                  onPressed: () {
                    ref.read(dailyProgressProvider.notifier).logPractice(
                          minutes: 2,
                          skillType: 'Vocabulary',
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Drill completed! +2 min practice logged.'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension on String {
  String capitalizeFirst() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
