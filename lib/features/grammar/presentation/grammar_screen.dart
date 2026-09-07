import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/widgets.dart';

/// Placeholder screen for grammar rules and structural exercises (/learn/grammar).
class GrammarScreen extends StatelessWidget {
  const GrammarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FluentAppBar(
        title: AppStrings.grammarTitle,
        subtitle: 'Practical grammar rules with structured practice',
        showBackButton: true,
      ),
      body: SafeArea(
        child: EmptyState(
          icon: Icons.account_tree_rounded,
          title: '${AppStrings.grammarTitle} Module',
          description:
              'Structured lessons covering tenses, syntax, prepositions, conditionals, and interactive sentence repair exercises will be implemented here.',
          actionLabel: 'Return to Learn',
          onAction: () => context.pop(),
        ),
      ),
    );
  }
}
