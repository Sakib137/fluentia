import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/widgets.dart';

/// Placeholder screen for vocabulary study and spaced repetition flashcards (/learn/vocabulary).
class VocabularyScreen extends StatelessWidget {
  const VocabularyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FluentAppBar(
        title: AppStrings.vocabularyTitle,
        subtitle: 'High-frequency words and spaced repetition mastery',
        showBackButton: true,
      ),
      body: SafeArea(
        child: EmptyState(
          icon: Icons.spellcheck_rounded,
          title: '${AppStrings.vocabularyTitle} Module',
          description:
              'Offline word banks, phonetic pronunciations, example sentences, and spaced repetition review decks will be implemented here.',
          actionLabel: 'Return to Learn',
          onAction: () => context.pop(),
        ),
      ),
    );
  }
}
