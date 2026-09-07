import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/widgets.dart';

/// Placeholder screen for writing exercises (/practice/writing).
class WritingScreen extends StatelessWidget {
  const WritingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FluentAppBar(
        title: AppStrings.writingTitle,
        subtitle: 'Sentence structuring, prompts, and composition drills',
        showBackButton: true,
      ),
      body: SafeArea(
        child: EmptyState(
          icon: Icons.edit_note_rounded,
          title: '${AppStrings.writingTitle} Module',
          description:
              'Guided sentence assembly, prompt responses, and structured essay builders will be implemented here.',
          actionLabel: 'Return to Practice',
          onAction: () => context.pop(),
        ),
      ),
    );
  }
}
