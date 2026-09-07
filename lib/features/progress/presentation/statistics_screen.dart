import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/design_system.dart';
import '../../../shared/widgets/widgets.dart';

/// Structural placeholder screen for detailed progress analytics (/progress/statistics).
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FluentAppBar(
        title: 'Detailed Statistics',
        subtitle: 'Longitudinal learning metrics and trends',
        showBackButton: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            const SectionHeader(
              title: 'Study Trends',
              subtitle:
                  'Weekly activity distribution across all English skills',
            ),
            const SizedBox(height: AppSpacing.sm),
            const AppCard(
              padding: AppSpacing.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Historical Performance Chart',
                    style: TextStyle(
                      fontSize: AppFontSizes.titleMedium,
                      fontWeight: AppFontWeights.semiBold,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'Time-series graphs for speaking accuracy, listening retention, and vocabulary recall will be displayed here.',
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
              icon: Icons.bar_chart_rounded,
              title: 'Statistics Module Ready',
              description:
                  'Complete at least one practice session to start generating longitudinal retention and performance analytics.',
              actionLabel: 'Return to Progress',
              onAction: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}
