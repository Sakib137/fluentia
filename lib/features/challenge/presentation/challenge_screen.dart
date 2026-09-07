import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/widgets.dart';

/// Placeholder screen for the daily challenge exercise (/challenge).
class ChallengeScreen extends StatelessWidget {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FluentAppBar(
        title: AppStrings.challengeTitle,
        subtitle: AppStrings.challengeSubtitle,
        showBackButton: true,
      ),
      body: SafeArea(
        child: EmptyState(
          icon: Icons.flag_rounded,
          title: 'Daily Challenge Active',
          description:
              'A rotating mix of speech, listening, and vocabulary exercises refreshed every 24 hours to test your skills.',
          actionLabel: 'Return to Home',
          onAction: () => context.pop(),
        ),
      ),
    );
  }
}
