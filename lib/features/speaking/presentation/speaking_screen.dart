import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/widgets.dart';

/// Placeholder screen for speaking and pronunciation exercises (/practice/speaking).
class SpeakingScreen extends StatelessWidget {
  const SpeakingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FluentAppBar(
        title: AppStrings.speakingTitle,
        subtitle: 'Pronunciation and oral fluency practice',
        showBackButton: true,
      ),
      body: SafeArea(
        child: EmptyState(
          icon: Icons.mic_rounded,
          title: '${AppStrings.speakingTitle} Module',
          description:
              'Interactive speech recognition, phonetic feedback, and pronunciation drills will be implemented here.',
          actionLabel: 'Return to Practice',
          onAction: () => context.pop(),
        ),
      ),
    );
  }
}
