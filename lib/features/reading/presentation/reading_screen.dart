import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/widgets.dart';

/// Placeholder screen for reading comprehension exercises (/practice/reading).
class ReadingScreen extends StatelessWidget {
  const ReadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FluentAppBar(
        title: AppStrings.readingTitle,
        subtitle: 'Curated passages, articles, and contextual vocabulary',
        showBackButton: true,
      ),
      body: SafeArea(
        child: EmptyState(
          icon: Icons.menu_book_rounded,
          title: '${AppStrings.readingTitle} Module',
          description:
              'Graded reader passages with tap-to-define vocabulary, speed reading drills, and comprehension questions will be implemented here.',
          actionLabel: 'Return to Practice',
          onAction: () => context.pop(),
        ),
      ),
    );
  }
}
