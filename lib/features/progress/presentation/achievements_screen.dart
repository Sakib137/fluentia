import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/design_system.dart';
import '../../../shared/widgets/widgets.dart';

/// Structural placeholder screen for learner milestones and badges (/progress/achievements).
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FluentAppBar(
        title: 'Milestones & Badges',
        subtitle: 'Celebrate fluency consistency and accomplishments',
        showBackButton: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            const SectionHeader(
              title: 'Mastery Milestones',
              subtitle:
                  'Badges earned through consistent daily study and skill drills',
            ),
            const SizedBox(height: AppSpacing.sm),
            const AppCard(
              padding: AppSpacing.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Milestone Catalog',
                    style: TextStyle(
                      fontSize: AppFontSizes.titleMedium,
                      fontWeight: AppFontWeights.semiBold,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'Earn badges for streak milestones (7, 30, 100 days), CEFR level advancements, and 500+ vocabulary mastery.',
                    style: TextStyle(
                      fontSize: AppFontSizes.bodySmall,
                      color: AppColors.slate500,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            EmptyState(
              icon: Icons.emoji_events_outlined,
              title: 'Milestones Module Ready',
              description:
                  'Earn your first milestone badge by maintaining a 3-day practice streak.',
              actionLabel: 'Return to Progress',
              onAction: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}
