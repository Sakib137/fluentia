import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/design_system.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/widgets.dart';

/// Learn hub screen organizing knowledge modules: Vocabulary & Grammar.
class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FluentAppBar(
        title: AppStrings.learnTitle,
        subtitle: AppStrings.learnSubtitle,
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            const SectionHeader(
              title: 'Knowledge Modules',
              subtitle: 'Systematic frameworks and high-frequency retention',
            ),
            const SizedBox(height: AppSpacing.xs),
            PracticeCard(
              title: AppStrings.vocabularyTitle,
              description: AppStrings.vocabularyDesc,
              icon: Icons.spellcheck_rounded,
              badge: 'Spaced Repetition',
              durationMinutes: 10,
              onStart: () => context.push(AppRoutes.learnVocabulary),
            ),
            const SizedBox(height: AppSpacing.md),
            PracticeCard(
              title: AppStrings.grammarTitle,
              description: AppStrings.grammarDesc,
              icon: Icons.account_tree_rounded,
              badge: 'Rule Frameworks',
              durationMinutes: 15,
              onStart: () => context.push(AppRoutes.learnGrammar),
            ),
          ],
        ),
      ),
    );
  }
}
