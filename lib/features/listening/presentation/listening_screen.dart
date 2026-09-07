import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/widgets.dart';

/// Placeholder screen for listening comprehension exercises (/practice/listening).
class ListeningScreen extends StatelessWidget {
  const ListeningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FluentAppBar(
        title: AppStrings.listeningTitle,
        subtitle: 'Audio comprehension and native dialogue passages',
        showBackButton: true,
      ),
      body: SafeArea(
        child: EmptyState(
          icon: Icons.headphones_rounded,
          title: '${AppStrings.listeningTitle} Module',
          description:
              'Natural conversational dialogues, comprehension checks, and playback speed controls will be implemented here.',
          actionLabel: 'Return to Practice',
          onAction: () => context.pop(),
        ),
      ),
    );
  }
}
