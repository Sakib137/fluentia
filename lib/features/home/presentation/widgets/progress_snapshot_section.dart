import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/design_system.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/stat_card.dart';
import '../../data/models/home_models.dart';
import '../providers/home_providers.dart';

/// Progress Snapshot section displaying real-time metrics across learning activities.
class ProgressSnapshotSection extends ConsumerWidget {
  const ProgressSnapshotSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshotAsync = ref.watch(progressSnapshotProvider);
    final isDark = context.isDarkMode;
    final snapshot = snapshotAsync.value ?? ProgressSnapshotData.initial();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: SectionHeader(
            title: 'Progress Snapshot',
            subtitle: 'Your cumulative offline practice achievements',
            leadingIcon: Icons.insights_rounded,
            actionLabel: 'Full Progress →',
            onAction: () {
              context.go(AppRoutes.progress);
            },
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 500;
              final itemWidth = isWide
                  ? (constraints.maxWidth - (AppSpacing.sm * 2)) / 3
                  : (constraints.maxWidth - AppSpacing.sm) / 2;

              return Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  SizedBox(
                    width: itemWidth,
                    child: StatCard(
                      label: 'Estimated Level',
                      value: snapshot.cefrLevel,
                      subtitle: snapshot.levelTitle,
                      icon: Icons.workspace_premium_rounded,
                      onTap: () => context.go(AppRoutes.progress),
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: StatCard(
                      label: 'Practice Time',
                      value: '${snapshot.totalPracticeMinutes}m',
                      subtitle: 'Total minutes logged',
                      icon: Icons.timer_outlined,
                      onTap: () => context.go(AppRoutes.progress),
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: StatCard(
                      label: 'Words Saved',
                      value: '${snapshot.wordsLearnedCount}',
                      subtitle: 'Vocabulary bank',
                      icon: Icons.book_outlined,
                      onTap: () => context.go(AppRoutes.learnVocabulary),
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: StatCard(
                      label: 'Sessions',
                      value: '${snapshot.completedSessionsCount}',
                      subtitle: 'Completed drills',
                      icon: Icons.sports_score_rounded,
                      onTap: () => context.go(AppRoutes.progress),
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: StatCard(
                      label: 'Active Streak',
                      value: '${snapshot.currentStreakDays}d',
                      subtitle: 'Consecutive days',
                      icon: Icons.local_fire_department_rounded,
                      iconColor: isDark ? AppColors.sage400 : AppColors.sage600,
                      onTap: () => context.go(AppRoutes.progress),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
